public without sharing class AGI_Custom_MySettings {

    private static HttpResponse callPasswordAPI(String email){
        Http apiEndpoint = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MuleSoftAPI/passwordReset?email=' + email);
        req.setMethod('GET');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        HttpResponse resp = apiEndpoint.send(req);
        
        return resp;
    }
    
    @AuraEnabled
    public static Boolean resetPassword() {
        User u = getCurrentUser();
        String email = u.Email;
        Boolean bStatus = false;
        
        HttpResponse resp = callPasswordAPI(email);
        
        System.debug(resp.getStatusCode());
        if (resp.getStatusCode() == 200){
            String respBody = resp.getBody();
            if (respBody.contains('OK'))
                bStatus = true;
        }
        else {
            bStatus = false;
        }
        
        return bStatus;
    }
    
    private static HttpResponse callEmailAPI(String oldEmail, String newEmail){
        Http apiEndpoint = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MuleSoftAPI/changeEmail?oldEmail=' + oldEmail + '&newEmail=' + newEmail);
        req.setMethod('GET');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        HttpResponse resp = apiEndpoint.send(req);
        
        return resp;
    }
    
    @AuraEnabled
    public static Boolean emailChange(String newEmail) {
        User u = getCurrentUser();
        
        String oldEmail = u.Email;
        Boolean bStatus = false;
        
        HttpResponse resp = callEmailAPI(oldEmail, newEmail);
        
        if (resp.getStatusCode() == 200){
            String respBody = resp.getBody();
            if (respBody.contains('OK')){
                bStatus = true;
                updateUserEmail(u, newEmail);
                updateUserContact(u.ContactId, newEmail);
            }
        }
        else {
            bStatus = false;
        }
        
        return bStatus;
    }
    
    private static void updateUserEmail(User u, String newEmail){
        u.Email = newEmail;
        u.Username = newEmail + '.adc';
        update u;
    }
    
    @future
    private static void updateUserContact(String cId, String newEmail){
        Contact c = [SELECT Id, Email from Contact where Id = :cId];

        if (c != null){
            c.Email = newEmail;
            update c;
        }
    }
    
    @AuraEnabled
    public static Boolean changeEmail(){
        return true;
    }
    
    @AuraEnabled
    public static Map<String, Object> getTimeZoneUserData(){
        Map<String, Object> mTZData = new Map<String, Object>();
        User u = getCurrentUser();

        mTZData.put('tzOptions', getTimeZones());
        mTZData.put('tzSelected', u.TimeZoneSidKey);

        return mTZData;        
    }
    
    @AuraEnabled
    public static List<timeZoneOptions> getTimeZones(){
        List<timeZoneOptions> options = new List<timeZoneOptions>();
        
        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getdescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        {
            options.add(new timeZoneOptions(p.getLabel(), p.getValue()));
        }
        
        return options;
    }
    
    @AuraEnabled
    public static User getCurrentUser(){
        User u = [Select Id, Email, FirstName, LastName, Address, CommunityNickname, Title, SmallPhotoUrl, ContactId, External_Provider__c, Profile.Name, UserPreferencesShowProfilePicToGuestUsers, TimeZoneSidKey   from User where Id = :userInfo.getUserId()];
        
        return u;
    }
    
    @AuraEnabled
    public static NetworkMember getMemberSettings(){
        NetworkMember nm = [Select Id, PreferencesDisableAllFeedsEmail, PreferencesDisableEndorsementEmail, PreferencesDisableProfilePostEmail,
                            PreferencesDisableFollowersEmail, PreferencesDisableLikeEmail, PreferencesDisableChangeCommentEmail, 
                            PreferencesDisProfPostCommentEmail, PreferencesDisableLaterCommentEmail, PreferencesDisableBookmarkEmail,
                            PreferencesDisCommentAfterLikeEmail, PreferencesDisableMentionsPostEmail, PreferencesDisMentionsCommentEmail,
                            PreferencesDisableItemFlaggedEmail, PreferencesDisableBestAnswerEmail, PreferencesDisableDirectMessageEmail,
                            PreferencesDisablePendingReviewEmail, PreferencesDisableCaseContactEmail from NetworkMember where MemberId = :userInfo.getUserId()];
   
           
        return nm;            
    }
    
    private static String getCustomValue(String keyName){
        String retVal = '';
        
       List<Community_Customization__c> cc = [SELECT ID, Value__c FROM Community_Customization__c WHERE name = :keyName];
        if (cc.size() > 0){
            retVal = cc[0].Value__c;
        }
        
        return retVal;        
    }
    
    @AuraEnabled
    public static String fetchUserGuide(){
        return getCustomValue('User Guide');
    }

    private static String getAssociatedAccount(User u){
        String accountId = '';
        
        if (u.ContactId != null) {
            Contact c = [SELECT Id, AccountId from Contact WHERE Id = :u.ContactId];        
            if (c != null)
                accountId = c.AccountId;
        }
        return accountId;
    }

    private static boolean isGuest(){
        boolean bResult = false;
        if (UserInfo.getUserType() == 'Guest') {
            bResult = true;
        } 
        return bResult;
    }
    
    @AuraEnabled    
    public static Map<String, Object> getUserDetails(){
        Map<String, Object> userDetails = new Map<String,Object>();
        
        User u = getCurrentUser();
        String nickName = u.CommunityNickname;
        String smallPhotoUrl = u.SmallPhotoUrl;
        String accountId = getAssociatedAccount(u);
        
        userDetails.put('nickName', nickName);
        userDetails.put('photoUrl', smallPhotoUrl);
        userDetails.put('accountId', accountId);
        userDetails.put('isGuest', isGuest());
        
        return userDetails;
    }
    
    @AuraEnabled
    public static void updateTZ(String tzValue){
        User u = getCurrentUser();

        u.TimeZoneSidKey = tzValue;

        update u;        
    }
    
    @AuraEnabled
    public static void updateNetworkMember(Boolean EndorsementEmail, Boolean ProfilePostEmail, Boolean FollowersEmail,
                                             Boolean LikeEmail, Boolean ChangeCommentEmail, Boolean ProfPostCommentEmail,
                                             Boolean LaterCommentEmail, Boolean BookmarkEmail, Boolean CommentAfterLikeEmail,
                                             Boolean MentionsPostEmail, Boolean MentionsCommentEmail, Boolean BestAnswerEmail,
                                             Boolean ItemFlaggedEmail, Boolean DirectMessageEmail, Boolean PendingReviewEmail,
                                             Boolean CaseContactEmail, Boolean AllFeedsEmail){
        NetworkMember nm = getMemberSettings();
        
        nm.PreferencesDisableEndorsementEmail = EndorsementEmail;
        nm.PreferencesDisableProfilePostEmail = ProfilePostEmail;
        nm.PreferencesDisableAllFeedsEmail = AllFeedsEmail;
        nm.PreferencesDisableFollowersEmail = FollowersEmail;
        nm.PreferencesDisableLikeEmail = LikeEmail;
        nm.PreferencesDisableChangeCommentEmail = ChangeCommentEmail;
        nm.PreferencesDisProfPostCommentEmail = ProfPostCommentEmail;
        nm.PreferencesDisableLaterCommentEmail = LaterCommentEmail;
        nm.PreferencesDisableBookmarkEmail = BookmarkEmail;
        nm.PreferencesDisCommentAfterLikeEmail = CommentAfterLikeEmail;
        nm.PreferencesDisableMentionsPostEmail = MentionsPostEmail;
        nm.PreferencesDisMentionsCommentEmail = MentionsCommentEmail;
        nm.PreferencesDisableItemFlaggedEmail = ItemFlaggedEmail;
        nm.PreferencesDisableBestAnswerEmail = BestAnswerEmail;
        nm.PreferencesDisableDirectMessageEmail = DirectMessageEmail;
        nm.PreferencesDisablePendingReviewEmail = PendingReviewEmail;                                         
        nm.PreferencesDisableCaseContactEmail = CaseContactEmail;                                         
                                                                                                
        update nm;
                                                 
    }
    @AuraEnabled
    public static Map<String,String> getUserPicVisibility(){
        Map<String,String> mResult = new Map<String,String>();
        
        String sFlag = '';
        String sImgUrl = '';
        
        User u = getCurrentUser();
        sFlag = u.UserPreferencesShowProfilePicToGuestUsers ? 'true' : 'false';
        sImgUrl = u.SmallPhotoUrl;
        
        mResult.put('imgUrl', sImgUrl);
        mResult.put('flag', sFlag);
        
        return mResult;
    }
    
    @AuraEnabled
    public static void updateUserPicVisibility(String picVisibility){
        User u = getCurrentUser();
        Boolean bSet = false;
        if (picVisibility == 'true')
            bSet = true;

        u.UserPreferencesShowProfilePicToGuestUsers = bSet;
        
        update u;
    }
    
    public class timeZoneOptions {
        @AuraEnabled
        public String optionLabel;
        @AuraEnabled
        public String optionValue;
        
        timeZoneOptions(String label, String value){
            optionLabel = label;
            optionValue = value;
        }
    }
}