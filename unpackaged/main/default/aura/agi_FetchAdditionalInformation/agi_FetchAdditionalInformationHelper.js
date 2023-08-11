({
	redirectUser : function(component, event, helper, token, state) {
		var url = 'https://' + $A.get("$Label.c.auth0_domain") + '/continue' + '?id_token=' + token + '&state=' + state
        console.log('url'+url);
        location.href = url;
	},
    
    handleErrors : function(component, event, helper, message) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (message) {
            toastParams.message = message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
	}
})