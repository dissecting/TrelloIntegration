public with sharing class TrelloStatusSetting {

    public static List<Trello_Status_Setting__mdt> getTrelloStatusSetting() {
        List<Trello_Status_Setting__mdt> trelloStatusSettingList = new List<Trello_Status_Setting__mdt>();

        if (!Test.isRunningTest()) {
            trelloStatusSettingList = [
                SELECT Position__c, Status__c
                FROM Trello_Status_Setting__mdt
                ORDER BY Position__c
            ];
        } else {
            trelloStatusSettingList = new List<Trello_Status_Setting__mdt> {
                new Trello_Status_Setting__mdt(
                    Status__c = 'TO DO',
                    Position__c = 0
                ),
                new Trello_Status_Setting__mdt(
                    Status__c = 'In Progress',
                    Position__c = 1
                ),
                new Trello_Status_Setting__mdt(
                    Status__c = 'UAT',
                    Position__c = 2
                ),
                new Trello_Status_Setting__mdt(
                    Status__c = 'Done',
                    Position__c = 3
                )
            };
        }

        return trelloStatusSettingList;
    }
}