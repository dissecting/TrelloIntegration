@isTest
private class KanbanBoardControllerTest {

    @testSetup
    private static void setupTestData() {

        TrelloSettings__c trelloSettings = new TrelloSettings__c(
            Api_key__c = 'testApiKey',
            Board_Name__c = 'testBoardName',
            Board_URL__c = 'https://test.com/testBoardName',
            Token__c = 'testToken',
            User_Name__c = 'TestUser'
        );

        insert trelloSettings;

        Card__c newCard = new Card__c(
            Card_Id__c = 'cardId',
            Name = 'cardName',
            Description__c = 'cardDescription',
            Assignee__c = 'TestUser',
            Status__c = 'TO DO',
            StatusPosition__c = 0,
            Card_Position__c = '00'
        );

        insert newCard;

        System.assertNotEquals(null, trelloSettings.Id, 'Record is not created');
        System.assertNotEquals(null, newCard.Id, 'Record is not created');
    }

    @isTest
    private static void testGetTrelloCards() {

        Test.setMock(HttpCalloutMock.class, new TrelloSyncCalloutMock());
        Test.startTest();

        KanbanBoardController.getSync();

        Test.stopTest();

        TrelloSettings__c trelloSettings = TrelloSettings__c.getOrgDefaults();

        System.assertEquals(System.now(), trelloSettings.Sync_Date__c, 'Sync failed');
    }

    @isTest
    private static void testGetKanbanBoard() {

        Test.startTest();

        KanbanBoardController.KanbanBoard kanbanBoard = KanbanBoardController.getKanbanBoard();

        Test.stopTest();

        List<Card__c> actualCardList = [
            SELECT Name, Description__c, Assignee__c, Status__c, StatusPosition__c, Card_Position__c, Card_Id__c
            FROM Card__c
        ];

        System.assertEquals(kanbanBoard.cardList, actualCardList, 'Kanban Board data is not received');
    }

    @isTest
    private static void testUpdateStatus() {
        String status = 'UAT';
        Integer statusPosition = 2;
        List<Card__c> cardList = [
            SELECT Id
            FROM Card__c
        ];

        String cardId = cardList[0].Id;

        Test.startTest();

        KanbanBoardController.getUpdateStatus(status, statusPosition, cardId);

        Test.stopTest();

        List<Card__c> actualCardList = [
            SELECT Status__c, StatusPosition__c, Card_Position__c
            FROM Card__c
            WHERE Status__c = :status
                AND StatusPosition__c = :statusPosition
                AND Id = :cardId
        ];

        System.assertEquals(false, actualCardList.isEmpty(), 'Card data is not updated');
    }
}
