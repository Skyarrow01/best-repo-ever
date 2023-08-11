({
	handleSelect : function(component, event) {
        var eventSource = event.getSource();
        var selectedValue = eventSource.get("v.label");
        
        var gotoUrl = "/";
        var myUser = $A.get("$SObjectType.CurrentUser");
        console.log(selectedValue);
		
        switch(selectedValue) {
            case "Home":
                gotoUrl = "/";
                break;
            case "My Profile":
                gotoUrl = "/profile/" + myUser.Id;
                break;
            case "My Settings":
                gotoUrl = "/my-settings/";
                break;
            case "My Messages":
                gotoUrl = "/messages/Home";
                break;
            case "Contact Support":
                gotoUrl = "/contactsupport";
                break;     
            case "Logout":
                gotoUrl = "";
                window.open('/secur/logout.jsp','_self');
                break;  
        }
        
        if (gotoUrl != "")
        	this.navigateToCommunityPage(gotoUrl, false);
	},
    navigateToCommunityPage: function(url, redirect) {
        if (url.substring(0,4) == 'https') {
            var element = document.createElement('a');
            element.href = url;
            element.click();
        } else {
        	var urlEvent = $A.get('e.force:navigateToURL');
            var params = {
                'url': url
            };
            
            if (redirect) {
                params.redirect = redirect;
            }
            
            if (urlEvent) {
                urlEvent.setParams(params);
                urlEvent.fire();
            }    
        }
    }
})