public with sharing class TrelloSyncController {

    private static List<Object> sendGetRequest(String primaryParameter, String primaryValue, String secondaryParameter, String objectName) {
        List<Object> objectList = new List<Object>();
        String endPoint = TrelloSyncController.getTrelloSettings().get('trelloSyncEndpoint');
        String apiKey = TrelloSyncController.getTrelloSettings().get('apiKey');
        String tokenValue = TrelloSyncController.getTrelloSettings().get('tokenValue');
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(String.format(endPoint, new List<String> {
            primaryParameter,
            primaryValue,
            secondaryParameter,
            apiKey,
            tokenValue
        }));
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
        }

        return objectList;
    }

    private static TrelloBoard getBoard() {
        TrelloBoard newBoard = new TrelloBoard();
        List<Object> boardList = new List<Object>();
        String primaryParameter = 'members';
        String secondaryParameter = 'boards';
        String objectName = 'TrelloBoard';
        String userName = TrelloSyncController.getTrelloSettings().get('userName');
        String boardUrl = TrelloSyncController.getTrelloSettings().get('boardUrl');
        String boardName = TrelloSyncController.getTrelloSettings().get('boardName');

        boardList = TrelloSyncController.sendGetRequest(
            primaryParameter,
            userName,
            secondaryParameter,
            objectName
        );

        if (!boardList.isEmpty()) {
            for (TrelloBoard currentBoard : (List<TrelloBoard>) boardList) {
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
        Integer columnPosition = 0;

        if (trelloBoard.id != null) {
            columnList = (List<TrelloColumn>) TrelloSyncController.sendGetRequest(
                primaryParameter,
                trelloBoard.id,
                secondaryParameter,
                objectName
            );

            for (TrelloColumn currentColumn : columnList) {
                currentColumn.columnPosition = columnPosition;
                columnPosition++;
            }
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
        Map<String, Integer> columnPositionByIdMap = new Map<String, Integer>();
        Map<Integer, String> statusNameByPositionMap = new Map<Integer, String>();
        Map<String, Integer> statusPositionByNameMap = new Map<String, Integer>();
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
                List<Trello_Status_Setting__mdt> statusList = TrelloStatusSetting.getTrelloStatusSetting();

                for (Trello_Status_Setting__mdt statusSetting : statusList) {
                    statusNameByPositionMap.put((Integer) statusSetting.Position__c, statusSetting.Status__c);
                    statusPositionByNameMap.put(statusSetting.Status__c, (Integer) statusSetting.Position__c);
                }

                for (TrelloColumn currentColumn : usersWithColumns.trelloColumnList) {
                    columnNameByIdMap.put(currentColumn.id, currentColumn.name);
                    columnPositionByIdMap.put(currentColumn.id, currentColumn.columnPosition);
                }

                for (TrelloUser currentUser : usersWithColumns.trelloUserList) {
                    userNameByIdMap.put(currentUser.id, currentUser.username);
                }

                for (Integer i = 0; i < cardList.size(); i++) {
                    if (!statusNameByPositionMap.isEmpty()) {
                        Boolean isEqualPositions = (
                            statusNameByPositionMap.get(columnPositionByIdMap.get(cardList[i].idList)) ==
                            columnNameByIdMap.get(cardList[i].idList)
                        );

                        if (isEqualPositions) {
                            cardList[i].columnPosition = columnPositionByIdMap.get(cardList[i].idList);
                        } else {
                            cardList[i].columnPosition = statusPositionByNameMap.get(
                                columnNameByIdMap.get(cardList[i].idList)
                            );
                        }

                    } else {
                        cardList[i].columnPosition = columnPositionByIdMap.get(cardList[i].idList);
                    }

                    cardList[i].columnName = columnNameByIdMap.get(cardList[i].idList);
                    cardList[i].userNames = new List<String>();

                    for (String userId : cardList[i].idMembers) {
                        cardList[i].userNames.add(userNameByIdMap.get(userId));
                    }

                    if (i != 0 && (cardList[i].columnPosition != cardList[i-1].columnPosition)) {
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

    public class TrelloBoard {
        public String id;
        public String name;
        public String url;
    }

    public class TrelloColumn {
        public String id;
        public String name;
        public String idBoard;
        public Integer columnPosition;
    }

    public class TrelloUser {
        public String id;
        public String username;
    }

    public class UsersWithColumns {
        public List<TrelloUser> trelloUserList;
        public List<TrelloColumn> trelloColumnList;
    }

    public class TrelloCard {
        public String id;
        public String name;
        public String descValue;
        public Datetime due;
        public String idList;
        public List<String> idMembers;
        public String columnName;
        public List<String> userNames;
        public Integer columnPosition;
    }
}