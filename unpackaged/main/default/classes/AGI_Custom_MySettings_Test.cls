@isTest
private class AGI_Custom_MySettings_Test {
	@isTest
    static void testTimezones(){
        List<AGI_Custom_MySettings.timeZoneOptions> options = AGI_Custom_MySettings.getTimeZones();
        
        System.assert(options.size() > 0);
    }
    
    @isTest
    static void testCurrentUser(){
        User aUser = AGI_Custom_MySettings.getCurrentUser();
        
        System.assert(aUser != null);
    }
    
    @isTest
    static void testNetworkMember(){
        NetworkMember nm = AGI_Custom_MySettings.getMemberSettings();
        
        System.assert(nm != null);
    }
    
    @isTest
    static void testUserGuide(){
        String userGuideUrl = AGI_Custom_MySettings.fetchUserGuide();
        
        System.assert(userGuideUrl == '');
    }
    
    @isTest
    static void testResetPass(){
		Test.setMock(HttpCalloutMock.class, new MuleAPIMock());         
        Boolean bResult = AGI_Custom_MySettings.resetPassword();
        
        System.assert(bResult == true);
    }

	@isTest
    static void testTZData(){
        Map<String, Object> result = AGI_Custom_MySettings.getTimeZoneUserData();
        System.assert(result.get('tzOptions') != null);
        System.assert(result.get('tzSelected') != null);
    }

	@isTest
    static void getUserDetails(){
		Map<String, Object> result = AGI_Custom_MySettings.getUserDetails();
        System.assert(result.get('accountId') != null);
    }    
}