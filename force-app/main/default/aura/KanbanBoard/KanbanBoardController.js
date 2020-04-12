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

    drag: function (component, event, helper) {
        event.dataTransfer.setData("text", event.target.id);
    },

    drop: function (component, event, helper) {
        event.preventDefault();

        var data = event.dataTransfer.getData("text");
        var tar = event.target;

        while (tar.tagName != "ul" && tar.tagName != "UL") {
            tar = tar.parentElement;
        }

        tar.appendChild(document.getElementById(data));
        document.getElementById(data).style.backgroundColor = "#ffb75d";
        helper.updatePickVal(component, data, tar.getAttribute("data-status"), tar.getAttribute("data-index"));
    }
})
