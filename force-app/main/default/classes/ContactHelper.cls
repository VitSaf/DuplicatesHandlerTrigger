public with sharing class ContactHelper {


    @TestVisible
    private static final String ERROR_TEXT = 'This is a duplicate';

    public static void checkForDuplicatesInsert(List<Contact> newContacts) {
        List<String> emailsToCheck = new List<String>();
        List<String> namesToCheck = new List<String>();
        //we need this map because new records don't have Id's yet
        Map<String, Contact> nameContactMap = new Map<String, Contact>();//<Name, Contact>
        Map<String, Contact> emailContactMap = new Map<String, Contact>();//<Email, Contact>
        //method always runs in O(n) because of this loop
        for(Contact cont : newContacts) {
            //for SOQL + npe handling
            if (cont.email != null) {
                emailContactMap.put(cont.Email, cont);
                emailsToCheck.add(cont.email);
            }
            if (cont.FirstName != null) {//FirstName + LastName to search in Names
                namesToCheck.add(cont.FirstName + ' ' + cont.LastName);
                nameContactMap.put(cont.FirstName + ' ' + cont.LastName, cont);
            } else {
                namesToCheck.add(cont.LastName);
                nameContactMap.put(cont.LastName, cont);
            }
        }
        for(Contact potentialDuplContact : [SELECT Id, Name, FirstName, LastName, Email FROM Contact WHERE Name IN :namesToCheck OR Email In :emailsToCheck]) {//potential duplicates
            try {// if we have more that one duplicate in records from DB, we will get NPE
                if (nameContactMap.get(potentialDuplContact.FirstName + ' ' + potentialDuplContact.LastName) != null) {//checking Names
                    nameContactMap.get(potentialDuplContact.Name).addError(ERROR_TEXT);
                } else {
                    if (emailContactMap.get(potentialDuplContact.Email) != null) {//if names OK checking emails
                        emailContactMap.get(potentialDuplContact.Email).addError(ERROR_TEXT);
                    }
                }
            } catch (NullPointerException npe) {
                continue;
            }
        }
    }

    //before update
    public static void checkForDuplicatesUpdate(Map<Id, Contact> newContactsMap) {
        //before update check is simplier because of existing IDs and 'newMap' trigger context variable
        List<String> emailsToCheck = new List<String>();
        List<String> namesToCheck = new List<String>();
        //method always runs in O(n) because of this loop
        for(Contact cont : newContactsMap.values()) {
            if (cont.email != null) {
                emailsToCheck.add(cont.email);
            }
            if (cont.FirstName != null) {
                namesToCheck.add(cont.FirstName + ' ' + cont.LastName);
            } else {
                namesToCheck.add(cont.LastName);
            }
        }
        //same as in checkForDuplicatesInsert
        for(Contact potentialDuplContact : [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Name IN :namesToCheck OR Email IN :emailsToCheck]) {
            try {
                if (newContactsMap.get(potentialDuplContact.Id).FirstName + ' ' + newContactsMap.get(potentialDuplContact.Id).LastName == potentialDuplContact.FirstName + ' ' + potentialDuplContact.LastName) {
                    newContactsMap.get(potentialDuplContact.Id).addError(ERROR_TEXT);
                } else {
                    if (newContactsMap.get(potentialDuplContact.Id).Email == potentialDuplContact.Email) {
                        newContactsMap.get(potentialDuplContact.Id).addError(ERROR_TEXT);
                    }
                }
            } catch (NullPointerException npe) {
                continue;
            }
        }
    }
}