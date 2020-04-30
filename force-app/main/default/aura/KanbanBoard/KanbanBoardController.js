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
        var attributes = { "recordId" : event.target.id };
        var formType = "c:CardDetailForm";
        var headerValue = "Card";
        var params = { attributes, formType, headerValue };

        helper.handleShowModal(component, params);
    },

    onCreateCard: function(component, event, helper) {
        var stageName = event.target.getAttribute("data-stage");
        var columnPosition = event.target.getAttribute("data-column");
        var cardCount = document.getElementById(columnPosition).children.length;
        var attributes = { "fieldValues" : {
            "statusName" : stageName,
            "cardPosition" : String(cardCount)
        }};
        var formType = "c:CreateCardForm";
        var headerValue = "New Card";
        var params = { attributes, formType, headerValue };

        helper.handleShowModal(component, params);
    },

    onEditCard: function(component, event, helper) {
        var attributes = { "recordId" : event.target.id };
        var formType = "c:EditCardForm";
        var headerValue = "Edit Card";
        var params = { attributes, formType, headerValue };

        helper.handleShowModal(component, params);
    },

    onCardCreated: function(component, event, helper) {
        helper.handleShowToast(component, event.getParam("stateType"),  event.getParam("msg"));

        if (event.getParam("stateType") == "SUCCESS") {
            helper.handleInit(component);
            component.get("v.modalPromise").then(function (modal) {
                modal.close();
            });
        }
    }
})