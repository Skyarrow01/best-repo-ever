({
    doInit : function(component, event, helper) {
        if (component.get('v.NumberOfTiles') == 2) {
            component.set('v.MediumLargeDeviceSize', 4);
        } else {
            component.set('v.MediumLargeDeviceSize', 3);
        }
        
        helper.fetchTilesObject(component, event, helper);
        helper.fetchCurrentUserProfile(component, event, helper);
    },
    
    linkRedirect: function(component, event, helper) {
    	var selectedItem = event.currentTarget;
        var url = selectedItem.dataset.link; 
        helper.redirectLink(component, event, helper, url);
    }
})