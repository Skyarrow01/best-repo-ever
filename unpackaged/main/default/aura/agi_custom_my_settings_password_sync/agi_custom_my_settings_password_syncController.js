({
	loadUserOptions : function(cmp, event, helper) {
        var options = [
        ];
        
        var action = cmp.get("c.getCurrentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var aUser = response.getReturnValue() ;
                cmp.set("v.CurrUser", aUser);
                
            }
            
            
        });
        $A.enqueueAction(action);		
	},
    
    passwordReset : function(cmp, event, helper) {
        var action = cmp.get("c.resetPassword");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if (resp == true)
                    alert('Please check your email for a password reset link.');
                else
                    alert('Please contact support as we were unable to reset your password.');

            }
        });
        $A.enqueueAction(action);		
        
    },
    
    changeMyEmail : function(cmp, event, helper) {
        var action = cmp.get("c.emailChange");
        action.setParams({ 
            newEmail : cmp.get("v.email") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if (resp == true)
                    alert('Your email address has been changed.');
                else
                    alert('Please contact support as we were unable to change your email.');

            }
        });
        $A.enqueueAction(action);		
    }
})