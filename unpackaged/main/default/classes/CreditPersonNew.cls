global with sharing class CreditPersonNew extends forseva1.CreditPersonDefault {
    
   global override virtual List<forseva1.Person> getCreditSubject(ID acctId) {
      return getCreditSubjectPub(acctId);    
   }
    
    /* global override virtual List<String> getCreditBureauRequestParameters(String parameterString) {
        return getCreditBureauRequestParametersPub(parameterString);
    }   */ 
    
    public List<forseva1.Person> getCreditSubjectPub(ID acctId) {
        
        List<Account> accts = [Select id, Custom_Name__c, Custom_Street__c, Custom_City__c, Custom_State_Province__c, Custom_Postal_Code__c From Account where Id = :acctId];
        
        List<forseva1.Person> persons = new List<forseva1.Person>();
        for (Account at : accts) {
            forseva1.Person p = new forseva1.Person();
            p.UnparsedAddress = at.Custom_Street__c;
            p.City = at.Custom_City__c;
            //added to split the name into two fields
            if(at.Custom_Name__c != '') {
                if(at.Custom_Name__c.trim().length() > 0 && at.Custom_Name__c.Contains(' ')) {
                    p.FirstName = at.Custom_Name__c.Substring(0,at.Custom_Name__c.indexOf(' '));
                    p.LastName = at.Custom_Name__c.Substring(at.Custom_Name__c.indexOf(' '),at.Custom_Name__c.Length());
                }
                else {
                    p.FirstName = 'null';
                    p.LastName = at.Custom_Name__c;
                }
            }
            p.PostalCode = at.Custom_Postal_Code__c ;
            p.State = at.Custom_State_Province__c;
           
            //p.personId = at.id;
            //p.SSN = at.SSN__c;
            
            persons.add(p);
            
        } 
        /*List<Contact> contacts = [Select MailingStreet, MailingState, MailingPostalCode, MailingCity, LastName, Id, FirstName,  SSN__c From Contact  where accountId = :acctId];
        
        List<forseva1.Person> persons = new List<forseva1.Person>();
        for (Contact ct : contacts) {
            forseva1.Person p = new forseva1.Person();
            p.UnparsedAddress = ct.MailingStreet;
            p.City = ct.MailingCity;
            p.FirstName = ct.FirstName;
            p.LastName = ct.LastName;
            p.PostalCode = ct.MailingPostalCode;
            p.State = ct.MailingState;
            p.personId = ct.id;
            p.SSN = ct.SSN__c;
            
            persons.add(p);
            
        } */
        

        return persons;        
    }
    
   /* public List<String> getCreditBureauRequestParametersPub(String parameterString) {
        
        List<String> parmList = new List<String>();
        
        String parm = null;
        
        // equifax parms
        parm = 'Flags!BeaconFlag';
        parmlist.add(parm);
        //parm = 'Flags!OnLineDirectoryFlag';
        //parmlist.add(parm);
        //parm = 'Flags!ConsumerReferralLocationFlag';
        //parmlist.add(parm);
        //parm = 'Flags!AlertContactFlag';
        //parmlist.add(parm);
        
       // parm = 'Models!5143';        
       // parmlist.add(parm);
        
        //parm = 'Customer Options!RawFileAppendIndicator:N';        
        //parmlist.add(parm);
        parm = 'Customer Options!PrintImageCDATAInclude:Y';        
        parmlist.add(parm);
        //parm = 'Customer Options!OutputFormat:67';        
        //parmlist.add(parm);
        // account...
        string accountId = null;        
        list<String> nvpList = parameterString.split(',');
        for (String nvp: nvpList) {
           String nm = getNameFromNvp(nvp);
            String val = getValueFromNvp(nvp);
            if (nm == 'accountId') {
                accountId = id.valueOf(val);
             parm = 'accountId!' + accountId;
               parmList.add(parm);
           }
            
       }
        
        
        return parmList;
            }
  
    private String getNameFromNvp(String nvp) {
        list<String> lst = nvp.split(':');
        return lst[0];
    }
    private String getValueFromNvp(String nvp) {
        System.debug(' nvp=' + nvp);
        list<String> lst = nvp.split(':');
        return lst[1];
    } */
}