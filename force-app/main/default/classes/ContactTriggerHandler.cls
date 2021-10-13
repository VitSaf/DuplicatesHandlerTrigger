public with sharing class ContactTriggerHandler implements ITriggerHandler {
    private static ContactTriggerHandler instance;

    private ContactTriggerHandler() {}

    /**
     * Create a simple deduplication trigger for contacts.
        A duplicate has the same email address or the same first and last name
        Make sure it also works on update
        Please take care of production readiness
     */

    public static ContactTriggerHandler getInstance() {
        if (instance == null) instance = new ContactTriggerHandler();
        return instance;
    }

    public void processBeforeInsert(List<SObject> newRecords) {
        ContactHelper.checkForDuplicatesInsert((List<Contact>)newRecords);
    }

    public void processBeforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        ContactHelper.checkForDuplicatesUpdate((Map<Id, Contact>)newRecords); 
    }

    public void processBeforeDelete(Map<Id, SObject> oldRecords) {}

    public void processAfterInsert(Map<Id, SObject> newRecords) {}

    public void processAfterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {}

    public void processAfterDelete(Map<Id, SObject> oldRecords) {
    }

    public void processAfterUndelete(Map<Id, SObject> newRecords) {}
    
}