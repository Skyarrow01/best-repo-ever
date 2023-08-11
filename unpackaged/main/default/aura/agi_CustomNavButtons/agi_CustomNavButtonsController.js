({
	gotoURL : function(component, event, helper) {
        var whichButton = event.getSource().getLocalId();
		var url = "";
        
        switch(whichButton){
            case "Button1":
            	url = component.get("v.Button1URL");
            	break;
            case "Button2":
            	url = component.get("v.Button2URL");
            	break;
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    }
})