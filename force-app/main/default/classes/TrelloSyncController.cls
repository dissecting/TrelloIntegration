public with sharing class TrelloSyncController {

    private static List<Object> sendGetRequest(String primaryParameter, String primaryValue, String secondaryParameter, String objectName) {
        List<Object> objectList = new List<Object>();
        Map<String, String> trelloSettingsMap = TrelloSyncController.getTrelloSettings();
        String endPoint = trelloSettingsMap.get('trelloSyncEndpoint');
        String apiKey = trelloSettingsMap.get('apiKey');
        String tokenValue = trelloSettingsMap.get('tokenValue');
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        try {
            request.setEndpoint(String.format(endPoint, new List<String> {
                primaryParameter,
                primaryValue,
                secondaryParameter,
                apiKey,
                tokenValue
            }));
        } catch (Exception e) {
            throw new IncorrectEndpointException('Endpoint has incorrect format');
        }
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            switch on objectName {
                when 'TrelloBoard' {
                    objectList = (List<Object>) JSON.deserialize(response.getBody(), List<TrelloBoard>.class);
                }
                when 'TrelloColumn' {
                    objectList = (List<Object>) JSON.deserialize(response.getBody(), List<TrelloColumn>.class);
                }
                when 'TrelloUser' {
                    objectList = (List<Object>) JSON.deserialize(response.getBody(), List<TrelloUser>.class);
                }
                when 'TrelloCard' {
                    objectList = (List<Object>) JSON.deserialize(
                        response.getBody().replaceAll('"desc":', '"descValue":'),
                        List<TrelloCard>.class
                    );
                }
                when else {
                    return objectList;
                }
            }
        } else if (response.getStatusCode() != 200) {
            throw new IncorrectStatusCodeException('Page is Not Found');
        }

        return objectList;
    }

    private static TrelloBoard getBoard() {
        TrelloBoard newBoard = new TrelloBoard();
        Map<String, String> trelloSettingsMap = TrelloSyncController.getTrelloSettings();
        String primaryParameter = 'members';
        String secondaryParameter = 'boards';
        String objectName = 'TrelloBoard';
        String userName = trelloSettingsMap.get('userName');
        String boardUrl = trelloSettingsMap.get('boardUrl');
        String boardName = trelloSettingsMap.get('boardName');

        List<TrelloBoard> boardList = (List<TrelloBoard>) TrelloSyncController.sendGetRequest(
            primaryParameter,
            userName,
            secondaryParameter,
            objectName
        );

        if (!boardList.isEmpty()) {
            for (TrelloBoard currentBoard : boardList) {
                if (currentBoard.url == boardUrl && currentBoard.name == boardName) {
                    newBoard.id = currentBoard.id;
                    newBoard.name = currentBoard.name;
                    newBoard.url = currentBoard.url;
                }
            }
        }

        return newBoard;
    }

    private static List<TrelloColumn> getColumns() {
        List<TrelloColumn> columnList = new List<TrelloColumn>();
        TrelloBoard trelloBoard = TrelloSyncController.getBoard();
        String primaryParameter = 'boards';
        String secondaryParameter = 'lists';
        String objectName = 'TrelloColumn';

        if (trelloBoard.id != null) {
            columnList = (List<TrelloColumn>) TrelloSyncController.sendGetRequest(
                primaryParameter,
                trelloBoard.id,
                secondaryParameter,
                objectName
            );
        }

        return columnList;
    }

    private static UsersWithColumns getUsersWithColumns() {
        UsersWithColumns usersWithColumns = new UsersWithColumns();
        List<TrelloUser> userList = new List<TrelloUser>();
        List<TrelloColumn> columnList = TrelloSyncController.getColumns();
        String primaryParameter = 'boards';
        String secondaryParameter = 'members';
        String objectName = 'TrelloUser';

        if (!columnList.isEmpty()) {
            userList = (List<TrelloUser>) TrelloSyncController.sendGetRequest(
                primaryParameter,
                columnList[0].idBoard,
                secondaryParameter,
                objectName
            );
        }

        usersWithColumns.trelloUserList = userList;
        usersWithColumns.trelloColumnList = columnList;

        return usersWithColumns;
    }

    private static List<Card__c> getCards(Set<String> cardIds) {
        UsersWithColumns usersWithColumns = TrelloSyncController.getUsersWithColumns();

        Map<String, String> columnNameByIdMap = new Map<String, String>();
        Map<String, String> userNameByIdMap = new Map<String, String>();

        List<TrelloCard> cardList = new List<TrelloCard>();
        List<Card__c> cardNewList = new List<Card__c>();

        String primaryParameter = 'boards';
        String secondaryParameter = 'cards';
        String objectName = 'TrelloCard';

        Integer cardPosition = 0;

        if (!usersWithColumns.trelloColumnList.isEmpty()) {
            cardList = (List<TrelloCard>) TrelloSyncController.sendGetRequest(
                primaryParameter,
                usersWithColumns.trelloColumnList[0].idBoard,
                secondaryParameter,
                objectName
            );

            if (!cardList.isEmpty()) {
                for (TrelloColumn currentColumn : usersWithColumns.trelloColumnList) {
                    columnNameByIdMap.put(currentColumn.id, currentColumn.name);
                }

                for (TrelloUser currentUser : usersWithColumns.trelloUserList) {
                    userNameByIdMap.put(currentUser.id, currentUser.username);
                }

                for (Integer i = 0; i < cardList.size(); i++) {
                    cardList[i].columnName = columnNameByIdMap.get(cardList[i].idList);
                    cardList[i].userNames = new List<String>();

                    for (String userId : cardList[i].idMembers) {
                        cardList[i].userNames.add(userNameByIdMap.get(userId));
                    }

                    if (i != 0 && (cardList[i].idList != cardList[i-1].idList)) {
                        cardPosition = 0;
                    }

                    if (!cardIds.contains(cardList[i].id)) {
                        Card__c newCard = new Card__c(
                            Card_Id__c = cardList[i].id,
                            Name = cardList[i].name,
                            Description__c = cardList[i].descValue,
                            Assignee__c = String.join(cardList[i].userNames, ', '),
                            Due_Date__c = cardList[i].due,
                            Status__c = cardList[i].columnName,
                            Card_Position__c = String.valueOf(cardPosition)
                        );

                        cardNewList.add(newCard);
                    }

                    cardPosition++;
                }
            }
        }

        return cardNewList;
    }

    public static void syncCards() {
        List<Card__c> availableCardList = [
            SELECT Card_Id__c
            FROM Card__c
            WHERE Card_Id__c != null
        ];

        Set<String> cardIds = new Set<String>();

        for (Card__c currentCard : availableCardList) {
            cardIds.add(currentCard.Card_Id__c);
        }

        List<Card__c> trelloCardList = TrelloSyncController.getCards(cardIds);

        insert trelloCardList;

        TrelloSyncController.updateSyncDate();
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
            && trelloSettings.Trello_Sync_Endpoint__c != null
        );

        if (isTrelloSettings) {
            trelloSettingsMap.put('apiKey', trelloSettings.Api_key__c);
            trelloSettingsMap.put('boardName', trelloSettings.Board_Name__c);
            trelloSettingsMap.put('boardUrl', trelloSettings.Board_URL__c);
            trelloSettingsMap.put('tokenValue', trelloSettings.Token__c);
            trelloSettingsMap.put('userName', trelloSettings.User_Name__c);
            trelloSettingsMap.put('trelloSyncEndpoint', trelloSettings.Trello_Sync_Endpoint__c);
        } else {
            throw new NoSettingsException('No Settings');
        }

        return trelloSettingsMap;
    }

    private static void updateSyncDate() {
        TrelloSettings__c trelloSettings = TrelloSettings__c.getInstance();

        if (trelloSettings != null) {
            Id settingsId = [
                SELECT Id
                FROM TrelloSettings__c
                WHERE Board_Name__c = :trelloSettings.Board_Name__c
                LIMIT 1
            ].Id;

            trelloSettings.Id = settingsId;
            trelloSettings.Sync_Date__c = System.now();

            update trelloSettings;
        }
    }

    private class TrelloBoard {
        private String id;
        private String name;
        private String url;
    }

    private class TrelloColumn {
        private String id;
        private String name;
        private String idBoard;
    }

    private class TrelloUser {
        private String id;
        private String username;
    }

    private class UsersWithColumns {
        private List<TrelloUser> trelloUserList;
        private List<TrelloColumn> trelloColumnList;
    }

    private class TrelloCard {
        private String id;
        private String name;
        private String descValue;
        private Datetime due;
        private String idList;
        private List<String> idMembers;
        private String columnName;
        private List<String> userNames;
    }

    private class IncorrectStatusCodeException extends Exception {}

    private class NoSettingsException extends Exception {}

    private class IncorrectEndpointException extends Exception {}
}