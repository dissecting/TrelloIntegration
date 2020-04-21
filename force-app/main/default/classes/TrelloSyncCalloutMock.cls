public with sharing class TrelloSyncCalloutMock implements HttpCalloutMock {

    private String endPointBoard;
    private String endPointColumn;
    private String endPointUser;
    private String endPointCard;

    public TrelloSyncCalloutMock(List<String> endPointList) {
        this.endPointBoard = endPointList[0];
        this.endPointColumn = endPointList[1];
        this.endPointUser = endPointList[2];
        this.endPointCard = endPointList[3];
    }

    public HttpResponse respond(HttpRequest request) {
        String endPoint = request.getEndpoint();
        HttpResponse response = new HttpResponse();

        response.setStatus('OK');
        response.setStatusCode(200);

        if (endPoint == endPointBoard) {
            response.setBody(
                '[{"name":"testBoardName","id":"boardId","url":"https://test.com/testBoardName"}]'
            );
        } else if (endPoint == endPointColumn) {
            response.setBody(
                '[{"id":"idList1","name":"TO DO","idBoard":"boardId"},'
                + '{"id":"idList2","name":"In Progress","idBoard":"boardId"},'
                + '{"id":"idList3","name":"UAT","idBoard":"boardId"},'
                + '{"id":"idList4","name":"Done","idBoard":"boardId"}]'
            );
        } else if (endPoint == endPointUser) {
            response.setBody(
                '[{"id":"userId","username":"TestUser"}]'
            );
        } else if (endPoint == endPointCard) {
            response.setBody(
                '[{"id":"cardId","desc":"desc text","idBoard":"boardId",'
                + '"name":"1","idList":"idList1","due":"2022-04-10T12:12:00.000Z",'
                + '"idMembers":["userId"]}]'
            );
        }

        return response;
    }
}