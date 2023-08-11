({
	redirectLink : function(component, event, helper, id) {
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id
        });
        navEvt.fire(); 
	},
    
    fetchTilesObject : function(component, event, helper) {
        var action = component.get("c.fetchImageTiles");
        action.setParams({
            "FirstTileName": component.get('v.FirstTileName'),
            "FirstTileLink": component.get('v.FirstTileLink'),
            "FirstTileImageLink": component.get('v.FirstTileImageLink'),
            "SecondTileName": component.get('v.SecondTileName'),
            "SecondTileLink": component.get('v.SecondTileLink'),
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
                console.log('resp'+JSON.stringify(resp));
                component.set('v.allTiles', resp);
            }
        });
        $A.enqueueAction(action);
    }
})