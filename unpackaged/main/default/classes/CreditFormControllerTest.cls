@isTest
public class CreditFormControllerTest {
    @isTest
    static void testInsertAccount(){
        test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Contact con = new Contact();
        con.Title = 'Mr.'; 
        con.FirstName = 'FirstName';
        con.LastName = 'Test';
        con.Role__c = 'Executive';
        con.AccountId = acc.Id;
        con.Email = 'xyz@test123.com';
        con.MobilePhone = '8889996644';
        insert con;
        
        CreditFormController.navigateToCreditForm(con.Id);
        CreditFormController.getAccountDetails(acc.Id);
        
        Contact cont = [Select Id, Name, AccountId from Contact where Id =: con.Id LIMIT 1];
        CreditFormController.getContactDetails(acc.Id);
        forseva1__OnlineCreditApplication__c oca = new forseva1__OnlineCreditApplication__c();
        oca.forseva1__Business_Name__c = 'Test+Acc';
        oca.Title_in_Business__c = 'Test+Business';
        oca.Account_ID__c = acc.Id;
        oca.Billing_Country__c = 'US';
        oca.Physical_Country__c = 'US';
        oca.forseva1__Billing_City__c = 'NEW';
        oca.forseva1__Billing_Zip_Postal_Code__c = '1234';
        oca.Billing_State_Province__c = 'Test';
        oca.forseva1__Billing_Address__c = 'Test';
        oca.forseva1__Phone__c = '1231231231';
        insert oca;
        test.stopTest();
    }
}