({
	handleClick : function(component, event, helper) {
		var url = event.target.dataset.link;
        window.location.href = url;
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();*/
	}
})