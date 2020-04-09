public with sharing class TrelloSyncController {
    public static Map<String, List<String>> getBoards() {
        Map<String, List<String>> boardsMap = new Map<String, List<String>>();
        String endPoint = 'https://api.trello.com/1/members/{0}/boards/?key={1}&token={2}';
        String apiKey;
        String boardName;
        String boardUrl;
        String tokenValue;
        String userName;
        TrelloSettings__c trelloSettings = TrelloSettings__c.getInstance();
        Boolean isTrelloSettings = (trelloSettings != null
            && trelloSettings.Api_key__c != null
            && trelloSettings.Board_Name__c != null
            && trelloSettings.Board_URL__c != null
            && trelloSettings.Token__c != null
            && trelloSettings.User_Name__c != null
        );

        if (isTrelloSettings) {
            apiKey = trelloSettings.Api_key__c;
            boardName = trelloSettings.Board_Name__c;
            boardUrl = trelloSettings.Board_URL__c;
            tokenValue = trelloSettings.Token__c;
            userName = trelloSettings.User_Name__c;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(String.format(endPoint, new List<String> { userName, apiKey, tokenValue }));
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());

            for (Object obj : results) {
                Map<String, Object> objMap = (Map<String, Object>) obj;

                boardsMap.put(
                    String.valueOf(objMap.get('id')),
                    new List<String> { String.valueOf(objMap.get('name')), String.valueOf(objMap.get('url')) }
                );
            }
        }

        System.debug(LoggingLevel.INFO, '*** boardsMap ' + boardsMap);

        return boardsMap;
    }
}