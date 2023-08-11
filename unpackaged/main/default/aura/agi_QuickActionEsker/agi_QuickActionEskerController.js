({
	doInit : function(component, event, helper) {
        var self = this;  // safe reference
    	var theButton = component.find("btn");
        
        var initAction = component.get("c.enableButton");
        initAction.setCallback(self, function(a) {
            var sObject = a.getReturnValue();

            if (sObject) {
                // true - show the button
                theButton.set("v.disabled", false);
            } else {
                // false - disable the button
                theButton.set("v.disabled", true);
            }
        });
    
        // Enqueue the action
        $A.enqueueAction(initAction);
	},
    
	handleClick : function(component, event, helper) {
        var action = component.get("c.forwardToEsker");

        action.setParams({
        	caseId : component.get("v.recordId")
    	});
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if (resp == true) {
                    $A.get('e.force:refreshView').fire();
                    alert('Message Sent to Esker');
                }
                else
                    alert('Could not send to Esker');
            }             
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})