@isTest
private class KanbanBoardControllerTest {

    @testSetup
    private static void setupTestData() {
        TrelloSettings__c newTrelloSettings = new TrelloSettings__c(
            Api_key__c = 'testApiKey',
            Board_Name__c = 'testBoardName',
            Board_URL__c = 'https://test.com/testBoardName',
            Token__c = 'testToken',
            User_Name__c = 'TestUser'
        );

        insert newTrelloSettings;

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

        System.assertNotEquals(null, newTrelloSettings.Id, 'Record is not created');
        System.assertNotEquals(null, newCard.Id, 'Record is not created');
    }

    @isTest
    private static void testGetTrelloCards() {

        String endPoint = Label.Trello_Sync_Endpoint;
        TrelloSettings__c trelloSettings = TrelloSettings__c.getOrgDefaults();
        List<String> endPointList = new List<String> {
            String.format(endPoint, new List<String> {
                'members',
                trelloSettings.User_Name__c,
                'boards',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            }),
            String.format(endPoint, new List<String> {
                'boards',
                'boardId',
                'lists',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            }),
            String.format(endPoint, new List<String> {
                'boards',
                'boardId',
                'members',
                trelloSettings.Api_key__c,
                trelloSettings.Token__c
            }),
            String.format(endPoint, new List<String> {
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

        TrelloSettings__c updatedTrelloSettings = TrelloSettings__c.getOrgDefaults();

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
