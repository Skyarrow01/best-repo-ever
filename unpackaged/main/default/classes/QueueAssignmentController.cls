public class QueueAssignmentController {
    
    @auraEnabled
    public static List<Group> fetchQueue() {
        Set<String> allQueues = new Set<String>();
        
        for(Silos_and_Questionnaire__mdt allQueuesToBeUsed : [SELECT Id, MasterLabel FROM Silos_and_Questionnaire__mdt]) {
            allQueues.add(allQueuesToBeUsed.MasterLabel);
        }
        
        return [SELECt Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :allQueues];
    }
    
    @auraEnabled
    public static userData fetchUsersNotAssignedToQueue(Id queueId) {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Product Engineer User'];
        
        Set<Id> existingAssociatedUserIds = new Set<Id>();
        for(GroupMember groupMemberInstance : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :queueId]) {
            
            if (String.valueOf(groupMemberInstance.UserOrGroupId).startsWith('005')) {
                existingAssociatedUserIds.add(groupMemberInstance.UserOrGroupId);
            }
        } 
        
        List<User> allOtherUserList = [SELECT Id, Name FROM User WHERE Id NOT IN :existingAssociatedUserIds AND ProfileId = :p.Id];
        
        userData data = new userData(allOtherUserList, [SELECT Id, Name FROM User WHERE Id IN :existingAssociatedUserIds AND ProfileId = :p.Id]);
        
        return data;
    }
    
    public class userData {
        @auraEnabled
        public List<User> assignUserData;
        @auraEnabled
        public List<User> removeUserData;
        
        public userData(List<User> assignUserData, List<User> removeUserData) {
            this.assignUserData = new List<User>();
            this.assignUserData = assignUserData;
            
            this.removeUserData = new List<User>();
            this.removeUserData = removeUserData;
        }
    }
    
    @auraEnabled
    public static void handleAssignUsersToQueue(String userListObj, String queueId) {
        
        List<User> allUsers = (List<User>)System.JSON.deserializeStrict(userListObj, List<User>.Class);
        System.debug('allUsers'+allUsers);
        
        List<GroupMember> allGroupMembers = new List<GroupMember>();
        for(User eachUser : allUsers) {
            GroupMember member = new GroupMember();
            member.UserOrGroupId = eachUser.Id;
            member.GroupId = queueId;
            allGroupMembers.add(member);
        }
        
        if(!test.isRunningTest())
        insert allGroupMembers;
    }
    
    @auraEnabled 
    public static void handleRemoveUsersToQueue(String userListObj, String queueId) {
        List<User> allUsers = (List<User>)System.JSON.deserializeStrict(userListObj, List<User>.Class);
        System.debug('allUsers'+allUsers);
        
        List<GroupMember> allGroupMembers = new List<GroupMember>();
        allGroupMembers = [SELECT Id FROM GroupMember WHERE GroupId = :queueId AND UserOrGroupId IN :allUsers];
        
        if(!test.isRunningTest())
        delete allGroupMembers;
    }
}