/*******
This trigger is implemented by Equifax.
This trigger is used to perform operations on OCA and account on submission of application form.

**********/
trigger OnlineCreditApplication on forseva1__OnlineCreditApplication__c (before insert, after insert, before update, after update) {
	if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            System.debug('Inside this portion');
            OnlineCreditApplicationUtil.removeExtraCharacters(Trigger.New);
            OnlineCreditApplicationUtil.populateIdOfAccount(Trigger.New);
        }
    }
    
    if(Trigger.isAfter || Trigger.isUpdate){
        if(Trigger.isInsert){
            OnlineCreditApplicationUtil.populateAddressOnAccount(Trigger.New);
            OnlineCreditApplicationUtil.populateCountryAndState(Trigger.New);
        }
    }
    /*if(trigger.isAfter && trigger.isInsert) {
    OnlineCreditApplicationUtil.createORUpdateExistingAccounts(Trigger.New);
    }*/
  /* if(Trigger.isInsert){
        if(Trigger.isBefore ){
            System.debug('Inside this portion');
           	OnlineCreditApplicationUtil.removeExtraCharacters(Trigger.New);
            OnlineCreditApplicationUtil.populateIdOfAccount(Trigger.New);
        }
        else
        {
            //TODO Code for Is-After & Is-Insert
            OnlineCreditApplicationUtil.removeExtraCharacters(Trigger.New);
            OnlineCreditApplicationUtil.populateIdOfAccount(Trigger.New);
        }
    }     
    else if(Trigger.isUpdate){
        if(Trigger.isBefore){
            //OnlineCreditApplicationUtil.removeExtraCharacters(Trigger.New);
            //OnlineCreditApplicationUtil.populateIdOfAccount(Trigger.New);
            //OnlineCreditApplicationUtil.populateAddressOnAccount(Trigger.New);
        }
        else
        {
            OnlineCreditApplicationUtil.populateAddressOnAccount(Trigger.New);
        }
    }*/

}