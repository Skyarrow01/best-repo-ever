({
    scroll : function(component, event, helper){
        var box = component.find("tctext");
        box = box.getElement();

        var agreed = component.find("agreed");
        
		var sh = box.scrollHeight;
		var st =   box.scrollTop;
        var ch = box.clientHeight;
        
        if ((sh - ch - st) <= 10){
            agreed.set("v.disabled", false);
        }
    },
    
	onPageReferenceChange : function(component, event, helper) {
		
        var parsedUrl = new URL(window.location.href);
        component.set('v.state', parsedUrl.searchParams.get("state"));

        var action = component.get("c.getTermsAndConditionsText");
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.tctext', resp);
            }
        });
        $A.enqueueAction(action);
    },
    
    onSubmission: function(component, event, helper) {
        
        var stateURL = component.get('v.state');
        var firstName = component.get('v.firstName');
        var lastName = component.get('v.lastName');
        var nickname = component.get('v.nickname');
        var disclaimeraccepted = component.get('v.disclaimeraccepted');
        
        var action = component.get("c.handleSubmit");
        action.setParams({
            "firstName": firstName,
            "lastName": lastName,
            "nickName": nickname,
            "disclaimerAccepted": disclaimeraccepted
        });
        
        action.setCallback(this, function (response) {
            component.set('v.uiMessage', '');
            
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('token'+resp);
                helper.redirectUser(component, event, helper, resp, stateURL);
                
            } else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set('v.uiMessage', message);
            }

        });
        $A.enqueueAction(action);
    }
})