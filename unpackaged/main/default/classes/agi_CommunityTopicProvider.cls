public without sharing class agi_CommunityTopicProvider {
	private static Integer rowLimit = 15;
	private static Id commSite = getDefaultCommunity();

    @auraEnabled
    public static agi_TopicsListing getTopicListing(Id topicId, String filterVal, String sortVal, Id userId, String nextPageToken){
        Topic theTopic = null;
        agi_TopicsListing tl = new agi_TopicsListing();
        List<agi_Topic> listings = new List<agi_Topic>();
		ConnectApi.FeedElementPage fep = null;
        ConnectApi.FeedSortOrder sortOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
        ConnectApi.FeedFilter feedFilter = ConnectApi.FeedFilter.AllQuestions;

/*        
        Boolean bShowInternal = false;
        if (userId == null)
        	bShowInternal = null;
*/
        Boolean bShowInternal = null;
        
        switch on sortVal {
            when '', null, 'activity' {
	            sortOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
            }
        	when 'latest' {
	            sortOrder = ConnectApi.FeedSortOrder.CreatedDateDesc;
        	}
            when 'top' {
	            sortOrder = ConnectApi.FeedSortOrder.Relevance;
            }
            when else {
	            sortOrder = ConnectApi.FeedSortOrder.LastModifiedDateDesc;
            }
        }
        
        switch on filterVal {
            when '', null, 'all' {
            	feedFilter = ConnectApi.FeedFilter.AllQuestions;    
            }
            when 'notanswered' {
            	feedFilter = ConnectApi.FeedFilter.UnansweredQuestions; 
            }
            when 'nobest' {
            	feedFilter = ConnectApi.FeedFilter.UnsolvedQuestions;                 
            }
            when 'best' {
                feedFilter = ConnectApi.FeedFilter.SolvedQuestions;
            }
            when else {
            	feedFilter = ConnectApi.FeedFilter.AllQuestions;                  
            }
        }
        
        if (topicId != null)
        	theTopic = [SELECT Id, Name 
                            FROM Topic
                             WHERE Id = :topicId
                             LIMIT 1];

        if (theTopic != null){
			fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  nextPageToken,
                                                                  rowLimit,
                                                                  sortOrder,
                                                                  bShowInternal,
                                                                  feedFilter
                                                                 );
        }
        else {
        	fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.FeedType.Home, 
                                                                  1, 
                                                                  ConnectApi.FeedDensity.AllUpdates, 
                                                                  nextPageToken, 
                                                                  rowLimit, 
                                                                  sortOrder, 
                                                                  feedFilter);    
        }
        
        listings = parseFeedElements(fep.elements);

        tl.listings = listings;
        
        if (theTopic != null)
        	tl.pins = getPins(theTopic);
        
        tl.nextPage = fep.nextPageToken;
        
        if (userId == null)
            tl.canPin = false;
        else {
            List<User> theUser = [SELECT Id, Profile.Name
                                 FROM User
                                 WHERE Id = :userId
                                 LIMIT 1];
            
            if (theUser.size() == 1){
                String prof = theUser[0].Profile.Name;
                if (('System Administrator'.equals(prof) || isModerator(userId)) &&
                    	topicId <> null)
                    tl.canPin = true;
                else
                    tl.canPin = false;
            }
        }
        return tl;
    }
    
    @auraEnabled
    public static agi_TopicsListing getTopicListing(Id topicId, String filterVal, String sortVal, Id userId){
        return getTopicListing(topicId, filterVal, sortVal, userId, null);
    }    

    @auraEnabled
    public static agi_TopicsListing loadMore(String originalTL, String originalPins, String nextPageToken,
                                            Id topicId, String filterVal, String sortVal, Id userId)
    {
        List<agi_topic> ogTopics = null;
        List<agi_topic> ogPins = null;
        
        if (!String.isBlank(originalTL))
        	ogTopics = (List<agi_topic>)System.JSON.deserializeStrict(originalTL, List<agi_topic>.Class);

        if (!String.isBlank(originalPins))
        	ogPins = (List<agi_topic>)System.JSON.deserializeStrict(originalPins, List<agi_topic>.Class);

        List<agi_topic> newTopics = new List<agi_topic>();
        List<agi_topic> newPins = ogPins;
        
        agi_TopicsListing nextPageData = getTopicListing(topicId, filterVal, sortVal, userId, nextPageToken);
        List<agi_topic> nextPageTopics = nextPageData.listings;
        
        for (agi_topic aTopic : ogTopics){
            newTopics.add(aTopic);
        }
        
        for (agi_topic anotherTopic : nextPageTopics) {
            newTopics.add(anotherTopic);
        }
        
        agi_TopicsListing result = new agi_TopicsListing();
        result.listings = newTopics;
        result.pins = newPins;
        result.canPin = nextPageData.canPin;
        result.nextPage = nextPageData.nextPage;
        
        
        return result;
    }
    
    @auraEnabled
    public static void changePinning(String toPin, String feedId, String topicId)
    {
        ConnectApi.PinCapabilityInput cpi = new ConnectApi.PinCapabilityInput();
        cpi.entityId = feedId;
        cpi.isPinned = Boolean.valueOf(toPin);

        Id commSite = getDefaultCommunity();        
        ConnectApi.ChatterFeeds.updatePinnedFeedElements(commSite, ConnectApi.feedType.Topics, (Id)topicId, cpi);
    }
    
    
