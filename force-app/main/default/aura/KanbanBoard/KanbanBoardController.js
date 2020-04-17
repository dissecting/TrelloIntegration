({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onSync: function(component, event, helper) {
        helper.handleSync(component);
    },

    onRender: function(component, event, helper) {
        var statusList = component.get("v.kanbanData.statusList");
        var elements = [];

        if (statusList) {
            if (!component.get("v.isRendered")) {
                for (var i = 0; i < statusList.length; i++) {
                    elements.push(document.getElementById(i));
                }

                dragula(elements).on("drop", function(el, target) {
                    var cardElements = target.children;
                    var cardIds = [];

                    for (var i = 0; i < cardElements.length; i++) {
                        cardIds.push(cardElements[i].id);
                    }

                    helper.handleUpdateStatus(
                        component,
                        target.getAttribute("data-status"),
                        target.id,
                        cardIds
                    );
                });
            }
            component.set("v.isRendered", true);
        }
    },

    onEdit: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");

        editRecordEvent.setParams({
            "recordId": event.target.id
        });
        editRecordEvent.fire();
    },

    onCreateCard: function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");

        createRecordEvent.setParams({
            "entityApiName": "Card__c",
            "defaultFieldValues": {
                "Name" : "test"
            }
        });
        createRecordEvent.fire();
    },

    onToast: function(component, event, helper) {
        if (event.getParams().type === "SUCCESS" && event.getParams().message.includes("was saved.")) {
            helper.handleInit(component);
        }
    }
})
