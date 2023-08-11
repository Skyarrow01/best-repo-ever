trigger agi_EmailMessageTrigger on EmailMessage (after insert) {
    boolean bTriggerEnabled = agi_EmailHandler.triggerEnabled();

    Set<Id> filteredMessage = new Set<Id>();
    Set<Id> filteredCases = new Set<Id>();
    
    if (bTriggerEnabled)
    {
        for(EmailMessage message : trigger.new)
        {
            if (message.ParentId != null &&
                    message.Incoming == true)
            {
                Id caseId = message.ParentId;
                List<Case> associatedCase = [SELECT Id, RecordType.Name, Status, Esker_Account__c 
                                             FROM Case
                                      		WHERE Id = :caseId];

                
                if (associatedCase.size() > 0){
                    for(Case aCase : associatedCase)
                    {
                    	if ((aCase.RecordType.Name == 'Orders') &&
                            aCase.Esker_Account__c == true){
                			filteredMessage.add(message.Id);
                            filteredCases.add(aCase.Id);
                        }
                    }
                }
            }
        }

        if (filteredMessage.size() > 0){
            for(Id caseId : filteredCases){
                update new Case(Id=caseId, Status='Esker Queued'); 
            }
           System.enqueueJob(new agi_Queued(filteredMessage));
        }


    } // bTriggerEnabled    
}