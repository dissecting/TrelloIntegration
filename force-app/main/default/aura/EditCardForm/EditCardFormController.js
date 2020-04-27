({
    handleSubmit: function(component, event, helper) {
        event.preventDefault();

        var nameField = component.find("nameField").get("v.value");

        if (!nameField || !nameField.replace(/\s/g, "").length > 0) {
            component.set("v.msg", "Title field should be filled");
            component.set("v.stateType", "ERROR");
        } else {
            component.set("v.msg", "Card changed successfully!");
            component.set("v.stateType", "SUCCESS");
            component.find("editRecordForm").submit();
        }

        var cardCreatedEvent = $A.get("e.c:cardCreated");

        cardCreatedEvent.setParams({
            "stateType" : component.get("v.stateType"),
            "msg" : component.get("v.msg")
        });
        cardCreatedEvent.fire();
    }
})