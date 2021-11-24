public with sharing class TaskTriggerHandler implements ITriggerHandler {
    private static TaskTriggerHandler instance;

    private TaskTriggerHandler() {}


    public static TaskTriggerHandler getInstance() {
        if (instance == null) {
            instance = new TaskTriggerHandler();
        }
        return instance;
    }

    public void processBeforeInsert(List<SObject> newRecords) {
    }

    public void processBeforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
    }

    public void processBeforeDelete(Map<Id, SObject> oldRecords) {}

    public void processAfterInsert(Map<Id, SObject> newRecords) {
        ActivityCounter.countActiveAccounts(newRecords, null);
    }

    public void processAfterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        ActivityCounter.countActiveAccounts(newRecords, oldRecords);
    }

    public void processAfterDelete(Map<Id, SObject> oldRecords) {
        ActivityCounter.countActiveAccounts(oldRecords, null);
    }

    public void processAfterUndelete(Map<Id, SObject> newRecords) {
        ActivityCounter.countActiveAccounts(newRecords, null);
    }
    
}