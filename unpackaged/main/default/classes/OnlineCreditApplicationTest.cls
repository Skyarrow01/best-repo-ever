/**
    This is the test class for Apex Class - OnlineCreditApplicationUtil
**/
@isTest
public class OnlineCreditApplicationTest {

    @isTest
    static void testInsertAccount(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.CID__c = '88889999';
        insert acc;
        test.startTest();
        forseva1__OnlineCreditApplication__c oca = new forseva1__OnlineCreditApplication__c();
        oca.forseva1__Business_Name__c = 'Test+Acc';
        oca.Title_in_Business__c = 'Test+Business';
        oca.Account_ID__c = acc.Id;
        oca.Billing_Country__c = 'US';
        oca.Physical_Country__c = 'US';
        oca.Customer_ID__c = '88889999';
        oca.forseva1__Billing_City__c = 'NEW';
        oca.forseva1__Billing_Zip_Postal_Code__c = '1234';
        oca.Billing_State_Province__c = 'Test';
        oca.forseva1__Billing_Address__c = 'Test';
        oca.forseva1__Phone__c = '1231231231';
        insert oca;
        
        oca.forseva1__Billing_City__c = 'Bhopal';
        update oca;
        test.stopTest();
    }
    
    @isTest
    static void testInsertCAAccount(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        forseva1__OnlineCreditApplication__c oca = new forseva1__OnlineCreditApplication__c();
        oca.forseva1__Business_Name__c = 'Test+Acc';
        oca.Title_in_Business__c = 'Test+Business';
        oca.Account_ID__c = acc.Id;
        oca.Billing_Country__c = 'Canada';
        oca.Physical_Country__c = 'Canada';
        oca.forseva1__Billing_City__c = 'NEW';
        oca.forseva1__Billing_Zip_Postal_Code__c = '1234';
        oca.Billing_State_Province__c = 'Test';
        oca.forseva1__Billing_Address__c = 'Test';
        oca.forseva1__Phone__c = '1231231231';
        insert oca;
    }
    
    @isTest
    static void testOCAMail(){
        Online_Credit_Application__c oca = new Online_Credit_Application__c();
        oca.Name = 'URL';
        oca.Value__c = 'https://automationdirectinc--dev.sandbox.my.salesforce-sites.com/CreditApplication';
        insert oca;
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.CID__c = 'A001';
        insert acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'Test';
        con.LastName = '12342r';
        con.Email = 'test@test.com';
        con.MobilePhone = '1234567890';
        con.Title = 'Electrical';
        con.Role__c = 'Administrative';
        insert con;
        CreditFormController.navigateToCreditForm(String.valueOf(acc.Id));
    }
}