public with sharing class ContactHelper {
    private ContactHelper() {}

    @AuraEnabled(Cacheable = true)
    public static String getAllAccounts() {
        return JSON.serialize([SELECT Id, Name FROM Account WITH SECURITY_ENFORCED]);
    }

    @AuraEnabled(Cacheable = true)
    public static String getContactAccessibleFields() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        String[] result = new List<String>();
        for (String S : fieldMap.keySet()) {
            if (fieldMap.get(s).getDescribe().isCreateable()
             && fieldMap.get(s).getDescribe().isAccessible()
             && fieldMap.get(s).getDescribe().isUpdateable()
             && fieldMap.get(s) + '' != 'AccountId') {
                result.add(fieldMap.get(s) + '');
        }
    }
      return JSON.serialize(result);
    }
}