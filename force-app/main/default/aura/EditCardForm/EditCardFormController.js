({
    handleSubmit: function(component, event, helper) {
        event.preventDefault();

        var nameField = component.find("nameField").get("v.value");

        if (!nameField || !nameField.replace(/\s/g, "").length > 0) {
            component.set("v.msg", "Title field should be filled");
            component.set("v.stateType", "ERROR");
            helper.doFireEvent(component, event);
        } else {
            component.set("v.msg", "Card changed successfully!");
            component.set("v.stateType", "SUCCESS");
            component.find("editRecordForm").submit();
        }
    },

    handleSave: function(component, event, helper) {
        helper.doFireEvent(component, event);
    }
})