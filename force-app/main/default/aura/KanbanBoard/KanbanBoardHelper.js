({
    handleInit: function(component) {
        var action = component.get("c.getKanbanBoard");

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.kanbanData", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },

    updateStatus : function(component, recordId, statusValue, position) {
        var action = component.get("c.getUpdateStatus");

        action.setParams({
            "recordId": recordId,
            "status": statusValue,
            "position": position
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                document.getElementById(recordId).style.backgroundColor = "#04844b";
                setTimeout(function() {
                    document.getElementById(recordId).style.backgroundColor = "";
                }, 300);
            }
        });

        $A.enqueueAction(action);
	}
})
