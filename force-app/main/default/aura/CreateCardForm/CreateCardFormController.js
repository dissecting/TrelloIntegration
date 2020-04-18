({
    handleSubmit: function(component, event, helper) {
        event.preventDefault();

        var fields = event.getParam("fields");

        fields.Status__c = component.get("v.statusName");
        fields.StatusPosition__c = component.get("v.statusPosition");
        fields.Card_Position__c = component.get("v.statusPosition") + component.get("v.cardPosition");
        component.find("createRecordForm").submit(fields);
    },

    handleSave: function(component, event, helper) {
        $A.get("e.c:cardCreated").fire();
    }
})
