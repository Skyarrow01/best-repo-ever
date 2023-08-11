public without sharing class agi_EmailHandler {
    private static final List<EskerSettings__c> integrationSettings = [SELECT Auto_Trigger_Enabled__c,
                                                    Esker_Notification_Email__c,
                                                    Global_Enabled__c 
                                                 FROM EskerSettings__c
                                                    WHERE Name = 'Default']; 

    @AuraEnabled
    public static boolean forwardToEsker(Id caseId)
    {
        // utilized by the push button on lightning component
        boolean bSuccessFlag = null;
        
        if (!integrationEnabled())
            return false;
        
        Case theCase = [SELECT CaseNumber, Id, Latest_Sent_to_Esker__c
                                FROM Case
                                WHERE Id = :caseId
                            LIMIT 1];
   
        DateTime lastEskerDT = theCase.Latest_Sent_to_Esker__c;
        List<EmailMessage> emails = getAllEmailForCase(caseId, lastEskerDT);
        List<Id> emailIds = new List<Id>();

        for (EmailMessage mail : emails){
            emailIds.add(mail.Id);
        }
        
        String emailSubject = 'FW: SalesForce Case#: ' + theCase.CaseNumber;
        String emailBody = generateBody(emails);
        List<Messaging.EmailFileAttachment> oldEmails = generateHtmlAttachments(emails);
        
        bSuccessFlag = sendEmail(emailSubject, emailBody, getRecipientEmail(), caseId, emailIds, false, oldEmails);
        
        return bSuccessFlag;
    }

    private static String generateBody(List<EmailMessage> emails)
    {
        String messageBody = '--------------- Forwarded Message ---------------\r\n<br>';
        String messageFromName = String.isBlank(emails[0].FromName) ? '' : emails[0].FromName;
        String messageFromEmail = String.isBlank(emails[0].FromAddress) ? '' : emails[0].FromAddress;
        String messageSubj = String.isBlank(emails[0].Subject) ? '' : emails[0].Subject;
        
        List<String> emailHeaders = new List<String>{messageFromName, messageFromEmail};
        
        messageBody += String.format('From: {0} [{1}]\r\n<br>', emailHeaders);
        messageBody += String.format('Sent: {0}\r\n<br>', new List<String>{(emails[0].MessageDate).format('M/d/yyyy h:mm a')});
        messageBody += 'To: orders@automationdirect.com\r\n<br>';
        messageBody += String.format('Subject: {0}\r\n\r\n<br><br>', new List<String>{messageSubj});
        
        return messageBody;
    }
    
    public static List<EmailMessage> getAllEmailForCase(Id caseId, DateTime eskeredDT)
    {
        List<EmailMessage> emails = null;
        
        if (eskeredDT == null)
            emails = [SELECT FromName, FromAddress, Subject, MessageDate, HasAttachment,HtmlBody,Id,Incoming,ParentId,TextBody 
                                     FROM EmailMessage 
                      WHERE ParentId = :caseId AND
                        Incoming = true];
        else
            emails = [SELECT FromName, FromAddress, Subject, MessageDate, HasAttachment,HtmlBody,Id,Incoming,ParentId,TextBody 
                                     FROM EmailMessage 
                      WHERE ParentId = :caseId AND
                        Incoming = true AND
                        CreatedDate >= :eskeredDT];
                
        return emails;
    }   
    
    private static List<Messaging.EmailFileAttachment> generateHtmlAttachments(List<EmailMessage> emailMsgs){
        List<Messaging.EmailFileAttachment> allHtmls = new List<Messaging.EmailFileAttachment>();
        Integer attachNo = 1;
        
        for (EmailMessage msg : emailMsgs){
            String messageBody = '';
            
            if (!String.isBlank(msg.HtmlBody))
                messageBody += msg.HtmlBody;
            else if (!String.isBlank(msg.TextBody))
                messageBody += (msg.TextBody).replaceAll('\n','<br>');
            else
                messageBody += '';

            if (!String.isBlank(messageBody))
            {
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.body = Blob.valueOf(messageBody);
                attach.contenttype = 'text/html';
                attach.filename = String.format('attachment{0}.html', new List<String>{String.valueOf(attachNo)});
                attach.inline = false;
                
                allHtmls.add(attach);
                attachNo++;
            }
        }
        
        return allHtmls;
    }
    
    public static boolean sendEmail(Id emailId, Boolean filterPDFs)
    {
        // called directly by the trigger / queued mechanism
        
        boolean bSuccessFlag = null;
        
        EmailMessage email = [SELECT Id, FromName, FromAddress,
                                        Subject, MessageDate, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :emailId LIMIT 1];
        String caseInfo = '';
        if (email.ParentId != null)
        {
            Case theCase = [SELECT CaseNumber FROM case where Id = :email.ParentId LIMIT 1];
            caseInfo = String.format('SalesForce Case#: {0}', new List<String>{theCase.CaseNumber});
        }
        
        String subject = String.format('FW: {0} - {1}', new List<String>{email.Subject, caseInfo});
        String bodyToSend = generateBody(new List<EmailMessage>{email});

        List<Messaging.EmailFileAttachment> oldEmails = generateHtmlAttachments(new List<EmailMessage>{email});
        bSuccessFlag = sendEmail(subject, bodyToSend, getRecipientEmail(), email.ParentId, new List<Id>{emailId}, filterPDFs, oldEmails);

        return bSuccessFlag;
    }
    
    
    public static boolean sendEmail(String subj, 
                                 String htmlBody,
                                 String recip,
                                 Id caseId,
                                 List<Id> emailIds,
                                 Boolean filterPDFs,
                                 List<Messaging.EmailFileAttachment> oldEmails)
    {
        boolean bSentFlag = false;
                                     
        if (emailIds.size() == 0)
            return bSentFlag;
                                     
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subj);
        mail.setToAddresses(new List<String> {recip});
        mail.setHtmlBody(htmlBody);
        mail.setOrgWideEmailAddressId(findDefaultSender());

        if (oldEmails != null && oldEmails.size() > 0)
            mail.setFileAttachments(oldEmails);
        
        List<String> attachmentIds = getLatestAttachments(emailIds, filterPDFs);
        if (attachmentIds.size() > 0)                                     
            mail.setEntityAttachments(attachmentIds); 
        string caseStatus = 'Open';

        if ((filterPDFs && attachmentIds.size() > 0) || !filterPDFs)
        {
            List<Messaging.Email> mailsToSend = new List<Messaging.Email>();
            mailsToSend.add(mail);
            Messaging.sendEmail(mailsToSend);
            caseStatus='Sent to Esker';
            bSentFlag = true;
        }
        if (caseId != null) updateCase(caseId, caseStatus, bSentFlag);        

        return bSentFlag;
    }
    
    private static Id findDefaultSender(){
        List<OrgWideEmailAddress> confEmails = [SELECT Id, Address
                                               FROM OrgWideEmailAddress
                                               WHERE Address = 'donotuse-salesforcetoesker@automationdirect.com'];
        
        if (confEmails.size() == 0)
            throw new NoDataFoundException();
        else
            return confEmails.get(0).Id;
    }
    
    public static List<String> getLatestAttachments(List<Id> emailIds, Boolean filterPDF)
    {
        List<String> docIds = getAttachmentIds(emailIds, filterPDF);
        List<String> returnVersionIds = new List<String>();
        
        List<ContentVersion> latestDocs = [SELECT Id FROM ContentVersion
                                    WHERE ContentDocumentId in :docIds
                                        AND IsLatest = true];

        for (ContentVersion versionId : latestDocs )
        {
           returnVersionIds.add(versionId.Id); 
        }
        
        return returnVersionIds;     
    }

    private static List<String> getAttachmentIds(List<Id> emailIds, Boolean filterPDF)
    {
        List<String> returnIds = null;
        Set<String> docIds = new Set<String>();
        
        List<ContentDocumentLink> links = [SELECT Id, ContentDocumentId FROM ContentDocumentLink
                                          WHERE LinkedEntityId in :emailIds];

        for(ContentDocumentLink link : links)
        {
            docIds.add(link.ContentDocumentId);            
        }
        
        if (filterPDF)
        {
            Set<String> filteredDocIds = filterPDFs(docIds);
            returnIds = new List<String>(filteredDocIds);
        }
        else
            returnIds = new List<String>(docIds);
        
        return returnIds;
    }

    private static Set<String> filterPDFs(Set<String> unfilteredDocIds)
    {
        Set<String> filteredDocs = new Set<String>();
        
        List<ContentDocument> docs = [SELECT Id 
                                        FROM ContentDocument
                                        WHERE Id in :unfilteredDocIds
                                            AND FileType in ('PDF', 'WORD', 'WORD_X', 'EXCEL', 'EXCEL_X', 'HTML')];
        
        for(ContentDocument aDoc : docs)
        {
            filteredDocs.add(aDoc.Id);    
        }

        return filteredDocs;        
    }
    
    private static String getRecipientEmail()
    {
        String recip = null;
        
        if (integrationSettings.size() > 0){
            String configRecip = integrationSettings[0].Esker_Notification_Email__c;
            
            recip = configRecip;
        }
        
        return recip;
            
    }
    
    private static boolean integrationEnabled()
    {
        boolean bFlag = false;

        if (integrationSettings.size() > 0){
            boolean bGlobal = integrationSettings[0].Global_Enabled__c;
            
            if (bGlobal == true)
                bFlag = true;
        }
        
        return bFlag;
    }

    public static boolean triggerEnabled()
    {
        boolean bFlag = false;

        if (integrationSettings.size() > 0){
            boolean bTrigger = integrationSettings[0].Auto_Trigger_Enabled__c;
            
            if (integrationEnabled() && bTrigger)
                bFlag = true;
        }
        
        return bFlag;
    }

    public static void updateCase(Id caseId, string caseStatus, Boolean bSentFlag)
    {
        if (bSentFlag)
            update new Case(Id=caseId, Status=caseStatus, Latest_Sent_to_Esker__c=DateTime.now(), Reason='Order - New');       
        else 
            update new Case(Id=caseId, Status=caseStatus);       

    }
    
    @AuraEnabled
    public static boolean enableButton(){
        return integrationEnabled();
    }
}