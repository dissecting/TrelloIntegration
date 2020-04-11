public with sharing class TrelloSyncController {

    private static List<Object> sendGetRequest(String primaryParameter, String primaryValue, String secondaryParameter, String objectName) {
        List<Object> objectList = new List<Object>();
        String endPoint = 'https://api.trello.com/1/{0}/{1}/{2}?key={3}&token={4}';
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

    public static TrelloBoard getBoard() {
        TrelloBoard newBoard = new TrelloBoard();
        List<TrelloBoard> boardList = new List<TrelloBoard>();
        String primaryParameter = 'members';
        String secondaryParameter = 'boards';
        String objectName = 'TrelloBoard';
        String userName = TrelloSyncController.getTrelloSettings().get('userName');
        String boardUrl = TrelloSyncController.getTrelloSettings().get('boardUrl');
        String boardName = TrelloSyncController.getTrelloSettings().get('boardName');

        boardList = (List<TrelloBoard>) TrelloSyncController.sendGetRequest(
            primaryParameter,
            userName,
            secondaryParameter,
            objectName
        );

        for (TrelloBoard currentBoard : boardList) {
            if (currentBoard.url == boardUrl && currentBoard.name == boardName) {
                newBoard.id = currentBoard.id;
                newBoard.name = currentBoard.name;
                newBoard.url = currentBoard.url;
            }
        }

        return newBoard;
    }

    public static List<TrelloColumn> getColumns() {
        String boardId = TrelloSyncController.getBoard().id;
        String primaryParameter = 'boards';
        String secondaryParameter = 'lists';
        String objectName = 'TrelloColumn';

        return (List<TrelloColumn>) TrelloSyncController.sendGetRequest(
            primaryParameter,
            boardId,
            secondaryParameter,
            objectName
        );
    }

    public static UsersWithColumns getUsersWithColumns() {
        UsersWithColumns usersWithColumns = new UsersWithColumns();
        List<TrelloUser> userList = new List<TrelloUser>();
        List<TrelloColumn> columnList = TrelloSyncController.getColumns();
        String primaryParameter = 'boards';
        String secondaryParameter = 'members';
        String objectName = 'TrelloUser';
        String boardId;

        if (!columnList.isEmpty()) {
            boardId = columnList[0].idBoard;
        }

        userList = (List<TrelloUser>) TrelloSyncController.sendGetRequest(
            primaryParameter,
            boardId,
            secondaryParameter,
            objectName
        );
        usersWithColumns.trelloUserList = userList;
        usersWithColumns.trelloColumnList = columnList;

        return usersWithColumns;
    }

    public static List<TrelloCard> getCards() {
        UsersWithColumns usersWithColumns = TrelloSyncController.getUsersWithColumns();
        Map<String, String> columnNameByIdMap = new Map<String, String>();
        Map<String, String> userNameByIdMap = new Map<String, String>();
        List<TrelloCard> cardList = new List<TrelloCard>();
        String primaryParameter = 'boards';
        String secondaryParameter = 'cards';
        String objectName = 'TrelloCard';
        String boardId;

        if (!usersWithColumns.trelloColumnList.isEmpty()) {
            boardId = usersWithColumns.trelloColumnList[0].idBoard;
        }

        cardList = (List<TrelloCard>) TrelloSyncController.sendGetRequest(
            primaryParameter,
            boardId,
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

            for (TrelloCard currentCard : cardList) {
                currentCard.columnName = columnNameByIdMap.get(currentCard.idList);
                currentCard.userNames = new List<String>();

                for (String userId : currentCard.idMembers) {
                    currentCard.userNames.add(userNameByIdMap.get(userId));
                }
            }
        }

        return cardList;
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

    public class TrelloBoard {
        public String id;
        public String name;
        public String url;
    }

    public class TrelloColumn {
        public String id;
        public String name;
        public String idBoard;
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
        public String due;
        public String idList;
        public List<String> idMembers;
        public String columnName;
        public List<String> userNames;
    }
}