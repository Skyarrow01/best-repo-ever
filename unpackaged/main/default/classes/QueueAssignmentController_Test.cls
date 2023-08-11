@isTest
public class QueueAssignmentController_Test {

    @isTest
    public static void testFetchQueue() {
        List<Group> allgroups = QueueAssignmentController.fetchQueue();
        
        
        QueueAssignmentController.userData userDataRecord;
        if(allgroups.size() > 0) {
            userDataRecord = QueueAssignmentController.fetchUsersNotAssignedToQueue(allgroups[0].Id);
            
            Set<Id> existingUsersId = new Set<id>();
            for (GroupMember  groupMemberInstance: [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :allgroups[0].Id LIMIT 5]) {
                   if (String.valueOf(groupMemberInstance.UserOrGroupId).startsWith('005')) {
						existingUsersId.add(groupMemberInstance.UserOrGroupId);
                   }
            }
        
            if (existingUsersId.size() > 0) {
                User u = [SELECT Id, Name FROM User WHERE Id NOT IN :existingUsersId LIMIT 1][0];
                QueueAssignmentController.handleAssignUsersToQueue('['+JSON.serialize(u)+']', allgroups[0].Id);
                
                User existing = [SELECT Id, Name FROM User WHERE Id IN :existingUsersId LIMIT 1][0];
                QueueAssignmentController.handleRemoveUsersToQueue('['+JSON.serialize(existing)+']', allgroups[0].Id);
                
            }
        }
        
    }
}