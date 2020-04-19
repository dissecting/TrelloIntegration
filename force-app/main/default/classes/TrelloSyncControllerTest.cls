@isTest
private class TrelloSyncControllerTest {

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

        System.assertNotEquals(null, trelloSettings.Id, 'Record is not created');
    }

    @isTest
    private static void testGetTrelloCards() {

        Test.setMock(HttpCalloutMock.class, new TrelloSyncCalloutMock());
        Test.startTest();

        TrelloSyncController.syncCards();

        Test.stopTest();

        Card__c card = [
            SELECT Id
            FROM Card__c
            LIMIT 1
        ];

        TrelloSettings__c trelloSettings = TrelloSettings__c.getOrgDefaults();

        System.assertNotEquals(null, card.id, 'Card is not created');
        System.assertEquals(System.now(), trelloSettings.Sync_Date__c, 'Sync Date is not updated');
    }
}
