({
    doFireEvent: function(component, event) {
        var cardCreatedEvent = $A.get("e.c:CardCreated");

        cardCreatedEvent.setParams({
            "stateType" : component.get("v.stateType"),
            "msg" : component.get("v.msg")
        });
        cardCreatedEvent.fire();
    }
})