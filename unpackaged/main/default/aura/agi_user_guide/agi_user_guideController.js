({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchUserGuide");
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.pdfContent', resp);
                System.debug('******** SUCCESS *********');
            } else {
                System.debug('******** FAILURE *********');
            }
        });
        $A.enqueueAction(action);
	}
})