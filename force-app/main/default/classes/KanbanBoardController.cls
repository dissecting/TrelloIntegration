public with sharing class KanbanBoardController {

    @AuraEnabled
    public static KanbanBoard getKanbanBoard() {
        TrelloSyncController.syncCards();

        List<Trello_Status_Setting__mdt> statusList = [
            SELECT Position__c, Status__c
            FROM Trello_Status_Setting__mdt
            ORDER BY Position__c
        ];

        List<String> statuses = new List<String>();
        List<Card__c> availableCardList = [
            SELECT Name, Description__c, Assignee__c, Due_Date__c, Status__c, Status_Id__c, StatusPosition__c
            FROM Card__c
            ORDER BY StatusPosition__c
        ];

        for (Trello_Status_Setting__mdt status : statusList) {
            statuses.add(String.valueOf(status.Status__c));
        }

        return new KanbanBoard(availableCardList, statuses);
    }

    @AuraEnabled
    public static void getUpdateStatus(Id recordId, String status, Integer position) {
        SObject card = recordId.getSObjectType().newSObject(recordId);
        card.put('Status__c', status);
        card.put('StatusPosition__c', position);

        update card;
    }

    public class KanbanBoard {
        @AuraEnabled
        public List<Card__c> cardList { get; set; }
        @AuraEnabled
        public List<String> statusList { get; set; }

        public KanbanBoard (List<Card__c> cards, List<String> statuses) {
            this.cardList = cards;
            this.statusList = statuses;
        }
    }
}
