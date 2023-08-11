({
	saveChanges : function(component, event, helper) {
		var locationCmp = component.find("location");
		var visCmp = component.find("vis");
		var notifCmp = component.find("notif");

        locationCmp.saveLoc();
        notifCmp.saveNotif();
        visCmp.saveVis();
        
        window.location.reload();
	}
})