({
 doInit: function(component, event, helper){
		var action = component.get("c.getUserPicVisibility");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.photoSettings", storeResponse);
            }
        });
        $A.enqueueAction(action);
	},
    save: function(component, event, helper) {
        var visSetting = component.find("visSetting").get("v.value");
        
		var action = component.get("c.updateUserPicVisibility");
        action.setParams({'picVisibility': visSetting});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);
    }
    
})