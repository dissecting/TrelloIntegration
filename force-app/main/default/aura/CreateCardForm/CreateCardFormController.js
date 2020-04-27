({
    handleSubmit: function(component, event, helper) {
        event.preventDefault();

        var fields = event.getParam("fields");
        var field = "Name";

        fields.Status__c = component.get("v.fieldValues.statusName");
        fields.Card_Position__c = component.get("v.fieldValues.cardPosition");

        if (fields.hasOwnProperty(field) && (!fields.Name || !fields.Name.replace(/\s/g, "").length > 0)) {
            component.set("v.msg", "Title field should be filled");
            component.set("v.stateType", "ERROR");
        } else {
            component.set("v.msg", "Card created successfully!");
            component.set("v.stateType", "SUCCESS");
            component.find("createRecordForm").submit(fields);
        }

        var cardCreatedEvent = $A.get("e.c:cardCreated");

        cardCreatedEvent.setParams({
            "stateType" : component.get("v.stateType"),
            "msg" : component.get("v.msg")
        });
        cardCreatedEvent.fire();
    }
})