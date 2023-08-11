@isTest
public class SocialRegHandler_Test {
    
    @isTest
    public static void registrationHandlerTest() {
        SocialRegHandler handler = new SocialRegHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast12345678',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'auth0',
            null, new Map<String, String>{'language' => 'en_US', 'full_name' => 'testFirst testLast12345678', 'nickname' => 'yo'});
        User u = handler.createUser(null, sampleData);
        System.assertEquals('testuser@example.org.adc', u.userName);
        System.assertEquals('testuser@example.org', u.email);
        System.assertEquals('testLast12345678', u.lastName);
        System.assertEquals('testFirst', u.firstName);
        insert(u);
        String uid = u.id;
        
    }
    
    @isTest
    public static void handlerUpdateTest() {
        SocialRegHandler handler = new SocialRegHandler();
        Auth.UserData sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
            'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'auth0',
            null, new Map<String, String>{'nickname'=>'communityNickname'});
        handler.updateUser([SELECT Id FROM User WHERE contactId != null LIMIT 1][0].Id, null, sampleData);
    }
    

}