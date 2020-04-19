global with sharing class TrelloSyncSch implements Schedulable {

    global void execute(SchedulableContext sc) {
        TrelloSyncController.syncCards();
    }
}