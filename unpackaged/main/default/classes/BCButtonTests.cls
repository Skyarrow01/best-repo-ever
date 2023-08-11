@isTest
private class BCButtonTests {
   
    static testMethod void BCEFXVerify() {
        
        setUpPolicies();
        Id m_USPolicyId ;
        List<forseva1__CreditPolicy__c> cp = [select Id,Name from forseva1__CreditPolicy__c where name='US' LIMIT 1];
        for (forseva1__CreditPolicy__c policy : cp) {
                m_USPolicyId = policy.Id;
        }
                
        Account ac = new Account(name='Test AC 1',billingstreet='29 S. LaSalle', billingcity='Chicago', billingState='Illinois',
                                   billingCountry='United States', billingPostalCode='30004', 
                                   phone = '2812223333');
        insert ac;
        
        Test.startTest ();
        BCEfxVerify con = new BCEfxVerify(new ApexPages.StandardController(ac));
        con.startCreditPull();
        Test.stopTest();
        
    }

    static testMethod void BCEFXReview() {
        setUpPolicies();
        Id m_USPolicyId ;
        List<forseva1__CreditPolicy__c> cp = [select Id,Name from forseva1__CreditPolicy__c where name='US' LIMIT 1];
        for (forseva1__CreditPolicy__c policy : cp) {
                m_USPolicyId = policy.Id;
        }
                
        Account ac = new Account(name='Test AC 1',billingstreet='29 S. LaSalle', billingcity='Chicago', billingState='Illinois',
                                   billingCountry='United States', billingPostalCode='30004', 
                                   phone = '2812223333');
        insert ac;
        
        Test.startTest ();
        BCEfxReview con = new BCEfxReview(new ApexPages.StandardController(ac));
        con.startCreditPull();
        Test.stopTest();
        
    }
    
    static testMethod void BCExperianVerify() {
        setUpPolicies();
        Id m_USPolicyId ;
        List<forseva1__CreditPolicy__c> cp = [select Id,Name from forseva1__CreditPolicy__c where name='US Experian' LIMIT 1];
        for (forseva1__CreditPolicy__c policy : cp) {
                m_USPolicyId = policy.Id;
        }
                
        Account ac = new Account(name='Test AC 1',billingstreet='29 S. LaSalle', billingcity='Chicago', billingState='Illinois',
                                   billingCountry='United States', billingPostalCode='30004', 
                                   phone = '2812223333');
        insert ac;
        
        Test.startTest ();
        BCExpVerify con = new BCExpVerify(new ApexPages.StandardController(ac));
        con.startCreditPull();
        Test.stopTest();
        
    }
    
    static testMethod void BCExperianReview() {
        setUpPolicies();
        Id m_USPolicyId ;
        List<forseva1__CreditPolicy__c> cp = [select Id,Name from forseva1__CreditPolicy__c where name='US Experian' LIMIT 1];
        for (forseva1__CreditPolicy__c policy : cp) {
                m_USPolicyId = policy.Id;
        }
                
        Account ac = new Account(name='Test AC 1',billingstreet='29 S. LaSalle', billingcity='Chicago', billingState='Illinois',
                                   billingCountry='United States', billingPostalCode='30004', 
                                   phone = '2812223333');
        insert ac;
        
        Test.startTest ();
        BCExpReview con = new BCExpReview(new ApexPages.StandardController(ac));
        con.startCreditPull();
        Test.stopTest();
        
    }
    
    static testMethod void BCEFXCAVerify() {
        setUpPolicies();
        Id m_USPolicyId ;
        List<forseva1__CreditPolicy__c> cp = [select Id,Name from forseva1__CreditPolicy__c where name='Canada' LIMIT 1];
        for (forseva1__CreditPolicy__c policy : cp) {
                m_USPolicyId = policy.Id;
        }
                
        Account ac = new Account(name='Test AC 1',billingstreet='29 S. LaSalle', billingcity='Chicago', billingState='Illinois',
                                   billingCountry='Canada', billingPostalCode='30004', 
                                   phone = '2812223333');
        insert ac;
        
        Test.startTest ();
        BCEfxCAVerify con = new BCEfxCAVerify(new ApexPages.StandardController(ac));
        con.startCreditPull();
        Test.stopTest();
    }
    
    
    static testMethod void BCEFXCAReview() {
        setUpPolicies();
        Id m_CAPolicyId ;
        List<forseva1__CreditPolicy__c> cp = [select Id,Name from forseva1__CreditPolicy__c where name='Canada' LIMIT 1];
        for (forseva1__CreditPolicy__c policy : cp) {
                m_CAPolicyId = policy.Id;
        }
                
        Account ac = new Account(name='Test AC 1',billingstreet='29 S. LaSalle', billingcity='Chicago', billingState='Illinois',
                                   billingCountry='Canada', billingPostalCode='30004', 
                                   phone = '2812223333');
        insert ac;
        
        Test.startTest ();
        BCEfxCAReview con = new BCEfxCAReview(new ApexPages.StandardController(ac));
        con.startCreditPull();
        Test.stopTest();
    }
    
    
    static void setUpPolicies() {

        List<forseva1__CreditPolicy__c> cplist = [select id from forseva1__CreditPolicy__c where name = 'US'];      
        if (cplist.size() == 0) {
            forseva1__CreditPolicy__c us_cp = new forseva1__CreditPolicy__c(name = 'US', forseva1__Default_Policy__c = true, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
            insert us_cp;
        }


        cplist = [select id from forseva1__CreditPolicy__c where name = 'US Experian'];      
        if (cplist.size() == 0) {
            forseva1__CreditPolicy__c credit_cp = new forseva1__CreditPolicy__c(name = 'US Experian', forseva1__Default_Policy__c = false, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
            insert credit_cp;
        }

        cplist = [select id from forseva1__CreditPolicy__c where name = 'Canada'];      
        if (cplist.size() == 0) {
            forseva1__CreditPolicy__c credit_ca = new forseva1__CreditPolicy__c(name = 'Canada', forseva1__Default_Policy__c = false, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
            insert credit_ca;
        }
        
        
    }
}