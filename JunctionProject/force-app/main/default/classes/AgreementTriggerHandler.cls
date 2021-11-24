public with sharing class AgreementTriggerHandler implements ITriggerHandler  {
    private static AgreementTriggerHandler instance;

    private AgreementTriggerHandler() {}

    public static AgreementTriggerHandler getInstance() {
        if (instance == null) instance = new AgreementTriggerHandler();
        return instance;
    }

    public void processBeforeInsert(List<SObject> newRecords) {
    }

    public void processBeforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
    }

    public void processBeforeDelete(Map<Id, SObject> oldRecords) {}

    public void processAfterInsert(Map<Id, SObject> newRecords) {
        AgreementHelper.actualizeJunctionRecords((Map<Id, Agreement__c>) newRecords, null);
    }

    public void processAfterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
        AgreementHelper.actualizeJunctionRecords((Map<Id, Agreement__c>) newRecords, (Map<Id, Agreement__c>) oldRecords);
    }
    public void processAfterDelete(Map<Id, SObject> oldRecords) {
    }

    public void processAfterUndelete(Map<Id, SObject> newRecords) {
        AgreementHelper.actualizeJunctionRecords((Map<Id, Agreement__c>) newRecords, null);
    }
    
}
