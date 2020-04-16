({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onSync: function(component, event, helper) {
        helper.handleSync(component);
    },

    onRender : function(component, event, helper) {
        var statusList = component.get("v.kanbanData.statusList");
        var elements = [];

        if (statusList) {
            for (var i = 0; i < statusList.length; i++) {
                elements.push(document.getElementById(i));
            }

            dragula(elements).on("drop", function(el, target) {
                var cardElements = target.children;
                var cardIds = [];

                for (var i = 0; i < cardElements.length; i++) {
                    cardIds.push(cardElements[i].id);
                }

                helper.handleUpdateStatus(
                    component,
                    target.getAttribute("data-status"),
                    target.id,
                    cardIds
                );
            });
        }
    }
})
