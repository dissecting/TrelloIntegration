({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onSync: function(component, event, helper) {
        helper.handleSync(component);
    },

    onRender: function(component, event, helper) {
        var statusList = component.get("v.kanbanData.statusList");
        var elements = [];

        if (statusList) {
            if (!component.get("v.isRendered")) {
                for (var i = 0; i < statusList.length; i++) {
                    elements.push(document.getElementById(i));
                }

                var drake = dragula(elements).on("drop", function(el, target) {
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

                component.set("v.dragula", drake);
            }
            component.set("v.isRendered", true);
        }
    },

    onCardDetail: function(component, event, helper) {
        $A.createComponent(
            "c:CardDetailForm", {
                "recordId": event.target.id
            },
           function(content, status) {
               if (status === "SUCCESS") {
                   component.find("overlayLib").showCustomModal({
                       header: "Card",
                       body: content,
                       showCloseButton: true
                   })
               }
           }
        );
    },

    onCreateCard: function(component, event, helper) {
        var stageName = event.target.getAttribute("data-stage");
        var columnPosition = event.target.getAttribute("data-column");
        var cardCount = document.getElementById(columnPosition).children.length;

        $A.createComponent(
            "c:CreateCardForm", {
                "statusName": stageName,
                "statusPosition": columnPosition,
                "cardPosition": cardCount
            },
           function(content, status) {
               if (status === "SUCCESS") {
                    var modalPromise = component.find("overlayLib").showCustomModal({
                       header: "New Card",
                       body: content,
                       showCloseButton: true
                   });
                   component.set("v.modalPromise", modalPromise);
               }
           }
        );
    },

    onEditCard: function(component, event, helper) {
        $A.createComponent(
            "c:EditCardForm", {
                "recordId": event.target.id
            },
           function(content, status) {
               if (status === "SUCCESS") {
                    var modalPromise = component.find("overlayLib").showCustomModal({
                       header: "Edit Card",
                       body: content,
                       showCloseButton: true
                   });
                   component.set("v.modalPromise", modalPromise);
               }
           }
        );
    },

    onCardCreated: function(component, event, helper) {
        helper.handleInit(component);
        component.get("v.modalPromise").then(function (modal) {
            modal.close();
        });
    },

    onToast: function(component, event, helper) {
        if (event.getParams().type === "SUCCESS" && event.getParams().message.includes("was saved.")) {
            helper.handleInit(component);
        }
    }
})