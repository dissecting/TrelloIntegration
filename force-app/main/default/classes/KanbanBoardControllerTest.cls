@isTest
private class KanbanBoardControllerTest {

    @testSetup
    private static void setupTestData() {
        TrelloSettings__c newTrelloSettings = new TrelloSettings__c(
            Api_key__c = 'testApiKey',
            Board_Name__c = 'testBoardName',
            Board_URL__c = 'https://test.com/testBoardName',
            Token__c = 'testToken',
            User_Name__c = 'TestUser',
            Trello_Sync_Endpoint__c = 'https://api.trello.com/1/{0}/{1}/{2}?key={3}&token={4}'
        );

        insert newTrelloSettings;

        Card__c newCard = new Card__c(
            Card_Id__c = 'cardId',
            Name = 'cardName',
            Description__c = 'cardDescription',
            Assignee__c = 'TestUser',
            Status__c = 'TO DO',
            Card_Position__c = '0'
        );

        insert newCard;

        System.assertNotEquals(null, newTrelloSettings.Id, 'Record is not created');
        System.assertNotEquals(null, newCard.Id, 'Record is not created');
    }

    @isTest
    private static void testGetTrelloCards() {

        TrelloSettings__c trelloSettings = TrelloSettings__c.getInstance();
        List<String> endPointList = new List<String> {
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'members',
                trelloSettings.User_Name__c,
                'boards',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            }),
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'boards',
                'boardId',
                'lists',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            }),
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'boards',
                'boardId',
                'members',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            }),
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'boards',
                'boardId',
                'cards',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            })
        };

        Test.setMock(HttpCalloutMock.class, new TrelloSyncCalloutMock(endPointList));
        Test.startTest();

        KanbanBoardController.getSync();

        Test.stopTest();

        TrelloSettings__c updatedTrelloSettings = TrelloSettings__c.getInstance();

        System.assertEquals(
            System.now().format('MM/dd/yyyy HH:mm'),
            updatedTrelloSettings.Sync_Date__c.format('MM/dd/yyyy HH:mm'),
            'Sync failed'
        );
    }

    @isTest
    private static void testGetKanbanBoard() {

        Test.startTest();

        KanbanBoardController.KanbanBoard kanbanBoard = KanbanBoardController.getKanbanBoard();

        Test.stopTest();

        List<Card__c> actualCardList = [
            SELECT Name, Description__c, Assignee__c, Status__c, Card_Position__c, Card_Id__c
            FROM Card__c
        ];

        System.assertEquals(kanbanBoard.cardList, actualCardList, 'Kanban Board data is not received');
    }

    @isTest
    private static void testUpdateStatus() {
        String status = 'UAT';
        List<Card__c> cardList = [
            SELECT Id
            FROM Card__c
        ];

        List<String> cardIds = new List<String>(new Map<String, Card__c>(cardList).keySet());

        Test.startTest();

        KanbanBoardController.getUpdateStatus(status, cardIds);

        Test.stopTest();

        List<Card__c> actualCardList = [
            SELECT Status__c, Card_Position__c
            FROM Card__c
            WHERE Status__c = :status
                AND Id IN :cardIds
        ];

        System.assertEquals(false, actualCardList.isEmpty(), 'Card data is not updated');
    }
}