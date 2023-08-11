({
	handleContactSupport : function(component, event, helper) {
		var url = '/contactsupport';

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();		
	},
    
    handleProductDocumentation :function(component, event, helper) {
        var url = 'https://www.automationdirect.com/support';
        window.open(url, '_blank');
    },
    
    handleMessageAdmin :function(component, event, helper) {
        var url = '/community-moderator/';
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    }
    
})