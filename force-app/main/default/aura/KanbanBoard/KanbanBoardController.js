({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    doView: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:navigateToSObject");

        editRecordEvent.setParams({
            "recordId": event.target.id
        });
        editRecordEvent.fire();
    },

    onRender : function(component, event, helper) {
        var statusList = component.get("v.kanbanData.statusList");
        var elements = [];

        if (statusList) {
            for (var i = 0; i < statusList.length; i++) {
                elements.push(document.getElementById(i));
            }

            dragula(elements).on("drop", function(el, target) {
                helper.updateStatus(
                    component,
                    el.id,
                    target.getAttribute("data-status"),
                    target.id
                );
            });
        }
    }
})
