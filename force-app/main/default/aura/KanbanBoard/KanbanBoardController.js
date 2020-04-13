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

    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },

    doDrag: function (component, event, helper) {
        event.dataTransfer.setData("text", event.target.id);
    },

    doDrop: function (component, event, helper) {
        event.preventDefault();

        var data = event.dataTransfer.getData("text");
        var targetEvent = event.target;

        while (targetEvent.tagName != "ul" && targetEvent.tagName != "UL") {
            targetEvent = targetEvent.parentElement;
        }

        targetEvent.appendChild(document.getElementById(data));
        helper.updateStatus(
            component,
            data,
            targetEvent.getAttribute("data-status"),
            targetEvent.getAttribute("data-index")
        );
    }
})
