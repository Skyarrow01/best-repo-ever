({
	redirectUser : function(component, event, helper, token, state) {
		var url = 'https://' + $A.get("$Label.c.auth0_domain") + '/continue' + '?id_token=' + token + '&state=' + state
        console.log('url'+url);
        location.href = url;
		
        
	}
})