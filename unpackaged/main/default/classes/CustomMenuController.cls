public class CustomMenuController {
    
    @auraEnabled
    public static allTopics fetchTopicInformation(String FirstTopicString, String SecondTopicString) {
        
        
        List<String> allTopicsFromString = new List<String>();
        List<String> allTopicsFromSecondString = new List<String>();
        
        for (String eachTopic : FirstTopicString.split(',')) {
            eachTopic = eachTopic.normalizeSpace();
            allTopicsFromString.add(eachTopic);
        }
        
        for (String eachTopic : SecondTopicString.split(',')) {
            eachTopic = eachTopic.normalizeSpace();
            allTopicsFromSecondString.add(eachTopic);
        }
        
        List<firstTopicList> firstTopicMainList = new List<firstTopicList>();
        for (Topic eachTopic : [SELECT Id, Name FROM Topic WHERE Name IN :allTopicsFromString AND NetworkId != null]) {
            firstTopicList topicInstance = new firstTopicList();
            topicInstance.Id = eachTopic.Id;
            topicInstance.Name = eachTopic.Name;
            firstTopicMainList.add(topicInstance);
        }
        
        List<firstTopicList> secondTopicMainList = new List<firstTopicList>();
        for (Topic eachTopic : [SELECT Id, Name FROM Topic WHERE Name IN :allTopicsFromSecondString AND NetworkId != null]) {
            firstTopicList topicInstance = new firstTopicList();
            topicInstance.Id = eachTopic.Id;
            topicInstance.Name = eachTopic.Name;
            secondTopicMainList.add(topicInstance);
        }
        
        allTopics t = new allTopics(firstTopicMainList, secondTopicMainList);
        
        return t;
        
    }
    
    public class allTopics {
        @auraEnabled
        public List<firstTopicList> firstTopicList = new List<firstTopicList>();
        @auraEnabled
        public List<firstTopicList> SecondTopicList = new List<firstTopicList>();
        
        public allTopics(List<firstTopicList> firstTopicList, List<firstTopicList> secondTopicList) {
            this.firstTopicList = firstTopicList;
            this.secondTopicList = secondTopicList;
        }
    }
    
    public class firstTopicList {
        @auraEnabled
        public String Id;
        @auraEnabled
        public String Name;
    }
    
    @auraEnabled
    public static String fetchProfileInformation() {
        User u = [SELECT Profile.Name FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        if (u != null) {
            return u.Profile.Name;
        }
        return '';
    }
}