// public class
    public class agi_TopicsListing {
        @AuraEnabled
        public List<agi_Topic> listings{get;set;}

        @AuraEnabled
        public List<agi_Topic> pins{get;set;}
        
        @AuraEnabled
        public Boolean canPin{get;set;}
        
        @AuraEnabled
        public String nextPage{get;set;}
    }
    
    public class agi_Topic {
		@AuraEnabled
        public Id topicId{get;set;}
		@AuraEnabled
        public String topicTitle{get;set;}
		@AuraEnabled
        public String topicName{get;set;}
		@AuraEnabled
        public DateTime topicCreated{get;set;}
		@AuraEnabled
        public String topicCreatedBy{get;set;}
		@AuraEnabled
        public Integer topicLikes{get;set;}
		@AuraEnabled
        public Integer topicComments{get;set;}
        @AuraEnabled
        public DateTime topicLastActivity{get;set;}
        @AuraEnabled
        public String topicLastUser{get;set;}
        @AuraEnabled
        public Integer topicViews{get;set;}
        @AuraEnabled
        public Boolean topicBestAnswered{get;set;}
        @AuraEnabled
        public Id topicFeedId{get;set;}
        @AuraEnabled
        public String topicLastCommenter{get;set;}
        @AuraEnabled
        public DateTime topicLastCommentDate{get;set;}
        @AuraEnabled
        public String topicPinnedBy{get;set;}
        @AuraEnabled
        public DateTime topicLastEditDate{get;set;}
        @AuraEnabled
        public String topicLastEditBy{get;set;}
        
    }

// private class here
    private class agi_CommentSummary {
        private String lastCommentBy{get;set;}
        private DateTime lastCommentDate{get;set;}
        private String lastCommentRelative{get;set;}
    }
    
    
