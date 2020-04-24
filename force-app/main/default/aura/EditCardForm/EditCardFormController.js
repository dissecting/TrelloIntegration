({
    handleSubmit: function(component, event, helper) {
        component.find("editRecordForm").submit();
    },

    handleSave: function(component, event, helper) {
        $A.get("e.c:cardCreated").fire();
    }
})