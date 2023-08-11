@isTest
public class agi_CommunityTopicProviderTest {
    private static String topicId;
    private static String commSite;
    private static User uAdmin;
    private static ConnectApi.FeedElementPage fep;
    private static User uModerator;
	private static User uGuest;
    
    static void setup(){
        List<Topic> testTopic = [SELECT Id
                          	FROM TOPIC
                          WHERE NAME='Open Source Devices'
                          LIMIT 1];
        topicId = testTopic[0].Id;
        
        List<Network> theSite = [SELECT Id
                       		FROM Network
                        LIMIT 1
                       	];
        
        if (theSite.size() == 1)
            commSite = theSite[0].Id;

        List<User> adminUser = [SELECT Id
                               FROM User
                               WHERE Id = '0053u000003Ts5JAAS'
                               LIMIT 1];
        
        if (adminUser.size() == 1)
            uAdmin = adminUser[0];
        
        List<PermissionSetAssignment> perms = [SELECT AssigneeId
                                              FROM PermissionSetAssignment
                                              WHERE PermissionSet.Name = 'Manage_Communities'
                                              ];
        
        if (perms.size() > 0){
            List<Id> permId = new List<Id>();
            for (PermissionSetAssignment p : perms)
                permId.add(p.AssigneeId);
            
            List<User> modUser = [SELECT Id
                                 FROM User
                                 WHERE Id in :permId
                                 AND IsActive = true
                                 LIMIT 1];
            
            uModerator = modUser[0];
        }

		List<Profile> guestProf = [SELECT Id
                                   FROM Profile
                                   WHERE Name = 'ADC Community User'
                                   LIMIT 1];
        
        if (guestProf.size() > 0){
        	List<User> guestUser = [SELECT Id
                                   FROM User
                                   WHERE ProfileId in :guestProf
                                   AND IsActive = true
                                   LIMIT 1];  
            
            uGuest = guestUser[0];
        }
        
    	fep = new ConnectApi.FeedElementPage();
        ConnectApi.FeedElement fi = new ConnectApi.GenericFeedElement();
		fi.parent = new ConnectApi.UserDetail();
        fi.capabilities = new ConnectApi.FeedElementCapabilities();
        
        ConnectApi.QuestionAndAnswersCapability qa = new ConnectApi.QuestionAndAnswersCapability();
        qa.questionTitle = 'Test';
        
        ConnectApi.InteractionsCapability iq = new ConnectApi.InteractionsCapability();
        iq.count = 100;
        
        ConnectApi.UpDownVoteCapability upd = new ConnectApi.UpDownVoteCapability();
        upd.upVoteCount = 10;
        
        ConnectApi.CommentsCapability cc = new ConnectApi.CommentsCapability();
        ConnectApi.CommentPage cp = new ConnectApi.CommentPage();
        cc.page = cp;
        
        ConnectApi.EditCapability ec = new ConnectApi.EditCapability();
        ec.lastEditedDate = DateTime.now();

        ConnectApi.FeedBody fb = new ConnectApi.FeedBody();
        ConnectApi.TopicsCapability tc = new ConnectApi.TopicsCapability();
        tc.items = new List<ConnectApi.Topic>();
        
        ConnectApi.PinCapability pc = new ConnectApi.PinCapability();
        pc.isPinned = true;
        
        fi.capabilities.questionAndAnswers = qa;
        fi.capabilities.interactions = iq;
        fi.capabilities.upDownVote = upd;
        fi.body = fb;
        fi.body.text = 'Test';
        fi.capabilities.topics = tc;
		fi.capabilities.comments = cc;
        fi.capabilities.edit = ec;
        fi.capabilities.pin = pc;
        
        fep.elements = new List<ConnectApi.GenericFeedElement>();
        fep.elements.add(fi);
        
    }

    @isTest(seeAllData=true)
    static void testTopicHasItems() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    '', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }
    
    @isTest(seeAllData=true)
    static void testHomepageHasItems() {
        setup();
    
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Home, 
                                                                  1,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(null, 
                                                                                    '', 
                                                                                    '', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);
    }
    
    @isTest(seeAllData=true)
    static void testTopicHasItemsLatest() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.CreatedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    'latest', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }    

    @isTest(seeAllData=true)
    static void testTopicHasItemsTop() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.Relevance,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    'top', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }        

    @isTest(seeAllData=true)
    static void testTopicHasItemsFake() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    'fake', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }     
    
    @isTest(seeAllData=true)
    static void testTopicHasItemsFilterNotAnswer() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.UnansweredQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    'notanswered', 
                                                                                    '', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }        

    @isTest(seeAllData=true)
    static void testTopicHasItemsFilterNoBest() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.UnsolvedQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    'nobest', 
                                                                                    '', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }        

    @isTest(seeAllData=true)
    static void testTopicHasItemsFilterBest() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.SolvedQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    'best', 
                                                                                    '', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }       

    @isTest(seeAllData=true)
    static void testTopicHasItemsFilterFake() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    'fake', 
                                                                                    '', 
                                                                                    null, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }    
    
    @isTest(seeAllData=true)
    static void testTopicHasItemsWithUser() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    '', 
                                                                                    uAdmin.Id, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }  

    @isTest(seeAllData=true)
    static void testTopicHasItemsWithModerator() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    '', 
                                                                                    uModerator.Id, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }      

    @isTest(seeAllData=true)
    static void testTopicHasItemsWithGuest() {
        setup();
        	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(commSite, 
                                                                  ConnectApi.feedType.Record, 
                                                                  topicId,
                                                                  1,
                                                                  10,
                                                                  ConnectApi.FeedDensity.AllUpdates,
                                                                  null,
                                                                  15,
                                                                  ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                  null,
                                                                  ConnectApi.FeedFilter.AllQuestions,
                                                                 fep);
        
            agi_CommunityTopicProvider.agi_TopicsListing tl = agi_CommunityTopicProvider.getTopicListing(topicId, 
                                                                                    '', 
                                                                                    '', 
                                                                                    uGuest.Id, 
                                                                                    null);
        
            
        Boolean bHasRows = false;
        if (tl.listings.size() > 0)
            bHasRows = true;
        
        System.assertEquals(true, bHasRows);

    }          
    

}