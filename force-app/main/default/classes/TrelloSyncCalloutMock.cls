public with sharing class TrelloSyncCalloutMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest request) {
        String endPointBoard = 'https://api.trello.com/1/members/TestUser/boards?key=testApiKey&token=testToken';
        String endPointColumn = 'https://api.trello.com/1/boards/boardId/lists?key=testApiKey&token=testToken';
        String endPointUser = 'https://api.trello.com/1/boards/boardId/members?key=testApiKey&token=testToken';
        String endPointCard = 'https://api.trello.com/1/boards/boardId/cards?key=testApiKey&token=testToken';
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