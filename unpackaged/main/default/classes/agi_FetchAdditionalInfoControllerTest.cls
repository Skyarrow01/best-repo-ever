@isTest
public class agi_FetchAdditionalInfoControllerTest {

    @testSetup static void setup(){
        Community_Customization__c customizationsTC = new Community_Customization__c();
        customizationsTC.Name = 'Terms And Conditions';
        customizationsTC.Value__c = 'Some text';
            
        insert customizationsTC;
    }
    
    @isTest
    static void test1(){
        String tcText = agi_FetchAdditionalInfoController.getTermsAndConditionsText();
        System.assert(tcText != '');
    }
    
    @isTest
    static void test2(){
        String token = agi_FetchAdditionalInfoController.handleSubmit('Bob', 'Jones', 'bjonestestxxx', true);
        System.assert(token != '');
    }
    
}