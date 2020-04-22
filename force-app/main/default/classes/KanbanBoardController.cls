public with sharing class KanbanBoardController {

    @AuraEnabled
    public static KanbanBoard getKanbanBoard() {
        List<Trello_Status_Setting__mdt> statusList = TrelloStatusSetting.getTrelloStatusSetting();
        List<String> statuses = new List<String>();
        List<Card__c> availableCardList = [
            SELECT Name, Description__c, Assignee__c, Due_Date__c,
                Status__c, Card_Position__c, Card_Id__c
            FROM Card__c
            ORDER BY Card_Position__c, LastModifiedDate
        ];

        TrelloSettings__c trelloSettings = TrelloSettings__c.getInstance();
        Datetime syncDateTime;

        if (trelloSettings.Sync_Date__c != null) {
            syncDateTime = trelloSettings.Sync_Date__c;
        }

        for (Trello_Status_Setting__mdt status : statusList) {
            statuses.add(status.Status__c);
        }

        return new KanbanBoard(availableCardList, statuses, syncDateTime.format('MM.dd.yyyy HH:mm:ss'));
    }

    @AuraEnabled
    public static void getUpdateStatus(String status, List<String> cardIds) {
        List<Card__c> cardList = new List<Card__c>();

        for (Integer i = 0; i < cardIds.size(); i++) {
            Card__c card = new Card__c(
                Id = cardIds[i],
                Status__c = status,
                Card_Position__c = String.valueOf(i)
            );

            cardList.add(card);
        }

        try {
            update cardList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void getSync() {
        try {
            TrelloSyncController.syncCards();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class KanbanBoard {
        @AuraEnabled
        public List<Card__c> cardList { get; private set; }
        @AuraEnabled
        public List<String> statusList { get; private set; }
        @AuraEnabled
        public String syncDate { get; private set; }

        public KanbanBoard (List<Card__c> cards, List<String> statuses, String dateValue) {
            this.cardList = cards;
            this.statusList = statuses;
            this.syncDate = dateValue;
        }
    }
}