// private methods here
    private static List<agi_Topic> parseFeedElements(List<ConnectApi.FeedElement> feedElements){
        return parseFeedElements(feedElements, false);
    }
    
    private static List<agi_Topic> parseFeedElements(List<ConnectApi.FeedElement> feedElements, Boolean isPinnedItem){
        List<agi_Topic> someFeeds = new List<agi_Topic>();

        for(ConnectApi.FeedElement el : feedElements) {
            User createdUser = null;
            if (el.parent.Id != null)
            	createdUser = [SELECT Id, Name, CommunityNickname FROM User WHERE Id = :el.parent.Id LIMIT 1];
            
            agi_Topic at = new agi_Topic();
            at.topicFeedId = el.id;
			at.topicCreated = el.createdDate;
            
            String topTitle = (el.capabilities.questionAndAnswers.questionTitle).replaceAll('\r\n|\n|\r',' ');
            if (topTitle.length() > 147){
                topTitle = topTitle.substring(0,147) + '...';
            }
            at.topicTitle = topTitle;
			at.topicViews = Integer.valueOf(el.capabilities.interactions.count);
            at.topicLikes = Integer.valueOf(el.capabilities.upDownVote.upVoteCount);
            
            if (createdUser != null)
				at.topicCreatedBy = createdUser.CommunityNickname;
            
            if (el.capabilities.topics.items.size() > 0)
            {
                at.topicName = el.capabilities.topics.items[0].name;
                at.topicId = el.capabilities.topics.items[0].id;
            }
            
            at.topicComments = el.capabilities.comments.page.total;
 			at.topicLastActivity = el.modifiedDate;
            
            ConnectApi.EditCapability eCap = el.capabilities.edit;
            at.topicLastEditDate = eCap.lastEditedDate;
            
			String lastActor = null;
            String lastCommenter = null;
			DateTime lastCommentDate = null;
            
            if (isPinnedItem) {
                agi_CommentSummary commentSummary = getActor(el.id);
            	lastActor = commentSummary.lastCommentBy;
                lastCommenter = commentSummary.lastCommentBy;
                lastCommentDate = commentSummary.lastCommentDate;
            }
            else {
                agi_CommentSummary commentSummary = extractActorFromComments(el.capabilities.comments);
                lastActor = commentSummary.lastCommentBy;
                lastCommenter = commentSummary.lastCommentBy;
                lastCommentDate = commentSummary.lastCommentDate;
            }
            
            at.topicLastCommenter = lastCommenter;
            at.topicLastCommentDate = lastCommentDate;
            
            if (String.isBlank(lastActor) && createdUser != null)
                at.topicLastUser = createdUser.CommunityNickname;
            else
                at.topicLastUser = lastActor;
                        
            if (el.capabilities.questionAndAnswers.bestAnswer == null)
                at.topicBestAnswered = false;
            else
                at.topicBestAnswered = true;
            
            // FIX THESE
            // END FIX THESE
            
			someFeeds.add(at);                
        }
		return someFeeds;        
    }

    private static Id getDefaultCommunity(){
        List<Network> theSite = [SELECT Id
                       		FROM Network
                        LIMIT 1
                       	];
        
        if (theSite.size() == 1)
            return theSite[0].Id;
        else
            return null;
    }

    private static Boolean isModerator(Id userId){
		Boolean bResult = false;

        List<PermissionSetAssignment> psa = [SELECT Id 
                                             FROM PermissionSetAssignment
												WHERE PermissionSet.Name = 'Manage_Communities'
                                            	AND AssigneeId = :userId];

        if(psa.size() > 0)
            bResult = true;
          
		return bResult;        
    }

    private static List<agi_Topic> getPins(Topic theTopic){
        List<agi_Topic> pins = new List<agi_Topic>();

		ConnectApi.PinnedFeedElements pFE = ConnectApi.ChatterFeeds.getPinnedFeedElementsFromFeed(commSite, ConnectApi.feedType.Topics, theTopic.Id);
        pins = parseFeedElements(pFE.elements, true);
        
        return pins;
    }    
    
    private static agi_CommentSummary extractActorFromComments(ConnectApi.CommentsCapability lastComments){
		agi_CommentSummary lastCommentSummary = new agi_CommentSummary();
        
        ConnectApi.CommentPage cp = lastComments.page;
        if (cp.items != null && cp.items.size() > 0)
        {
            ConnectApi.UserSummary lastUser = cp.items[0].user;
            lastCommentSummary.lastCommentBy = lastUser.communityNickname;
            lastCommentSummary.lastCommentDate = cp.items[0].createdDate;
            lastCommentSummary.lastCommentRelative = cp.items[0].relativeCreatedDate;
        }

        return lastCommentSummary;
    }
    private static agi_CommentSummary getActor(Id feedElementId){
        agi_CommentSummary sResult = null;

		ConnectApi.FeedElement fe = ConnectApi.ChatterFeeds.getFeedElement(commSite,
                                                                           feedElementId, 
                                                                           1, 
                                                                           10);
		sResult = extractActorFromComments(fe.capabilities.comments);
        
        return sResult;
    }
}