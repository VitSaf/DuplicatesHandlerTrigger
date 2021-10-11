trigger ContactTrigger on Contact (before insert,after insert, before update, after update, after delete, before delete) {
    TriggerDispatcher.run(ContactTriggerHandler.getInstance());
}