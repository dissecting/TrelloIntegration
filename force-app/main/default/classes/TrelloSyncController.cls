public with sharing class TrelloSyncController {
    public static Map<String, List<String>> getBoards() {
        Map<String, List<String>> boardsMap = new Map<String, List<String>>();
        String endPoint = 'https://api.trello.com/1/members/{0}/boards?key={1}&token={2}';
        String apiKey = TrelloSyncController.getTrelloSettings().get('apiKey');
        String tokenValue = TrelloSyncController.getTrelloSettings().get('tokenValue');
        String userName = TrelloSyncController.getTrelloSettings().get('userName');
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
                    String.valueOf(objMap.get('url')),
                    new List<String> { String.valueOf(objMap.get('id')), String.valueOf(objMap.get('name')) }
                );
            }
        }

        return boardsMap;
    }

    public static Map<String, List<String>> getLists() {
        Map<String, List<String>> boardsMap = TrelloSyncController.getBoards();
        Map<String, List<String>> listsMap = new Map<String, List<String>>();
        String endPoint = 'https://api.trello.com/1/boards/{0}/lists?key={1}&token={2}';
        String apiKey = TrelloSyncController.getTrelloSettings().get('apiKey');
        String tokenValue = TrelloSyncController.getTrelloSettings().get('tokenValue');
        String boardUrl = TrelloSyncController.getTrelloSettings().get('boardUrl');
        String boardId = boardsMap.get(boardUrl)[0];
        Integer listPosition = 0;
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(String.format(endPoint, new List<String> { boardId, apiKey, tokenValue }));
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());

            for (Object obj : results) {
                Map<String, Object> objMap = (Map<String, Object>) obj;

                listsMap.put(
                    String.valueOf(listPosition),
                    new List<String> {
                        String.valueOf(objMap.get('id')),
                        String.valueOf(objMap.get('name')),
                        String.valueOf(objMap.get('idBoard'))
                    }
                );
                listPosition++;
            }
        }

        return listsMap;
    }

    public static List<Map<String, List<String>>> getUsers() {
        List<Map<String, List<String>>> userList = new List<Map<String, List<String>>>();
        Map<String, List<String>> listsMap = TrelloSyncController.getLists();
        Map<String, List<String>> usersMap = new Map<String, List<String>>();
        String endPoint = 'https://api.trello.com/1/boards/{0}/members?key={1}&token={2}';
        String apiKey = TrelloSyncController.getTrelloSettings().get('apiKey');
        String tokenValue = TrelloSyncController.getTrelloSettings().get('tokenValue');
        String boardId = listsMap.get('0')[2];
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(String.format(endPoint, new List<String> { boardId, apiKey, tokenValue }));
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());

            for (Object obj : results) {
                Map<String, Object> objMap = (Map<String, Object>) obj;

                usersMap.put(String.valueOf(objMap.get('id')), new List<String> {
                    String.valueOf(objMap.get('username'))
                });
            }

            userList.add(listsMap);
            userList.add(usersMap);
        }

        return userList;
    }

    public static Map<String, List<String>> getCards() {
        List<Map<String, List<String>>> userList = TrelloSyncController.getUsers();
        Map<String, List<String>> listsMap = userList[0];
        Map<String, List<String>> usersMap = userList[1];
        Map<String, List<String>> cardsMap = new Map<String, List<String>>();
        Map<String, List<String>> positionsByIdMap = new Map<String, List<String>>();
        String endPoint = 'https://api.trello.com/1/boards/{0}/cards?key={1}&token={2}';
        String apiKey = TrelloSyncController.getTrelloSettings().get('apiKey');
        String tokenValue = TrelloSyncController.getTrelloSettings().get('tokenValue');
        String boardId = listsMap.get('0')[2];
        Integer cardPosition = 0;
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(String.format(endPoint, new List<String> { boardId, apiKey, tokenValue }));
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());

            for (String listKey : listsMap.keySet()) {
                positionsByIdMap.put(
                    listsMap.get(listKey)[0],
                    new List<String> { String.valueOf(listKey), listsMap.get(listKey)[1]}
                );
            }

            for (Object obj : results) {
                Map<String, Object> objMap = (Map<String, Object>) obj;
                String idList = String.valueOf(objMap.get('idList'));
                List<Object> idMemberList = (List<Object>) objMap.get('idMembers');
                List<String> userNameList = new List<String>();

                for (Object idUser : idMemberList) {
                    userNameList.add(usersMap.get(String.valueOf(idUser))[0]);
                }

                cardsMap.put(
                    positionsByIdMap.get(idList)[0] + '-' + String.valueOf(cardPosition),
                    new List<String> {
                        String.valueOf(objMap.get('name')),
                        String.valueOf(objMap.get('desc')),
                        String.valueOf(objMap.get('due')),
                        String.valueOf((Object) userNameList),
                        positionsByIdMap.get(idList)[1]
                    }
                );

                cardPosition++;
            }
        }

        return cardsMap;
    }

    private static Map<String, String> getTrelloSettings() {
        Map<String, String> trelloSettingsMap = new Map<String, String>();
        TrelloSettings__c trelloSettings = TrelloSettings__c.getInstance();
        Boolean isTrelloSettings = (trelloSettings != null
            && trelloSettings.Api_key__c != null
            && trelloSettings.Board_Name__c != null
            && trelloSettings.Board_URL__c != null
            && trelloSettings.Token__c != null
            && trelloSettings.User_Name__c != null
        );

        if (isTrelloSettings) {
            trelloSettingsMap.put('apiKey', trelloSettings.Api_key__c);
            trelloSettingsMap.put('boardName', trelloSettings.Board_Name__c);
            trelloSettingsMap.put('boardUrl', trelloSettings.Board_URL__c);
            trelloSettingsMap.put('tokenValue', trelloSettings.Token__c);
            trelloSettingsMap.put('userName', trelloSettings.User_Name__c);
        }

        return trelloSettingsMap;
    }
}