@isTest
public class AgreementHelperTest {
    private AgreementHelperTest() {}

    @TestSetup
    private static void makeData(){
        Id accId = TestDataFactory.createAccounts(1)[0].Id;
        TestDataFactory.createProducts(10);
        //TestDataFactory.createAgreements(new List<String>{'NN1110,NN1111', 'NN1110,NN1111,NN1112', 'NN1114,NN1113','NN1113'},accId);
    }

    @isTest
    private static void insertAgreementTest() {
        String codes = '';
        final Integer NUM = 3;
        
        for (Product2 prod : [SELECT ProductCode FROM Product2 LIMIT :NUM]) {
            codes += prod.ProductCode + ',';
        }
        
        System.runAs(TestDataFactory.createAdminUser()) {
            Test.startTest();
            Agreement__c[] agrs = TestDataFactory.createAgreements(new List<String>{codes.removeEnd(',')}, [SELECT Id FROM Account LIMIT 1].Id);
            Test.stopTest();
            System.assertEquals(NUM, TestDataFactory.queryJunctionFromAgreement(agrs)[0].Agreement_Products__r.size());
        }
    }

    @isTest
    private static void updateAgreementAddCodeTest() {
        System.runAs(TestDataFactory.createAdminUser()) {
            Product2[] products = [SELECT Id, ProductCode FROM Product2 LIMIT 3];
            Agreement__c agr = TestDataFactory.createAgreements(new List<String>{products[0].ProductCode + ',' + products[1].ProductCode}
                                                                ,[SELECT Id FROM Account LIMIT 1].Id)[0];
            
            Test.startTest();
            Agreement__c a = [SELECT Id, Products__c, Name FROM Agreement__c WHERE Id =:agr.Id];
            a.Products__c = agr.Products__c  + ',' + products[2].ProductCode;
            update a;
            Test.stopTest();
            System.assertEquals(2 + 1, [SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Product_Junction__c WHERE Agreement__c = :a.Id].size());
        }
    }

    @isTest
    private static void updateAgreementsTest() {

        System.runAs(TestDataFactory.createAdminUser()) {
            Product2[] prods = TestDataFactory.createProducts(new List<String>{'NP1010','NP1011', 'NP1012', 'NP1013'});
            Test.startTest();
            Agreement__c[] agrms = TestDataFactory.createAgreements(new List<String>{'NP1010,NP1011','NP1010,NP1012','NP1010,NP1013,NP1012'}
                                                                    , [SELECT Id FROM Account LIMIT 1].Id);
            Set<Agreement_Product_Junction__c> jun10 = new Set<Agreement_Product_Junction__c>([SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Product_Junction__c WHERE Agreement__c = :agrms[0].Id]);
            Set<Agreement_Product_Junction__c> jun11 = new Set<Agreement_Product_Junction__c>([SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Product_Junction__c WHERE Agreement__c = :agrms[2].Id]);
            agrms[0].Products__c = 'NP1010,NP1011,NP1012';
            agrms[2].Products__c = 'NP1010';
            update agrms;
            Test.stopTest();
            Set<Agreement_Product_Junction__c> jun20 = new Set<Agreement_Product_Junction__c>([SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Product_Junction__c WHERE Agreement__c = :agrms[0].Id]);
            Set<Agreement_Product_Junction__c> jun21 = new Set<Agreement_Product_Junction__c>([SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Product_Junction__c WHERE Agreement__c = :agrms[2].Id]);
            System.assertNotEquals(jun10, jun20);
            System.assertNotEquals(jun11, jun21);
            System.assertEquals(agrms[0].Products__c.split(',').size(), jun20.size());
            System.assertEquals(agrms[2].Products__c.split(',').size(), jun21.size());
        }
    }

    @isTest
    private static void insertAgreementsTest() {
        final Integer NUM = 50;
        final String code = 'NN1110,NN1111,NN1112';
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        String[] codes = new List<String>();
        for (Integer i = 0; i < NUM; i++) {
            codes.add(code);
        }
        
        System.runAs(TestDataFactory.createAdminUser()) {
            Test.startTest();
            Agreement__c[] agrs = TestDataFactory.createAgreements(codes, accId);
            Test.stopTest();
            Integer sum = 0;
            for (Agreement__c agr : TestDataFactory.queryJunctionFromAgreement(agrs)) {
                sum += agr.Agreement_Products__r.size();
            }
            System.assertEquals(NUM*3 , sum);//3 is number of Products on each Agreement__c
        }
    }
    //TODO Add test for undelete

}
