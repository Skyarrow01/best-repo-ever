({
	getAddressRecommendations: function(component, event) {
        var key = component.get("v.searchKey");
        var action = component.get("c.getAddressSet");
        action.setParams({
            "SearchText": key
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = JSON.parse(response.getReturnValue());
                var predictions = response.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc =[];
                        addresses.push(
                            {
                                main_text: predictions[i].structured_formatting.main_text, 
                                secondary_text: predictions[i].structured_formatting.secondary_text,
                                place_id: predictions[i].place_id
                            });
                        
                    }
                }
                for(var i=0; i <addresses.length; i++){
                    console.log(addresses[i].main_text);
                    console.log(addresses[i].secondary_text);
                    console.log(addresses[i].place_id);
                }
                component.set("v.AddressList", addresses);
            }
        });
        $A.enqueueAction(action);
    },
    
    getAddressDetailsByPlaceId: function(component, event) {
        var selectedValue = event.currentTarget.dataset.value;
        var action = component.get("c.getAddressDetailsByPlaceId");
        action.setParams({
            PlaceID:selectedValue 
        });
        action.setCallback(this, function(response){
            var res = response.getState();
            if(res == 'SUCCESS'){
                //console.log(response.getReturnValue());
                var response = JSON.parse(response.getReturnValue());
                var postalCode = '', state = '', country= '', city = '', street = '', street_number = '', route = '', subLocal1 = '', subLocal2 = '';
                
                for(var i=0; i < response.result.address_components.length ; i++){
                    var FieldLabel = response.result.address_components[i].types[0];
                    //console.log(FieldLabel);
                    //debugger;
                    if(FieldLabel == 'sublocality_level_2' || FieldLabel == 'sublocality_level_1' || FieldLabel == 'street_number' || FieldLabel == 'route' || FieldLabel == 'locality' || FieldLabel == 'country' || FieldLabel == 'postal_code' || FieldLabel == 'administrative_area_level_1'){
                        switch(FieldLabel){
                            case 'sublocality_level_2':
                                subLocal2 = response.result.address_components[i].long_name;
                                break;
                            case 'sublocality_level_1':
                                subLocal1 = response.result.address_components[i].long_name;
                                break;
                            case 'street_number':
                                street_number = response.result.address_components[i].long_name;
                                break;
                            case 'route':
                                route = response.result.address_components[i].short_name;
                                break;
                            case 'postal_code':
                                postalCode = response.result.address_components[i].long_name;
                                break;
                            case 'administrative_area_level_1':
                                state = response.result.address_components[i].short_name;
                                break;
                            case 'country':
                                country = response.result.address_components[i].short_name;
                                break;
                            case 'locality':
                                city = response.result.address_components[i].long_name;
                                break;
                            default:
                                break;
                        }
                    }
                }
                
                street = street_number + ' ' + route;
                if(street == null){
                    street = subLocal2 + ' ' + subLocal1;
                }
                console.log(street+'-'+postalCode+'-'+state+'-'+country+'-'+city);
                component.set('v.street', street);
                component.set('v.postalCode', postalCode);
                component.set('v.state', state);
                component.set('v.country', country);
                component.set('v.city', city);
                component.set("v.searchKey", null);
                component.set("v.showModalBox", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeCurrentTab: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        	workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
              window.history.back();
        });
    },
    
    openTab: function(component, event, helper, recordId) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId":recordId,
                    "actionName":"view"
                },
                "state": {}
            },
            focus: true
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
            workspaceAPI.getTabInfo({
                tabId: response
        }).then(function(tabInfo) {
            console.log("The recordId for this tab is: " + tabInfo.recordId);
        });
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    getContactRecord: function(component, event, helper, Id) {
        var action = component.get("c.getContactRecord");
        action.setParams({
            "recordId": Id
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('resp'+JSON.stringify(resp));
                if (resp.AccountId) {
                    component.set('v.parentAccountId', resp.AccountId);
                }
                
                if (resp.Account && resp.Account.Name) {
                    component.set('v.parentAccountName', resp.Account.Name);
                }
                
                if (resp.Email) {
                    component.set('v.email', resp.Email);
                }
                
                if (resp.MobilePhone && resp.MobilePhone.length > 0) {
                    component.set('v.phone', resp.MobilePhone);
                }
                
                if (resp.Direct_Phone__c && resp.Direct_Phone__c.length > 0) {
                    component.set('v.phone', resp.Direct_Phone__c);
                }
            }
        });
        $A.enqueueAction(action);
    }
    	
})