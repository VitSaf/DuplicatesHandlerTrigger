trigger AgreementTrigger on Agreement__c (after insert, after undelete, after update) {
    TriggerDispatcher.run(AgreementTriggerHandler.getInstance());
}