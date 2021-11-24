@isTest
private class TestEventTrigger {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createAccounts(5);
    }

    @isTest
    private static void updateEventTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Event event = TestDataFactory.createEvent(user.Id, [SELECT Id FROM Account LIMIT 1].Id);
            Test.startTest();
            try {
                event.EndDateTime = event.EndDateTime.addHours(1);
                update event;
            } catch (DMLException dmle) {
                System.debug(dmle);
            }
            Test.stopTest();
            System.assertNotEquals(0, [SELECT Id, Number_of_activities__c FROM Account WHERE Number_of_activities__c > 0].size());
        }
    }

    @isTest
    private static void insertEventTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Test.startTest();
            try {
                TestDataFactory.createEvent(user.Id, [SELECT Id FROM Account LIMIT 1].Id);
            } catch (DMLException dmle) {
                System.debug(dmle);
            }
            Test.stopTest();
            System.assertNotEquals(0, [SELECT Id, Number_of_activities__c FROM Account WHERE Number_of_activities__c > 0].size());
        }
    }

    @isTest
    private static void deleteEventTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Id accId = [SELECT Id FROM Account LIMIT 1].Id;
            Event event = TestDataFactory.createEvent(user.Id, accId);
            TestDataFactory.createEvent(user.Id, accId);
            Test.startTest();
            try {
                delete event;
            } catch (DMLException dmle) {
                System.debug(dmle);
            }
            Test.stopTest();
            Account activeAcc = [SELECT Id, Number_of_activities__c FROM Account WHERE Id = :accId LIMIT 1];
            System.assertNotEquals(2, activeAcc.Number_of_activities__c);
            System.assertEquals(1, activeAcc.Number_of_activities__c);
        }
    }

    @isTest
    private static void insertEventsTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Test.startTest();
            TestDataFactory.createEventsForAccs([SELECT Id, Number_of_activities__c FROM Account], user.Id);
            Test.stopTest();
            
            Boolean assertFlag = true;
            for (Account a : [SELECT Id, Number_of_activities__c FROM Account]) {
                if (a.Number_of_activities__c != 50) {
                    assertFlag = false;
                }
            }
            System.assertNotEquals(false, assertFlag);
        }
    }

    @isTest
    private static void deleteEventsTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            TestDataFactory.createEventsForAccs([SELECT Id, Number_of_activities__c FROM Account], user.Id);         
            Test.startTest();
            Account acc = [SELECT Id, Number_of_activities__c FROM Account LIMIT 1];
            Event[] eventsToDelete = [SELECT Id, whatId, ownerId FROM Event WHERE whatId =: acc.Id AND ownerId = :user.Id LIMIT 10];
            delete eventsToDelete;
            Test.stopTest();
            System.assertNotEquals(50,  [SELECT Id, Number_of_activities__c FROM Account WHERE Id = : acc.Id LIMIT 1].Number_of_activities__c);
            System.assertEquals(40,  [SELECT Id, Number_of_activities__c FROM Account WHERE Id = : acc.Id LIMIT 1].Number_of_activities__c);
        } 
    }

    @isTest
    private static void eventParentChangesTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Account[] accs = [SELECT Id, Name, Number_of_activities__c FROM Account LIMIT 2];
            Id[] ids = new List<Id>{accs[0].Id, accs[1].Id};
            Event e = TestDataFactory.createEvent(user.Id, accs[0].Id);
            Test.startTest();
            e.WhatId = accs[1].Id;
            update e;
            Test.stopTest();
            System.assertEquals(1, [SELECT Id, Number_of_activities__c FROM Account WHERE Id = :accs[1].Id].Number_of_activities__c);
            System.assertEquals(0, [SELECT Id, Number_of_activities__c FROM Account WHERE Id = :accs[0].Id].Number_of_activities__c);
        }
    }

}
