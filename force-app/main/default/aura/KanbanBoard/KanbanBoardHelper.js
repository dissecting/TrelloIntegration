({
    handleInit: function(component) {
        var action = component.get("c.getKanbanBoard");

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.kanbanData", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();

                this.handleShowToast(component, state, errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    handleSync: function(component) {
        var preloader = component.find("preloader");
        var action = component.get("c.getSync");

        component.set("v.isSync", true);
        $A.util.addClass(preloader, "progress");

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                var msgSuccess = "Sync completed successfully";
                var drake = component.get("v.dragula");

                this.handleShowToast(component, state, msgSuccess);
                this.handleInit(component);
                component.set("v.isSync", false);
                $A.util.removeClass(preloader, "progress");
                drake.cancel();
                $A.get("e.force:refreshView").fire();
            } else if (state === "ERROR") {
                var errors = response.getError();

                this.handleShowToast(component, state, errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    handleUpdateStatus: function(component, statusValue, position, cardIds) {
        var action = component.get("c.getUpdateStatus");

        action.setParams({
            "status": statusValue,
            "statusPosition": position,
            "cardIds" : cardIds.join(",")
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "ERROR") {
                var errors = response.getError();

                this.handleShowToast(component, state, errors[0].message);
            }
        });

        $A.enqueueAction(action);
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
