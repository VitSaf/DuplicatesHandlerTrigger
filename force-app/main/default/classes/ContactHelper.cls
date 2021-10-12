public with sharing class ContactHelper {


    @TestVisible
    private static final String ERROR_TEXT = 'This is a duplicate';

    public static void checkForDuplicatesInsert(List<Contact> newContacts) {
        List<String> emails = new List<String>();
        List<String> names = new List<String>();
        Map<String, Contact> nameContactMap = new Map<String, Contact>();
        Map<String, Contact> emailContactMap = new Map<String, Contact>();
        //method always runs in O(n) because of this loop
        for(Contact cont : newContacts) {
            //for SOQL + npe handling
            if (cont.email != null) {
                emailContactMap.put(cont.Email, cont);
                emails.add(cont.email);
            }
            if (cont.FirstName != null) {//FirstName + LastName to search in Names
                names.add(cont.FirstName + ' ' + cont.LastName);
                nameContactMap.put(cont.FirstName + ' ' + cont.LastName, cont);
            } else {
                names.add(cont.LastName);
                nameContactMap.put(cont.LastName, cont);
            }
        }
        for(Contact duplContact : [SELECT Id, Name, FirstName, LastName, Email FROM Contact WHERE Name IN :names OR Email In :emails]) {//potential duplicates
            try {
                if (nameContactMap.get(duplContact.FirstName + ' ' + duplContact.LastName) != null) {//checking Names
                    nameContactMap.get(duplContact.Name).addError(ERROR_TEXT);
                } else {
                    if (emailContactMap.get(duplContact.Email) != null) {//if names OK checking emails
                        emailContactMap.get(duplContact.Email).addError(ERROR_TEXT);
                    }
                }
            } catch (Exception e) {
                System.debug(e + ' | ' + duplContact);
                continue;
            }

        }

    }

    //before update
    public static void checkForDuplicatesUpdate(Map<Id, Contact> newContactsMap) {
        //before update check is simplier because of existing IDs and standard trigger <Id, SObject> Maps
        List<String> emails = new List<String>();
        List<String> names = new List<String>();
        //method always runs in O(n) because of this loop
        for(Contact cont : newContactsMap.values()) {
            if (cont.email != null) {
                emails.add(cont.email);
            }
            if (cont.FirstName != null) {
                names.add(cont.FirstName + ' ' + cont.LastName);
            } else {
                names.add(cont.LastName);
            }
        }
        //same as in checkForDuplicatesInsert
        for(Contact duplContact : [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Name IN :names OR Email IN :emails]) {
            try {
                if (newContactsMap.get(duplContact.Id).FirstName + ' ' + newContactsMap.get(duplContact.Id).LastName == duplContact.FirstName + ' ' + duplContact.LastName) {
                    newContactsMap.get(duplContact.Id).addError(ERROR_TEXT);
                } else {
                    if (newContactsMap.get(duplContact.Id).Email == duplContact.Email) {
                        newContactsMap.get(duplContact.Id).addError(ERROR_TEXT);
                    }
                }
            } catch (Exception e) {
                System.debug(e + ' | ' + duplContact);
                continue;
            }

        }
    }
}