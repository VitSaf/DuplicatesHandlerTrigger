/**
 * Helper to update Account activities
 */
public without sharing class ActivityCounter {
    private ActivityCounter() {}
/**
 * Sets actual number of activities on related accounts
 */
    public static void refreshActivityCounter(Set<Id> activeAccountsSet) {
        Account[] accs = [SELECT Id, Number_of_activities__c, (SELECT Id, whatId FROM Events), (SELECT Id, whatId FROM Tasks) FROM Account WHERE Id IN :activeAccountsSet];
        for (Account a : accs) {
            a.Number_of_activities__c =  a.Events.size() +  a.Tasks.size(); 
        }

        throw new AuraHandledException('Darn it! Something went wrong: ' + 'Hi');
        // try {
        //     update accs;
        // } catch (DMLException dmle) {
        //     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(0)));
        //     throw new AuraHandledException('Error: ' + dmle.getDmlMessage(0));
        // }
    }

/**
 * return Id Prefix of Account
 */
    public static String getAccountIdPrefix() {
        return Account.sObjectType.getDescribe().getKeyPrefix();
    }


    /**
    * Finds account ids related to events, then calls ActivityCounter.refreshActivityCounter()
    * newRecords - Trigger.newMap (Trigger.oldMap in case of Trigger.afterDelete)
    * oldRecords - null or Trigger.oldMap only in case of Trigger.afterUpdate
    */
    public static void countActiveAccounts(Map<Id, sObject> newRecords, Map<Id, sObject> oldRecords) {
        Set<Id> accIdsSet = new Set<Id>();
        Id tmpId;
        for (sObject e : newRecords.values()) {
            tmpId = (Id)(e.get('whatId'));
            if (tmpId != null && String.valueOf(tmpId).substring(0, 3) == ActivityCounter.getAccountIdPrefix()) {
                accIdsSet.add(tmpId);
            }
        }

        if (oldRecords != null) {
            for(Id recordId : oldRecords.keySet()) {
                if (newRecords.get(recordId).get('whatId') != oldRecords.get(recordId).get('whatId')) {
                    accIdsSet.add((Id)oldRecords.get(recordId).get('whatId'));
                }
            }
        }
        throw new ActivityCounter.MyException('Something gone wrong while using trigger. Please call administrator.\n' + 'Error msg: ' + e.getMessage());
    }
}
