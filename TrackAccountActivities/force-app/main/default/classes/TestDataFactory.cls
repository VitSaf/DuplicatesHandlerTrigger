/**
 * Data Factory for tests
 */
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

    public static Event createEvent(Id userId, Id accountId) {
        Event e = new Event(ownerId = userId, whatId = accountId, StartDateTime = Datetime.now(), EndDateTime = Datetime.now().addHours(5));
        try {
            insert e;
        } catch (DMLException dmle) {
            System.debug(dmle);
        }
        return e;
    }

    public static Task createTask(Id userId, Id accountId) {
        Task t = new Task(ownerId = userId, whatId = accountId, Status = 'Not Started');
        try {
            insert t;
        } catch (DMLException dmle) {
            System.debug(dmle);
        }
        return t;
    }

    public static Account[] createAccounts(Integer accsNum) {
        Account[] accs = new List<Account>();
        for(Integer i = 0; i < accsNum; i++) {
            accs.add(new Account(Name = 'testAcc' + i));
        }
        try {
            insert accs;
        } catch (DMLException dmle) {
            System.debug(dmle);
        }
        return accs;
    }

    public static Event[] createEventsForAccs(Account[] accs, Id userId) {
        Event[] events = new List<Event>();
        for (Integer i = 0; i < 50; i++) {
            for (Account a : accs) {
                events.add(new Event(ownerId = userId, whatId = a.Id, StartDateTime = Datetime.now(), EndDateTime = Datetime.now().addHours(5)));
            }
        }

        try {
            insert events;
        } catch (DMLException dmle) {
            System.debug(dmle);
        }
        return events;
    }

    public static Task[] createTasksForAccs(Account[] accs, Id userId) {
        Task[] tasks = new List<Task>();
        for (Integer i = 0; i < 50; i++) {
            for (Account a : accs) {
                tasks.add(new Task(ownerId = userId, whatId = a.Id, Status = 'Not Started'));
            }
        }

        try {
            insert tasks;
        } catch (DMLException dmle) {
            System.debug(dmle);
        }
        return tasks;
    }
}
