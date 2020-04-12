public with sharing class KanbanBoardController {

    @AuraEnabled
    public static KanbanBoard getKanbanBoard() {
        TrelloSyncController.syncCards();

        Set<String> statuses = new Set<String>();
        List<Integer> statusPosition = new List<Integer>();
        List<Card__c> availableCardList = [
            SELECT Name, Description__c, Assignee__c, Due_Date__c, Status__c, Status_Id__c, StatusPosition__c
            FROM Card__c
            ORDER BY StatusPosition__c
        ];

        for (Card__c card : availableCardList) {
            statuses.add(card.Status__c);
            statusPosition.add((Integer) card.StatusPosition__c);
        }

        return new KanbanBoard(availableCardList, new List<String>(statuses), statusPosition);
    }

    @AuraEnabled
    public static String getUpdateStatus(Id recordId, String status, Integer position) {
        SObject card = recordId.getSObjectType().newSObject(recordId);
        card.put('Status__c', status);
        card.put('StatusPosition__c', position);

        update card;

        return 'Success';
    }

    public class KanbanBoard {
        @AuraEnabled
        public List<Card__c> cardList { get; set; }
        @AuraEnabled
        public List<String> statusList { get; set; }
        @AuraEnabled
        public List<Integer> statusPosition { get; set; }

        public KanbanBoard (List<Card__c> cards, List<String> statuses, List<Integer> positions) {
            this.cardList = cards;
            this.statusList = statuses;
            this.statusPosition = positions;
        }
    }
}
