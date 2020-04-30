@isTest
private class TrelloSyncControllerTest {

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

        System.assertNotEquals(null, newTrelloSettings.Id, 'Record is not created');
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

        TrelloSyncController.syncCards();

        Test.stopTest();

        Card__c card = [
            SELECT Id
            FROM Card__c
            LIMIT 1
        ];

        TrelloSettings__c updatedTrelloSettings = TrelloSettings__c.getInstance();

        System.assertNotEquals(null, card.id, 'Card is not created');
        System.assertEquals(
            System.now().format('MM/dd/yyyy HH:mm'),
            updatedTrelloSettings.Sync_Date__c.format('MM/dd/yyyy HH:mm'),
            'Sync Date is not updated'
        );
    }

    @isTest
    private static void testIncorrectRequest() {
        TrelloSettings__c trelloSettings = TrelloSettings__c.getInstance();
        List<String> endPointList = new List<String> {
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'test1',
                'test2',
                'test3',
                'test4',
                'test5'
            }),
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'test1',
                'test2',
                'test3',
                'test4',
                'test5'
            }),
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'test1',
                'test2',
                'test3',
                'test4',
                'test5'
            }),
            String.format(trelloSettings.Trello_Sync_Endpoint__c, new List<String> {
                'test1',
                'test2',
                'test3',
                'test4',
                'test5'
            })
        };

        Test.setMock(HttpCalloutMock.class, new TrelloSyncCalloutMock(endPointList));
        Test.startTest();

        try {
            TrelloSyncController.syncCards();
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }
}