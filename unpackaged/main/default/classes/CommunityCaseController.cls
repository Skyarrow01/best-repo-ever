// Class without sharing to allow guest Contact and Case creates
public without sharing class CommunityCaseController {

    static Account quickCallAccount = null;

    public CommunityCaseController() {
        System.debug('CommunityCaseController constuctor called yes!');
    }

    @TestVisible 
    private static Account getQuickCallAccount() {
        if (quickCallAccount == null) {
            String quickCall = 'Quick Call (Do not change)';
            List<Account> accounts = [
                SELECT Id, Name
                FROM Account 
                WHERE Name = :quickCall 
                ORDER BY CreatedDate DESC
            ];
            
            if (accounts.isEmpty()) {
                Account a = new Account(name = quickCall);
                insert(a);
                quickCallAccount = a;
            } else {
                quickCallAccount = accounts.get(0);
            }

        }
        return quickCallAccount;

    }

    @TestVisible 
    private static Contact getContactForCase(String email, String name, String phone) {
        List<Contact> contacts = [SELECT Id, Name, email, phone
                                    FROM Contact
                                    WHERE email = :email];
        // Check for empty          
        System.debug('Getting Contact for email: ' + email + ' found ' + contacts.size());
        if (contacts.isEmpty()) {
            return createQuickCallContact(email, name, phone);
        }    
        return contacts[0];
    }

    
    @TestVisible 
    private static Contact createQuickCallContact(String email, String name, String phone) {
        // Split into first and last names for insert
        String[] names = name.split(' ', 2);
        Account qcAccount = getQuickCallAccount();
        Contact c = new Contact();
        c.accountId = qcAccount.Id;
        c.firstName = names[0];
        c.lastName  = names.size() > 1 ? names[1] : '';
        c.email = email;
        c.Direct_Phone__c = phone;
        c.Role__c = 'Technical';
        c.ownerId = ID.valueOf(ConfigObjectId__mdt.getInstance('DefaultUserId').ObjectId__c);
        c.verified__c = true;

        insert(c);
        System.debug('Created Contact first: ' + names[0] + ' last: ' + names[1] );
        return c;
    }

    @TestVisible 
    private static Id getProductId(String itemCode) {
        if (String.isEmpty(itemCode)) return null;

        List<Product2> products = [SELECT Id, Name
            FROM product2
            WHERE name = :itemCode];
        if (products.isEmpty()) return null;
        return products[0].Id;
    }

    private static Id getProfileSkillId(String profileSkillName) {
        List<ProfileSkill> psList = [select id from profileskill where name = :profileSkillName];
        if (psList.isEmpty()) return null;
        return psList[0].Id;
    }

    // Using a trigger flow to send email instead of this method due to the SF short coming of not allowing the 
    // the Community Profile to be used by the Org Wide Addresses - https://ideas.salesforce.com/s/idea/a0B8W00000GdjQGUAZ/allow-sites-profiles-use-of-organizationwide-email-addresses
    // private static void sendAckEmail(Case newCase, Id contactId) {
    //     OrgWideEmailAddress fromAddress = [SELECT id FROM OrgWideEmailAddress WHERE address = 'techinquiries@automationdirect.com'];
    //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //     message.setTargetObjectId(contactId); 
    //     message.setWhatId(newCase.Id);
    //     message.setOrgWideEmailAddressId(fromAddress.Id); 
    //    // message.setReplyTo(from.address);
    //     message.setUseSignature(false); 
    //     message.setBccSender(false); 
    //     //message.setSaveAsActivity(false); 
    //     EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Community_Case_Created'];
    //     message.setTemplateID(emailTemplate.Id); 
    //     //message.setWhatId(account.Id); //This is important for the merge fields in template to work
    //     message.toAddresses = new String[] { newCase.SuppliedEmail};
    //     Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        
    //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
      
    //     if (results[0].success) 
    //     {
    //         System.debug('The email was sent successfully.');
    //     } else {
    //         System.debug('The email failed to send: ' +  results[0].errors[0].message);
    //     }
    // }

    @AuraEnabled
    public static String createCase(String name, String email, String phone,
                                    String product, String productGroup, String subject, String description) {
        System.debug('CommunityCaseController.createCase for name: ' + name + ' email: ' + email);
        System.debug('CreateCase subject: ' + subject + '\n desc: ' + description);

        // Validations, have everything?

        // Look up contact from email or Create Contact if not found
        Contact contact = getContactForCase(email, name, phone);
        System.debug('Got contact for case : '+ contact);

        Id productId = getProductId(product);
        System.debug('Got product = [' + product + '] productId: [' + productId +']');

        Id skillId = getProfileSkillId(productGroup);
        System.debug('Got productGroup = [' + productGroup + '] skillId: [' + skillId +']');
 
        // Create case
        Case tsCase = new Case();
        tsCase.ContactId = contact.Id;
        tsCase.origin = 'Web';
        tsCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email and Web').getRecordTypeId();
        tsCase.status = 'Open';
        tsCase.Phone__c = phone;
        tsCase.SuppliedName = name;
        tsCase.SuppliedEmail = email;
        tsCase.SuppliedPhone = phone;
        tsCase.Product__c = productId;
        // NOTE: Want to learn why do we need BOTH Product Group fields??? 
        // had to add Product_Group__C to make a validation rule happy!!
        tsCase.Product_Group__C = productGroup;
        tsCase.Tech_Product_Group__c = skillId;
        tsCase.Subject = subject;
        tsCase.Description = description;

        insert(tsCase);

        //Load the caseNumber that just got created so can return it, and everything else so Ack email can use it
        Case newCase = [select Id, caseNumber, contactId, SuppliedName, SuppliedEmail, SuppliedPhone, subject, description from Case where id=:tsCase.id ];
        // Using using a trigger flow send ack email, see note above related to this method                       
        // sendAckEmail(newCase, contact.Id);    

        return newCase.CaseNumber;
    }

    @AuraEnabled(Cacheable = true)
    public static list<Product2> searchProducts(String itemCode) {
        itemCode = '%' + itemCode + '%';
        list<Product2> productList = [SELECT  Id, Name From Product2 WHERE Name LIKE :itemCode LIMIT 10];

        // if(productList.isEmpty()) {
        //     throw new AuraHandledException('No Matching Products Found..');
        // }
        return productList; 
    }
}