@isTest
private class TestTaskTrigger {

    @TestSetup
    static void makeData(){
        TestDataFactory.createAccounts(5);
    }

    @isTest
    private static void updateTaskTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Task task = TestDataFactory.createTask(user.Id, [SELECT Id FROM Account LIMIT 1].Id);
            Test.startTest();
            try {
                task.Status = 'In Progress';
                update task;
            } catch (DMLException dmle) {
                System.debug(dmle);
            }
            Test.stopTest();
            System.assertNotEquals(0, [SELECT Id, Number_of_activities__c FROM Account WHERE Number_of_activities__c > 0].size());
        }
    }

    @isTest
    private static void insertTaskTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Test.startTest();
            try {
                TestDataFactory.createTask(user.Id, [SELECT Id FROM Account LIMIT 1].Id);
            } catch (DMLException dmle) {
                System.debug(dmle);
            }
            Test.stopTest();
            System.assertNotEquals(0, [SELECT Id, Number_of_activities__c FROM Account WHERE Number_of_activities__c > 0].size());
        }
    }

    @isTest
    private static void deleteTaskTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Id accId = [SELECT Id FROM Account LIMIT 1].Id;
            Task task = TestDataFactory.createTask(user.Id, accId);
            TestDataFactory.createTask(user.Id, accId);
            Test.startTest();
            try {
                delete task;
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
    private static void insertTasksTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {            
            Test.startTest();
            TestDataFactory.createTasksForAccs([SELECT Id, Number_of_activities__c FROM Account], user.Id);
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
    private static void deleteTasksTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            TestDataFactory.createTasksForAccs([SELECT Id, Number_of_activities__c FROM Account], user.Id);         
            Test.startTest();
            Account acc = [SELECT Id, Number_of_activities__c FROM Account LIMIT 1];
            Task[] tasksToDelete = [SELECT Id, whatId, ownerId FROM Task WHERE whatId =: acc.Id AND ownerId = :user.Id LIMIT 10];
            delete tasksToDelete;
            Test.stopTest();
            System.assertNotEquals(50,  [SELECT Id, Number_of_activities__c FROM Account WHERE Id = : acc.Id LIMIT 1].Number_of_activities__c);
            System.assertEquals(40,  [SELECT Id, Number_of_activities__c FROM Account WHERE Id = : acc.Id LIMIT 1].Number_of_activities__c);
        } 
    }

    @isTest
    private static void taskParentChangesTest() {
        User user = TestDataFactory.createAdminUser();
        System.runAs(user) {
            Account[] accs = [SELECT Id, Name, Number_of_activities__c FROM Account LIMIT 2];
            Task t = TestDataFactory.createTask(user.Id, accs[0].Id);
            Test.startTest();
            t.WhatId = accs[1].Id;
            update t;
            Test.stopTest();
            System.assertEquals(1, [SELECT Id, Number_of_activities__c FROM Account WHERE Id = :accs[1].Id].Number_of_activities__c);
            System.assertEquals(0, [SELECT Id, Number_of_activities__c FROM Account WHERE Id = :accs[0].Id].Number_of_activities__c);
        }
    }
}

