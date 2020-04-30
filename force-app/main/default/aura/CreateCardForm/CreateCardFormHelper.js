({
    doFireEvent: function(component, event) {
        var cardCreatedEvent = $A.get("e.c:cardCreated");

        cardCreatedEvent.setParams({
            "stateType" : component.get("v.stateType"),
            "msg" : component.get("v.msg")
        });
        cardCreatedEvent.fire();
    }
})