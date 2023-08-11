public without sharing class agi_FetchAdditionalInfoController {
    
    private static String createSignedJWT(String firstName, String lastName, String nickName) {
        
        JWT jwt = new JWT('HS256');
        jwt.privateKey = [SELECT PrivateKey__c FROM JWTPrivateKey__mdt WHERE MasterLabel = 'DefaultPrivateKey'].PrivateKey__c;
        jwt.iss = 'URN:SalesforceForm';
        jwt.sub = 'SF Communities Value Transfer';
        jwt.aud = 'URN:auth0';
        Map<String,String> claims = new  Map<String,String>();
        claims.put('firstName',firstName);
        claims.put('lastName',lastName);
        claims.put('nickname',nickName);
        claims.put('status','ok');
        jwt.claims = claims;
        String token = jwt.issue(); 
        return token;
    }
    
    @auraEnabled
    public static String handleSubmit(String firstName, String lastName, String nickName, Boolean disclaimerAccepted) {
        String jwtToken = '';
        
        if (disclaimerAccepted == null || disclaimerAccepted == false)
            throw new AuraHandledException('Please review and accept the Terms and Conditions');
        
        //query and see if the nickname already exists in the system
        List<User> userRecords = [SELECT Id FROM User WHERE CommunityNickname = :nickName];
        if(userRecords.size() > 0) {
            //throw a nickname already exist error
            throw new AuraHandledException('This Nickname is already taken, please choose a different nickname to proceed');
        }
        
        try {
            jwtToken = createSignedJWT(firstName, lastName, nickName);
        } catch(Exception e) {
            throw new AuraHandledException('Something went wrong!:'+e.getMessage());    
        }
        return jwtToken;
    }
    
    @AuraEnabled
    public static String getTermsAndConditionsText() {
        String terms = '';
        
        Community_Customization__c customizations = [SELECT Value__c from Community_Customization__c WHERE name ='Terms And Conditions']; 
        if (customizations != null)
            terms = customizations.Value__c;

        return terms;
        
    }
}