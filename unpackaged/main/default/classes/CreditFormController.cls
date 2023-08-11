/*******
This class is implemented by Equifax.
This class is used to create the form URL and sending email to the contact.

**********/
public class CreditFormController {

    @AuraEnabled
    public static void navigateToCreditForm(String recId){
        System.debug('Record ID: '+recId);
        List<Contact> cont = [Select Id, Name, AccountId from Contact where Id =: recId LIMIT 1];
        List<Id> accId = new List<Id>();
        Account acc = new Account();
        for(Contact con: cont){
           accId.add(con.AccountId);
        }
        if(accId.size()!=0 && accId.size()==1){
        acc = getAccountDetails(accId[0]);
        }
        String mailBody;
        String email;
        if(acc != null){
            String url;
            String name;
            Online_Credit_Application__c oca = Online_Credit_Application__c.getValues('URL');
            if(oca != null && oca.Value__c != null)
                url = oca.Value__c;
            //url = 'https://automationdirectinc--dev.sandbox.my.salesforce-sites.com/CreditApplication';
            if(acc.Id != null){
                url += '?Id=' + acc.Id;
                url += '&Name=' + acc.Name;
                String custId = acc.CID__c;
                url += '&CustomerID=' + (String.isNotBlank(custId) ? custId:'');
                //url += '&CustomerId=' + acc.CID__c;
                Contact con = getContactDetails(acc.Id);
                if(con != null){
                    if(con.Name != null)
                        name = con.Name;
                    if(con.firstName != null)
                        url += '&FirstName=' + con.FirstName;
                    if(con.LastName != null)
                        url += '&LastName=' + con.LastName;
                    if(con.Email != null){
                        url += '&Email=' + con.Email;
                        email = con.Email;
                    }
                    if(con.MobilePhone != null)
                        url += '&Phone=' + con.MobilePhone;
                    if(con.Title != null)
                        url += '&Title=' + con.Title;
                }
                //mailBody = draftMailBody(name, url);
            }
        }
        // email is mandatory field on Contact
        if(email != null){
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            
            EmailTemplate emailTemp =  [Select Id,
                                        Subject,
                                        Body
                                        from EmailTemplate  
                                        WHERE DeveloperName='Online_Credit_Application_template'];
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where displayname = 'AutomationDirect Credit'];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) {
    		mail.setOrgWideEmailAddressId(owea.get(0).Id);
			}
            mail.setTemplateId(emailTemp.Id);
            mail.setTargetObjectId(cont[0].Id);
            mailList.add(mail);
            
            if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList);
            }
        }
    }
    
    public static Account getAccountDetails(String recId){
        Account acc = [Select Id, Name, CID__c, Email__c from Account Where Id = :recId];
        return acc;
    }
    
    public static Contact getContactDetails(String accId){
        Contact con = [Select Id, Name, FirstName, LastName, Email, MobilePhone, Title 
                       From Contact 
                       Where AccountId = :accId 
                       Order By LastModifiedDate Desc 
                       Limit 1];
        return con;
    }
    
}