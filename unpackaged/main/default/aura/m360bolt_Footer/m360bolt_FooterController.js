({
	gotoURL : function(component, event, helper) {
		var url = component.get('v.GuidelineLink');

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
	}
})