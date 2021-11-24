trigger EventTrigger on Event (after insert, after update, after delete) {
    TriggerDispatcher.run(EventTriggerHandler.getInstance());
}