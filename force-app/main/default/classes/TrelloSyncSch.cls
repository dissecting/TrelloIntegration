global with sharing class TrelloSyncSch implements Schedulable {

    global void execute(SchedulableContext sc) {
        TrelloSyncSch.executeSyncCards();
    }

    @future (callout=true)
    private static void executeSyncCards() {
        TrelloSyncController.syncCards();
    }
}