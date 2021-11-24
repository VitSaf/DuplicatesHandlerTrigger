@isTest
public class TestDataFactory {
    private TestDataFactory() {}

    public static User createAdminUser() {
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(Username = 'test3453User345@testtt.com', IsActive = true, ProfileId = prof.Id, Alias = 'testU',
                        email = 'test123@mail.com', LastName = 'test', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                        EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        try {
            insert user;
        } catch (DMLException dmle) {
            System.debug(dmle);
        }
        return user;
    }

    public static Account[] createAccounts(Integer accsNum) {
        Account[] accs = new List<Account>();
        for(Integer i = 0; i < accsNum; i++) {
            accs.add(new Account(Name = 'testAcc' + i));
        }

        insert accs;

        return accs;
    }

    public static Product2[] createProducts(Integer n) {
        Product2[] products = new List<Product2>();
        for (Integer i = 0; i < n; i++) {
            products.add(new Product2(Name = 'test' + i, ProductCode = 'NN111' + i, isActive = true));
        }
        insert products;
        return products;
    }

    public static Product2[] createProducts(String[] codes) {
        Product2[] products = new List<Product2>();
        for (String code : codes) {
            products.add(new Product2(Name = 'test' + code + 'test', ProductCode = code, isActive = true));
        }
        insert products;
        return products;
    }

    public static Agreement__c[] createAgreements(String[] productCodes, Id accId) {
        Agreement__c[] agrs = new List<Agreement__c>();
        for (Integer i = 0; i < productCodes.size(); i++) {
            agrs.add(new Agreement__c(Name = 'testAgr' + i, Account__c = accId, Products__c = productCodes[i]));
        }
        insert agrs;
        return agrs;
    }

    public static Agreement__c[] queryJunctionFromAgreement(Agreement__c[] agrs) {
        return [SELECT  Id, Products__c, (SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Products__r)
                FROM Agreement__c 
                WHERE Id IN :agrs];
    }


}
