({
    updatePickVal : function(component, recId, statusValue, indexValue) {
        var action = component.get("c.getUpdateStatus");

        action.setParams({
            "recordId": recId,
            "status": statusValue,
            "position": indexValue
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                document.getElementById(recId).style.backgroundColor = "#04844b";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 300);
            }
        });

        $A.enqueueAction(action);
	}
})
