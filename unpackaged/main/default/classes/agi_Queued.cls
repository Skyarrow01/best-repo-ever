public class agi_Queued implements Queueable {
    Set<Id> messageIds;
    Set<Id> caseIds;
    
    public agi_Queued(Set<Id> messageRecords){
        this.messageIds = messageRecords;
    }
    
    public void execute(QueueableContext ctx)
    {
        for(Id messageId: messageIds){
            agi_EmailHandler.sendEmail(messageId, true);
        }
    }
    
}