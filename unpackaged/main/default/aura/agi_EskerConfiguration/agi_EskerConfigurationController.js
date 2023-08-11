({
	doInit : function(component, event, helper) {
        var self = this;  // safe reference
    
        var initAction = component.get("c.loadPage");
        initAction.setCallback(self, function(a) {
            var sObject = a.getReturnValue();
            var recordId = sObject.Id;
            
            component.set("v.customSetting", sObject);
            component.set("v.recordId", recordId);
        });
    
        // Enqueue the action
        $A.enqueueAction(initAction);
	},
    
    update : function(component, event, helper) {
        var intEnabled = component.find("intEnabled").get("v.checked");
        var triggerEnabled = component.find("triggerEnabled").get("v.checked");
        var eskerEmail = component.find("eskerEmail").get("v.value");
		var recordId = component.get("v.recordId");
		
		var action = component.get("c.updateSettings");        
		action.setParams({"recordId": recordId, "intEnabled": intEnabled,
                          "triggerEnabled": triggerEnabled, "eskerEmail": eskerEmail});
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                alert('Settings updated');
            } else if (state === "INCOMPLETE") {
                // do something
            } else {
                alert('Failed to update settings');
                console.log('FAILURE');
            }
        });
        $A.enqueueAction(action);        
        
    }
})