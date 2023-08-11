@isTest 
public class CreditPersonNewTest 
{
    
    @TestSetup
    static void initData()
    {
        //Creating US Credit Policy
        forseva1__CreditPolicy__c us_cp = new forseva1__CreditPolicy__c(name = 'US', forseva1__Default_Policy__c = true, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
        insert us_cp;
        
        //Creating Accounts      
        Date bdate = Date.Today()-100;  
        List<Account>  aclist = new List<Account>();
        aclist.add(new Account(name = 'Cambridge', forseva1__Credit_Policy__c = us_cp.Id, Custom_Name__c = 'test person' ));
        insert aclist;
        
        List<Contact> contactList = new List<Contact>();
        Contact contact1 = new Contact(FirstName = 'PG1', LastName = 'Contact', AccountId = aclist[0].Id, Role__c='Administrative', Email='tom@test.com');
        contactList.add(contact1);
        insert contactList;
        
    }
    
    
  static testMethod void generateReportUnitTest() 
  {
        
    Account account1 = [select Id from Account where name = 'Cambridge'];
    
        Test.StartTest();
        
        CreditPersonNew creditPerson = new CreditPersonNew();
        creditPerson.getCreditSubject(account1.Id);
        
        Test.stopTest();
        
  }
    
    
    static testMethod void generateContactforMultipleContacts() 
  {
        
    Account account1 = [select Id from Account where name = 'Cambridge'];
        
        
        Contact contact2 = new Contact(FirstName = 'PG2', LastName = 'Contact2', AccountId = account1.Id, Role__c='Administrative', Email='tim@test.com');
        insert contact2;
        
    Test.StartTest();
        
        CreditPersonNew creditPerson = new CreditPersonNew();
        creditPerson.getCreditSubject(account1.Id);
        
        Test.stopTest();
  }
  
  static testMethod void ParamUnitTest() 
  {
        
    Account account1 = [select Id from Account where name = 'Cambridge'];
    Contact cnt1 = [select Id from Contact where Account.name = 'Cambridge'];
    
        Test.StartTest();
        
        CreditPersonNew creditPerson = new CreditPersonNew();
        creditPerson.getCreditSubject(account1.Id);
        String parmpass = 'we:11';
        //System.assertNotEquals(null, creditPerson.getCreditBureauRequestParametersPub(parmpass));
        
        Test.stopTest();
        
  }
    
    
}