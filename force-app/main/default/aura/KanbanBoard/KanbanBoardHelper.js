({
    handleInit: function(component) {
        var action = component.get("c.getKanbanBoard");
        var actionType = "GetKanban";

        this.handleCallback(component, action, actionType);
    },

    handleSync: function(component) {
        var action = component.get("c.getSync");
        var actionType = "Sync";

        this.handleCallback(component, action, actionType);
    },

    handleUpdateStatus: function(component, statusValue, cardIds) {
        var action = component.get("c.getUpdateStatus");
        var actionType = "UpdateStatus";

        action.setParams({
            "status": statusValue,
            "cardIds" : cardIds
        });

        this.handleCallback(component, action, actionType);
    },

    handleDragAndDrop: function(component) {
        var statusList = component.get("v.kanbanData.statusList");
        var elements = [];
        var self = this;

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

                    self.handleUpdateStatus(
                        component,
                        target.getAttribute("data-status"),
                        cardIds
                    );
                });

                component.set("v.dragula", drake);
            }
            component.set("v.isRendered", true);
        }
    },

    handleCallback: function(component, action, actionType) {
        var preloader = component.find("preloader");

        if (actionType === "Sync") {
            component.set("v.isSync", true);
            $A.util.addClass(preloader, "progress");
        }

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                if (actionType === "Sync") {
                    var msgSuccess = "Sync completed successfully";
                    var drake = component.get("v.dragula");

                    this.handleShowToast(component, state, msgSuccess);
                    this.handleInit(component);

                    component.set("v.isSync", false);
                    $A.util.removeClass(preloader, "progress");
                    drake.cancel();
                    $A.get("e.force:refreshView").fire();
                } else if (actionType === "GetKanban") {
                    component.set("v.kanbanData", response.getReturnValue());
                }
            } else if (state === "ERROR") {
                var errors = response.getError();

                this.handleShowToast(component, state, errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    handleShowModal: function(component, params) {
        $A.createComponent(
            params.formType,
            params.attributes,
           function(content, status) {
               if (status === "SUCCESS") {
                    var modalPromise = component.find("overlayLib").showCustomModal({
                       header: params.headerValue,
                       body: content,
                       showCloseButton: true
                   });

                   component.set("v.modalPromise", modalPromise);
               }
           }
        );
    },

    handleShowToast: function(component, msgType, msg) {
        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title": msgType === "SUCCESS" ? "Success!": "Error!",
            "type": msgType === "SUCCESS" ? "success": "error",
            "message": msg
        });
        toastEvent.fire();
    }
})