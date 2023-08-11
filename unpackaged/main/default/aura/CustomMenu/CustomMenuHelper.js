({
    
    fetchSubtopicsInformation : function(component, event, helper) {
        var action = component.get("c.fetchTopicInformation");
        action.setParams({
            "FirstTopicString": component.get('v.FirstMenuItemSubtopicsName'),
            "SecondTopicString": component.get('v.SecondMenuItemSubtopicsName')
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if (resp.firstTopicList) {
                    component.set('v.FirstMenuItemSubtopicsList', resp.firstTopicList);
                    component.set('v.SecondMenuItemSubtopicsList', resp.SecondTopicList);
                }
                
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
    },
    
    displayLeftNavMenu: function(component, event, helper) {
        var el = component.find('sideMenuPageContainer').getElement();
        
        $A.util.toggleClass( el, 'showElement');
        console.log('el'+el);
        var elClass = el.className;
        
        switch(elClass) {
            case 'navMenuWrapper cCustomMenu showElement':
                document.body.scrollTop = 0;
                document.body.setAttribute('style', 'overflow: hidden;');
                break;
            default:
                document.body.setAttribute('style', 'overflow: inherit;');
                break;
        }
    },
    
    closeLeftNavMenu: function(component) {
        var el = component.find('sideMenuPageContainer').getElement();
        console.log('el'+el);
        $A.util.removeClass( el, 'showElement');
        document.body.setAttribute('style', 'overflow: inherit;');
    }
    
})