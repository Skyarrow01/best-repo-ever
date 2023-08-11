/*******
This class is implemented by Equifax.
This class is used to associate OCA form with account and populate address information from OCA form to the account.

**********/
public class OnlineCreditApplicationUtil {
    public static void removeExtraCharacters(List<forseva1__OnlineCreditApplication__c> ocaList){
        for(forseva1__OnlineCreditApplication__c oca : ocaList){
            if(oca.forseva1__Business_Name__c != null && oca.forseva1__Business_Name__c.contains('+')){
                oca.forseva1__Business_Name__c = formatString(oca.forseva1__Business_Name__c);
            }
            if(oca.Title_in_Business__c != null && oca.Title_in_Business__c.contains('+')){
                oca.Title_in_Business__c = formatString(oca.Title_in_Business__c);
            }
        }
    }
    
    public static String formatString(String name){
        List<String> subNames = new List<String>();
        String val;
        System.debug('\n\n Name :: ' + name);
        subNames = name.split('\\+');
        for(String x : subNames){
            if(val == null)
                val = x;
            else
                val += ' ' + x;
        }
        return val;
    }
    public static void populateIdOfAccount(List<forseva1__OnlineCreditApplication__c> ocaList){
        Set<String> accountNumberSet = new Set<String>();
        for(forseva1__OnlineCreditApplication__c oca : ocaList){
            if(oca.Customer_ID__c != null)
                accountNumberSet.add(oca.Customer_ID__c);
        }
        
       	List<Account> acctd = [Select Id, Name, CID__c from Account where CID__c IN: accountNumberSet]; 
        List<Id> IdList = new List<Id>();
        Map<String,Id> customerIDMap = new Map<String,Id>();
        if(!acctd.isEmpty()){
            for(Account acc: acctd){
                customerIDMap.put(acc.CID__c,acc.Id);
            }
        }        
        system.debug('Map size: '+customerIDMap);
        for(forseva1__OnlineCreditApplication__c oca : ocaList){
            if(oca.Account_ID__c != null){
                //oca.Account__c = oca.Account_ID__c;
                oca.Account__c = customerIDMap.get(oca.Customer_ID__c);
            }  else if (oca.Account_ID__c == null && oca.Customer_ID__c != null){
                //Account acc = Select Id from Account where 
                if(customerIDMap.containsKey(oca.Customer_ID__c) && !customerIDMap.isEmpty()){
                    System.debug('AccountID:+++++'+customerIDMap.get(oca.Customer_ID__c));
                    oca.Account__c = customerIDMap.get(oca.Customer_ID__c);
                } else {System.debug('Online Credit application record created');}              
            }        
            if(oca.Billing_Country__c != null && oca.Billing_Country__c == 'United States')
            {
                oca.Billing_Country__c = 'US';
            }else if (oca.Billing_Country__c != null && oca.Billing_Country__c == 'Canada')
            {
                oca.Billing_Country__c = 'CA';
            }
            
            if(oca.Physical_Country__c != null && oca.Physical_Country__c == 'United States')
            {
                oca.Physical_Country__c = 'US';
            }else if (oca.Physical_Country__c != null && oca.Physical_Country__c == 'Canada')
            {
                oca.Billing_Country__c = 'CA';
            }
        }
    } 
    public static void populateAddressOnAccount(List<forseva1__OnlineCreditApplication__c> ocaList){
        Set<Id> accountIdsSet = new Set<Id>();
        for(forseva1__OnlineCreditApplication__c oca : ocaList){
            if(oca.Account__c != null)
                accountIdsSet.add(oca.Account__c);
        }
        if(accountIdsSet != null && accountIdsSet.size() > 0){
            
            Map<Id, Account> accMap = new Map<Id, Account>();
            List<Account> accUpdateList = new List<Account>();
            accMap = fetchAccountDetails(accountIdsSet);
            for(forseva1__OnlineCreditApplication__c oca : ocaList){
                Boolean flagChange = false;
                if(accMap.containsKey(oca.Account__c)){
                    Account acc = accMap.get(oca.Account__c);
                    if((acc.Custom_City__c != oca.forseva1__Billing_City__c) || (acc.Custom_City__c == null)){
                        flagChange = true;
                        acc.Custom_City__c = oca.forseva1__Billing_City__c;
                    }
                    if((acc.Custom_Country__c != oca.Billing_Country__c) || (acc.Custom_Country__c == null)){
                        flagChange = true;
                        acc.Custom_Country__c = oca.Billing_Country__c;
                        acc.forseva1__Credit_Policy__c = getCreditPolicyId(acc.Custom_Country__c);
                    }
                    if((acc.Custom_Postal_Code__c != oca.forseva1__Billing_Zip_Postal_Code__c) || (acc.Custom_Postal_Code__c == null)){
                        flagChange = true;
                        acc.Custom_Postal_Code__c = oca.forseva1__Billing_Zip_Postal_Code__c;
                    }
                    if((acc.Custom_State_Province__c != oca.Billing_State_Province__c) || (acc.Custom_State_Province__c == null)){
                        flagChange = true;
                        acc.Custom_State_Province__c = oca.Billing_State_Province__c;
                    }
                    if((acc.Custom_Street__c != oca.forseva1__Billing_Address__c) || (acc.Custom_Street__c == null)){
                        flagChange = true;
                        acc.Custom_Street__c = oca.forseva1__Billing_Address__c;
                    }
                    if((acc.Custom_Name__c != oca.forseva1__Business_Name__c) || (acc.Custom_Name__c == null)){
                        flagChange = true;
                        acc.Custom_Name__c = oca.forseva1__Business_Name__c;
                    }
                    if((acc.Custom_Phone__c != oca.forseva1__Phone__c) || (acc.Custom_Phone__c == null)){
                        flagChange = true;
                        acc.Custom_Phone__c = oca.forseva1__Phone__c;
                    }
                    
                    if(flagChange == true){
                        accUpdateList.add(acc);
                    }
                }
            }
            if(accUpdateList != null && accUpdateList.size() > 0){
                update accUpdateList;
            }
        }
    }
    public static String getCreditPolicyId (String country){
        String countryName = (country == 'US'?'US':'Canada');
        String creditPolicyID;
        for(forseva1__CreditPolicy__c cp: [SELECT Id, Name 
                                           FROM forseva1__CreditPolicy__c
                                           WHERE Name =:countryName ]){
            creditPolicyID = cp.Id;
        }
        return creditPolicyID;
    }
    public static Map<Id, Account> fetchAccountDetails(Set<Id> accountIds){
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(Account acc : [SELECT Id, Custom_City__c, Custom_Country__c, Custom_Postal_Code__c, Custom_State_Province__c, Custom_Street__c,Custom_Name__c ,Custom_Phone__c 
                           FROM Account
                           WHERE Id IN :accountIds]){
                               accountMap.put(acc.Id, acc);
                           }
        return accountMap;
    } 
	
    public static void populateCountryAndState(List<forseva1__OnlineCreditApplication__c> ocaList){
        List<forseva1__OnlineCreditApplication__c> updateOCAList = new List<forseva1__OnlineCreditApplication__c>();
        
        for(forseva1__OnlineCreditApplication__c oca: ocaList){
            forseva1__OnlineCreditApplication__c updateOCA = new forseva1__OnlineCreditApplication__c(Id=oca.Id);
            updateOCA.Billing_Country__c = oca.Country_Text__c;
            updateOCA.Billing_State_Province__c = oca.Billing_State_Province2__c;
            updateOCA.Physical_Country__c = oca.Country_Physical_Text__c;
            updateOCA.Physical_State_Province__c = oca.Country_Physical_State__c;
            updateOCAList.add(updateOCA);
        }
        if(!updateOCAList.isEmpty()){
            update updateOCAList;
        }
    }
    
}