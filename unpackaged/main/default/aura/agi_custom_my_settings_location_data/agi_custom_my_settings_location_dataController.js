({
	loadTimeZoneOptions : function(cmp, event, helper) {
        var options = [
        ];
        
        var action = cmp.get("c.getTimeZoneUserData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue() ;
                var arr = resp['tzOptions'];
 
                cmp.set("v.currTZ", resp['tzSelected']);

                arr.forEach(function(element) {
                    options.push({ value: element.optionValue, label: element.optionLabel });
                });
                cmp.set("v.TimeZoneOptions", options);
                
            }
            
            
        });
        $A.enqueueAction(action);		
	},
    save: function(component, event, helper) {
        var action = component.get("c.updateTZ");
        var tz = component.find("tz").get("v.value");
        
        action.setParams({"tzValue": tz});
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
            } else if (state === "INCOMPLETE") {
                // do something
            } else {
                console.log('FAILURE');
            }
        });
        $A.enqueueAction(action);
        
    }
    
    
})