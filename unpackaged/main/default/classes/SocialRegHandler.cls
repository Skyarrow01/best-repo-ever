global class SocialRegHandler implements Auth.RegistrationHandler{
    
    final String social_account;
    final String community_profile;
    final String standard_profile;
    final String username_append_string;
    final Integer associating_limit;
    
    global SocialRegHandler() {
        //defaulting values from custom metadata 
        List<Community_Registration_Setting__mdt> communitySettingsList = [
            SELECT Id, Associated_Contact_Limit__c, Community_User_Profile_Name__c, Social_Account_Name__c, Standard_User_Profile_Name__c, Username_Appended_String__c
            FROM Community_Registration_Setting__mdt
            LIMIT 1
        ];
        
        if (communitySettingsList.size() > 0) {
            social_account = communitySettingsList[0].Social_Account_Name__c;           
            community_profile  = communitySettingsList[0].Community_User_Profile_Name__c;
            standard_profile = communitySettingsList[0].Standard_User_Profile_Name__c;
            username_append_string = communitySettingsList[0].Username_Appended_String__c;
            associating_limit = Integer.valueof(communitySettingsList[0].Associated_Contact_Limit__c);
            
        } else {
            social_account = 'General Community Account';
            community_profile = 'ADC Community User';
            standard_profile  = 'ADC Standard User';
            username_append_string = '.adc';
            associating_limit = 10000;
        }
    }
    
    void prepareUserData(Auth.UserData data, User u) {   
        
        String name, firstName, lastName, username, alias, email, nickname, ext_provider;
                
        // Initialize the attributes essential for creating a new user with dummy values 
        // in case they will not be provided by the Auth Provider 
        email = 'change@me.com';
        
        if (String.isNotBlank(data.firstname)) {
            firstName = data.firstname;
        }
        
        if (String.isNotBlank(data.lastname)) {
            lastName = data.lastname;
        }
        
        if (String.isNotBlank(data.email)) {
            email = data.email;
            
            //check if lastname is still blank then substring the email before @
            if (String.isBlank(lastName)) {
                lastName = email.substringBefore('@');
            }
        }
        
        if (data.attributeMap.containsKey('full_name')) {
            name = data.attributeMap.get('full_name');        
        }
        
        if (data.attributeMap.containsKey('nickname')) {
            nickname = data.attributeMap.get('nickname');    
        }
        
        if (String.isNotBlank(data.identifier)) {
            ext_provider = data.identifier.substringBefore('|');
        }
        
        alias = lastName;
        //Alias must be 8 characters or less
        if (alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        
        u.Username = email + username_append_string;
        u.Email = email;
        u.LastName = lastName;
        u.FirstName = firstName;
        u.Alias = alias;
        u.CommunityNickName = nickname;
        u.Languagelocalekey = UserInfo.getLocale();
        u.Localesidkey = UserInfo.getLocale();
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'America/New_York';
        u.Disclaimer_Accepted__c = true;
        u.Disclaimer_Accepted_At__c = System.now();
        u.External_Provider__c = ext_provider;
        
    }
    
    // Creates a Standard salesforce or a community user
    global User createUser(Id portalId, Auth.UserData data) {
        
        //check if email is blank then do nothing : Cannot create user
        if (String.isBlank(data.email)) {
            return null;
        }
        
        User u = new User();
        List<User> userList = [
            SELECT Id, Email, FirstName, LastName, Username, Alias, Languagelocalekey, Localesidkey, TimeZoneSidKey, EmailEncodingKey 
            FROM User 
            WHERE Email = :data.email+'.invalid' 
            AND isActive = true
        ];
        
        if (userList.size()>0) {
            u = userList[0];
            //if user found call the update method
            updateUser(u.Id, portalId, data); 
        }
        
        prepareUserData(data, u);
        
        // Is this a Community Context?
        if(data.attributeMap.containsKey('sfdc_networkid') || data.attributeMap.containsKey('network_id') || Test.isRunningTest()) {
            
            //Logic for creating a new account after 10k contacts are associated to it.
            Account a;
            String socialAccountName = social_account+'%';
            List<Account> accounts = [
                SELECT Id, Name,
                (SELECT Id FROM Contacts)   
                FROM Account 
                WHERE Name 
                LIKE :socialAccountName 
                ORDER BY CreatedDate DESC
            ];
            
            if (accounts.isEmpty()) {
                a = new Account(name = social_account);
                insert(a);
                
            } else {
                //the found account should have a limited number of contacts associated to it
                if (accounts[0].Contacts.size() < associating_limit) {
                    a = accounts[0];
                    
                } else {
                    //create a new Account with a subsequent number
                    Integer accountNumber;
                    if (accounts[0].Name.equals(social_account)) {
                        accountNumber = 0;
                    } else {
                        accountNumber = Integer.valueOf(accounts[0].Name.replace(social_account, ''));
                    }
                                        
                    a = new Account(name = social_account + String.valueOf(accountNumber + 1));
                    insert a;
                }
            }
            
            Contact c; 
            //Logic to find if the contact already exist with the same email
            List<Contact> fetchedContactWithSameEmail = [SELECT Id, FirstName, LastName,Direct_Phone__c FROM Contact WHERE Email = :u.email];
            if (fetchedContactWithSameEmail.size() > 0) {
                //Contact found with existing email
                c = fetchedContactWithSameEmail[0];
                
            } else {
                c = new Contact();
                c.accountId = a.Id;
                c.firstName = u.firstName;
                c.lastName  = u.lastName;
                c.email = u.email;
                c.Direct_Phone__c = '1111111111';
                c.Role__c = 'Technical';
                insert(c);
            }
            
            Profile p = [SELECT Id FROM Profile WHERE Name =:community_profile];     
            u.profileId = p.Id;
            u.contactId = c.Id;
            return u;
            
        } else {
            
            Profile p = [SELECT Id FROM profile WHERE name=:standard_profile ];
            u.profileId = p.Id;
            return u;
        } 
    }
    
    // Updates the user's first and last name
    global void updateUser(Id userId, Id portalId, Auth.UserData data) { 
        User u = new User(Id=userId);
        /*if (String.isNotBlank(data.firstname)) {
            u.firstname = data.firstname;
        }
        
        if (String.isNotBlank(data.lastname)) {
            u.lastName = data.lastname;
        }
        
        if (data.attributeMap.containsKey('nickname')) {
            u.CommunityNickName = data.attributeMap.get('nickname');    
        }
        */
        update(u);
    } 
}