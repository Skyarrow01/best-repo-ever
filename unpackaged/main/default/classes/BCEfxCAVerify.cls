public with sharing class BCEfxCAVerify {
    
    Account m_acct;
    
    public BCEfxCAVerify (ApexPages.StandardController stdController) {
        m_acct = (Account) stdController.getRecord();
    }
    
    public ApexPages.PageReference startCreditPull() {
        try {
            //credit policy id for Paynet
            List<forseva1__CreditPolicy__c> cplist = [select id from forseva1__CreditPolicy__c where name = 'Canada'];      
            Account acct = [Select id, forseva1__Credit_Policy__c from Account where id =: m_acct.Id LIMIT 1];
            
            if (cplist.size() != 0) {
                for (forseva1__CreditPolicy__c cp : cplist){
                    if (acct.forseva1__Credit_Policy__c != cp.id) {
                        acct.forseva1__Credit_Policy__c  = cp.id;
                        update acct;
                    }
                }
            }
            
            //  PageReference pqPage = Page.forseva1__CreditReview;
            //  PageReference pqPage = Page.forseva1__AccountPrequalification;
            PageReference pqPage = Page.forseva1__AccountVerificationList;
            //pqPage.setRedirect(true);   
            pqPage.getParameters().put('id', acct.Id);
            return pqPage; 
            
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return ApexPages.currentPage();         
        }
    }
}