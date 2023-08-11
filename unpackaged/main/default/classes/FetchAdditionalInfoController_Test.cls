@isTest
public class FetchAdditionalInfoController_Test {

    @isTest
    public static void createSignedJWTTest() {
        
        String JWTTOken = FetchAdditionalInfoController.handleSubmit('Zameer', 'Vohra', 'ZVNick', true);
    }
}