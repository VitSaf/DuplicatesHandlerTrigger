@IsTest
public class ContactTriggerTest {
/**
 * 
 * === Apex Code Coverage by Class
        CLASSES                PERCENT  UNCOVERED LINES
        ─────────────────────  ───────  ───────────────
        TriggerDispatcher      100%                    
        ContactTriggerHandler  77%      27,33,36       
        ContactHelper          87%      23,24,36,38,58 
        ContactTrigger         100%      
 */
    @TestSetup
    static void makeData(){
        insert new Contact(LastName = 'Testov', FirstName = 'Test', Email = 'test@mail.com');//origin
    }

    @isTest
    private static void testBeforeInsertDuplEmail() {
        String result;
        Test.startTest();
        try {
            insert new Contact(LastName = 'Contactov', FirstName = 'Anon', Email = 'test@mail.com');//email dupl
        } catch (Exception e) {
            result = e.getMessage();
        }
        Test.stopTest();
        System.assert(result.contains(ContactHelper.ERROR_TEXT));
    }

    @isTest
    private static void testBeforeInsertDuplName() {
        String result;
        Test.startTest();
        try {
            insert new Contact(LastName = 'Testov', FirstName = 'Test', Email = 'diff@mail.com');//Name dupl
        } catch (Exception e) {
            result = e.getMessage();
        }
        Test.stopTest();
        System.assert(result.contains(ContactHelper.ERROR_TEXT));
    } 

    @isTest
    private static void testBeforeInsertNotDupl() {
        String result;
        Test.startTest();
        try {
            insert new Contact(LastName = 'Testov', FirstName = 'Not', Email = 'nottest@mail.com');
        } catch (Exception e) {
            result = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertEquals(2, [SELECT Id, Name FROM Contact].size());
    }

    @isTest
    private static void testBeforeUpdateDuplEmail() {
        String result;
        Contact almostDupl = new Contact(LastName = 'Contactov', FirstName = 'Anon', Email = 'test1@mail.com');
        insert almostDupl;
        Test.startTest();
        try {
            almostDupl.Email = 'test@mail.com';
            update almostDupl;
            //email dupl
        } catch (Exception e) {
            result = e.getMessage();
        }
        Test.stopTest();
        System.assert(result.contains(ContactHelper.ERROR_TEXT));
    }

    @isTest
    private static void testBeforeUpdateDuplName() {
        String result;
        Contact almostDupl = new Contact(LastName = 'Contactov', FirstName = 'Anon', Email = 'test1@mail.com');
        insert almostDupl;
        Test.startTest();
        try {
            almostDupl.LastName = 'Testov';
            almostDupl.FirstName = 'Test';
            update almostDupl;
        } catch (Exception e) {
            result = e.getMessage();
        }
        Test.stopTest();
        System.assert(result.contains(ContactHelper.ERROR_TEXT));
    }

    @isTest
    private static void testBeforeUpdateNotDupl() {
        String result;
        Contact almostDupl = new Contact(LastName = 'Contactov', FirstName = 'Anon', Email = 'test1@mail.com');
        insert almostDupl;
        String oldName = almostDupl.Name;
        Test.startTest();
        try {
            almostDupl.LastName = 'Contactovich';
            almostDupl.LastName = 'Cont';
            almostDupl.Email = 'Contactovich@mail.com';
            update almostDupl;
        } catch (Exception e) {
            result = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(oldName, [SELECT Id, Name FROM Contact WHERE Id = :almostDupl.Id].Name);
    }
}