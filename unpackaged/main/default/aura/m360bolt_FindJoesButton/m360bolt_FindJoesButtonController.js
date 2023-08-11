({
	gotoURL : function(component, event, helper) {
        var url = component.get("v.FindJoesButtonURL");

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    }
})