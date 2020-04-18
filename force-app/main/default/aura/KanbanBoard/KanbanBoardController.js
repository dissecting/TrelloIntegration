({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onSync: function(component, event, helper) {
        helper.handleSync(component);
    },

    onRender: function(component, event, helper) {
        helper.handleDragAndDrop(component);
    },

    onCardDetail: function(component, event, helper) {
        var params = { "recordId": event.target.id };
        var formType = "c:CardDetailForm";
        var headerValue = "Card";

        helper.handleShowModal(component, params, formType, headerValue);
    },

    onCreateCard: function(component, event, helper) {
        var stageName = event.target.getAttribute("data-stage");
        var columnPosition = event.target.getAttribute("data-column");
        var cardCount = document.getElementById(columnPosition).children.length;
        var params = {
            "statusName": stageName,
            "statusPosition": columnPosition,
            "cardPosition": cardCount
        };
        var formType = "c:CreateCardForm";
        var headerValue = "New Card";

        helper.handleShowModal(component, params, formType, headerValue);
    },

    onEditCard: function(component, event, helper) {
        var params = { "recordId": event.target.id };
        var formType = "c:EditCardForm";
        var headerValue = "Edit Card";

        helper.handleShowModal(component, params, formType, headerValue);
    },

    onCardCreated: function(component, event, helper) {
        helper.handleInit(component);
        component.get("v.modalPromise").then(function (modal) {
            modal.close();
        });
    }
})