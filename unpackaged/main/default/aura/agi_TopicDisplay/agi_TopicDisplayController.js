({
	doInit : function(component, event, helper) {
		var userId =  $A.get("$SObjectType.CurrentUser.Id");
        if (userId == null)
            component.set("v.guest", true);
        else {
            component.set("v.guest", false);
            component.set("v.CurrentUser", userId);
        }
        
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        component.set("v.baseUrl", baseURL);

        helper.getList(component);
	},
    
    handleFilter : function(component, event, helper) {
        let filterItems = ['fall','fnotanswered','fnobest','fbest']
        filterItems.forEach(function(item, index, array){
        	var cmpTurnOff = "v." + item;
            component.set(cmpTurnOff, null);
        });
        
        var cmpName = "v.f" + event.getParam("value");
        component.set(cmpName, true);
        
        var selectedMenuItemValue = event.getParam("value");
        component.set("v.optFilter", selectedMenuItemValue);
        helper.getList(component);
    },

    handleSort : function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.optSort", selectedOptionValue);
        helper.getList(component);
    },
    
    handlePin : function(component, event, helper) {
        var recId = event.getParam("value");
        helper.pin(component, true, recId);
        helper.getList(component);
    },
    
    handleUnpin : function(component, event, helper) {
        var recId = event.getParam("value");
        helper.pin(component, false, recId);
        helper.getList(component);
    },
    
    handleViewMoreClick: function(component, event, helper) {
        helper.getMore(component);
    }
    
})