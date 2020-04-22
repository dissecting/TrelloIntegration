@isTest
private class TrelloSyncSchTest {

    @testSetup
    private static void setupTestData() {
        TrelloSettings__c trelloSettings = new TrelloSettings__c(
            Api_key__c = 'testApiKey',
            Board_Name__c = 'testBoardName',
            Board_URL__c = 'https://test.com/testBoardName',
            Token__c = 'testToken',
            User_Name__c = 'TestUser',
            Trello_Sync_Endpoint__c = 'https://api.trello.com/1/{0}/{1}/{2}?key={3}&token={4}'
        );

        insert trelloSettings;

        System.assertNotEquals(null, trelloSettings.Id, 'Record is not created');
    }

    @isTest
    private static void testSetSyncSchedulable() {
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

        String CRON_EXP = '0 0 0 3 1 ? 2025';
        String jobId = System.schedule('SyncTest', CRON_EXP, new TrelloSyncSch());

        Test.stopTest();

        CronTrigger cronTrigger = [
            SELECT CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(0, cronTrigger.TimesTriggered);
        System.assertEquals('2025-01-03 00:00:00', String.valueOf(cronTrigger.NextFireTime));
    }
}