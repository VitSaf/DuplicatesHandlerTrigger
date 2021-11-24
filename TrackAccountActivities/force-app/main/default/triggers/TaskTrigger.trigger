trigger TaskTrigger on Task (after insert, after update, after delete) {
    TriggerDispatcher.run(TaskTriggerHandler.getInstance());
}