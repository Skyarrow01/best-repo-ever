({
	redirectLink : function(component, event, helper, url) {
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
	},
    
    fetchTilesObject : function(component, event, helper) {
        var profileName = component.get('v.currentUserProfileName');
        
        var action = component.get("c.fetchImageTiles");
        action.setParams({
            "FirstTileName": component.get('v.FirstTileName'),
            "FirstTileLink": (profileName = 'ADC Community User' || profileName == 'Community Profile' ) ? component.get('v.FirstTileLinkGuest') : component.get('v.FirstTileLink'),
            "FirstTileImageLink": component.get('v.FirstTileImageLink'),
            "SecondTileName": component.get('v.SecondTileName'),
            "SecondTileLink": (profileName = 'ADC Community User' || profileName == 'Community Profile' ) ? component.get('v.SecondTileLinkGuest') : component.get('v.SecondTileLink'),
            "SecondTileImageLink": component.get('v.SecondTileImageLink'),
            "ThirdTileName": component.get('v.ThirdTileName'),
            "ThirdTileLink": component.get('v.ThirdTileLink'),
            "ThirdTileImageLink": component.get('v.ThirdTileImageLink'),
            "FourthTileName": component.get('v.FourthTileName'),
            "FourthTileLink": component.get('v.FourthTileLink'),
            "FourthTileImageLink": component.get('v.FourthTileImageLink'),
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.allTiles', resp);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCurrentUserProfile : function(component, event, helper) {
      	 var action = component.get("c.fetchProfileInformation");
        
         action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.currentUserProfileName', resp);
            }
         });
         $A.enqueueAction(action); 
    }
})