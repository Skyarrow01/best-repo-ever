({
	handleSelect : function(component, event, helper) {
        helper.handleSelect(component, event);
    },
    
    doInit: function(component, event, helper){
		var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.currUser", storeResponse);
            }
        });
        $A.enqueueAction(action);
	}    
})