@isTest
private class TrelloSyncSchTest {

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
    private static void testSetSyncSchedulable() {

        Test.setMock(HttpCalloutMock.class, new TrelloSyncCalloutMock());
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