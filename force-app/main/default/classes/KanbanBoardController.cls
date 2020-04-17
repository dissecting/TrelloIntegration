public with sharing class KanbanBoardController {

    @AuraEnabled
    public static KanbanBoard getKanbanBoard() {
        List<Trello_Status_Setting__mdt> statusList = [
            SELECT Position__c, Status__c
            FROM Trello_Status_Setting__mdt
            ORDER BY Position__c
        ];

        List<String> statuses = new List<String>();
        List<Card__c> availableCardList = [
            SELECT Name, Description__c, Assignee__c, Due_Date__c,
                Status__c, StatusPosition__c, Card_Position__c
            FROM Card__c
            ORDER BY StatusPosition__c, Card_Position__c, LastModifiedDate
        ];

        TrelloSettings__c trelloSettings = TrelloSettings__c.getOrgDefaults();
        Datetime syncDateTime;

        if (trelloSettings.Sync_Date__c != null) {
            syncDateTime = trelloSettings.Sync_Date__c;
        }

        for (Trello_Status_Setting__mdt status : statusList) {
            statuses.add(String.valueOf(status.Status__c));
        }

        return new KanbanBoard(availableCardList, statuses, String.valueOf(syncDateTime));
    }

    @AuraEnabled
    public static void getUpdateStatus(String status, Integer statusPosition, String cardIds) {
        List<Id> cardIdList = cardIds.split(',');
        List<Card__c> cardList = new List<Card__c>();

        for (Integer i = 0; i < cardIdList.size(); i++) {
            Card__c card = new Card__c(
                Id = cardIdList[i],
                Status__c = status,
                StatusPosition__c = statusPosition,
                Card_Position__c = String.valueOf(statusPosition) + String.valueOf(i)
            );

            cardList.add(card);
        }

        update cardList;
    }

    @AuraEnabled
    public static void getSync() {
        TrelloSyncController.syncCards();
    }

    public class KanbanBoard {
        @AuraEnabled
        public List<Card__c> cardList { get; set; }
        @AuraEnabled
        public List<String> statusList { get; set; }
        @AuraEnabled
        public String syncDate { get; set; }

        public KanbanBoard (List<Card__c> cards, List<String> statuses, String dateValue) {
            this.cardList = cards;
            this.statusList = statuses;
            this.syncDate = dateValue;
        }
    }
}
