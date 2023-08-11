public class TechnicalForumImageController {

    @auraEnabled
    public static List<tiles> fetchImageTiles(String FirstTileName, String FirstTileLink, String FirstTileImageLink, String SecondTileName, String SecondTileLink, String SecondTileImageLink,
                                             String ThirdTileName, String ThirdTileLink, String ThirdTileImageLink, String FourthTileName, String FourthTileLink, String FourthTileImageLink) {
        List<tiles> allTiles = new List<tiles>();
        List<String> allTopicsId = new List<String>();
        Map<String, Id> mapOfTopicNameWithId = new Map<String, Id>();
        Map<String, List<String>> mapOfTopicsWithSubtopics = new Map<String, List<String>>();
                        
        Network networkRecord = [SELECT Id, Name FROM Network LIMIT 1];
                                                 
        List<String> allTopics = new List<String>{FirstTileName, SecondTileName, ThirdTileName, FourthTileName};
                                                 
        for(Topic allTopicsList : [SELECT Id, Name FROM Topic WHERE Name IN :allTopics AND NetworkId != null]) {
        	allTopicsId.add(allTopicsList.Id);  
            mapOfTopicNameWithId.put(allTopicsList.Name, allTopicsList.Id);
        }
        
        if (!test.isRunningTest()) {
            ConnectApi.ManagedTopicCollection collection = ConnectAPI.ManagedTopics.getManagedTopics(networkRecord.Id, ConnectApi.ManagedTopicType.Navigational, allTopicsId, 2);
            List<ConnectApi.ManagedTopic> topicInfo = collection.managedTopics;
            
            for(ConnectApi.ManagedTopic eachTopicInfor : topicInfo) {
                String topicName = eachTopicInfor.topic.name;
                mapOfTopicsWithSubtopics.put(topicName, new List<String>());
                
                for (ConnectApi.ManagedTopic eachChild : eachTopicInfor.children) {
                    mapOfTopicsWithSubtopics.get(topicName).add(eachChild.topic.name);
                }
            }                                         
        
        } else {
            //for test class fill in the mapOfTopicsWithSubtopics with dummy details
            mapOfTopicsWithSubtopics.put(FirstTileName, new List<String>{'test1', 'test2'});
            mapOfTopicsWithSubtopics.put(SecondTileName, new List<String>{'test3', 'test4'});
            mapOfTopicsWithSubtopics.put(ThirdTileName, new List<String>{'test5', 'test6'});
            mapOfTopicsWithSubtopics.put(FourthTileName, new List<String>{'test7', 'test8'});
        }                                        
        
        System.debug('mapOfTopicsWithSubtopics'+mapOfTopicsWithSubtopics);
        
        if (String.isNotBlank(FirstTileName)) {
            tiles firstTile = new tiles();
            firstTile.name = FirstTileName;
            firstTile.id = mapOfTopicNameWithId.get(FirstTileName);
            FirstTileImageLink = CustomImageDisplayController.GetResourceURL(FirstTileImageLink);
            firstTile.imageLink = FirstTileImageLink;
            firstTile.linkRedirect = FirstTileLink;
            firstTile.subtopics = new List<subtopics>();
            
            for(String eachSubtopic : mapOfTopicsWithSubtopics.get(FirstTileName)) {
                firstTile.subtopics.add(new subtopics(eachSubtopic));
            }
            
            allTiles.add(firstTile);
        }
        
        if (String.isNotBlank(SecondTileName)) {
            tiles secondTile = new tiles();
            secondTile.name = SecondTileName;
            secondTile.id = mapOfTopicNameWithId.get(SecondTileName);
            SecondTileImageLink = CustomImageDisplayController.GetResourceURL(SecondTileImageLink);
            secondTile.imageLink = SecondTileImageLink;
            secondTile.linkRedirect = SecondTileLink;
            secondTile.subtopics = new List<subtopics>();
            
            for(String eachSubtopic : mapOfTopicsWithSubtopics.get(SecondTileName)) {
                secondTile.subtopics.add(new subtopics(eachSubtopic));
            }
            
            allTiles.add(secondTile);
        }
                                                 
        if (String.isNotBlank(ThirdTileName)) {
            tiles thirdTile = new tiles();
            thirdTile.name = ThirdTileName;
            thirdTile.id = mapOfTopicNameWithId.get(ThirdTileName);
            ThirdTileImageLink = CustomImageDisplayController.GetResourceURL(ThirdTileImageLink);
            thirdTile.imageLink = ThirdTileImageLink;
            thirdTile.linkRedirect = ThirdTileLink;
            thirdTile.subtopics = new List<subtopics>();
            
            for(String eachSubtopic : mapOfTopicsWithSubtopics.get(ThirdTileName)) {
                thirdTile.subtopics.add(new subtopics(eachSubtopic));
            }
            
            allTiles.add(thirdTile);
        }
                                                 
        if (String.isNotBlank(FourthTileName)) {
            tiles fourthTile = new tiles();
            fourthTile.name = FourthTileName;
            fourthTile.id = mapOfTopicNameWithId.get(FourthTileName);
            FourthTileImageLink = CustomImageDisplayController.GetResourceURL(FourthTileImageLink);
            fourthTile.imageLink = FourthTileImageLink;
            fourthTile.linkRedirect = FourthTileLink;
            fourthTile.subtopics = new List<subtopics>();
            
            for(String eachSubtopic : mapOfTopicsWithSubtopics.get(FourthTileName)) {
                fourthTile.subtopics.add(new subtopics(eachSubtopic));
            }
            
            allTiles.add(fourthTile);
        }
        System.debug(allTiles);
        return allTiles;
    }
    
    public class tiles {
        @auraEnabled
        public String name;
        @auraEnabled
        public String id;
        @auraEnabled
        public String imageLink;
        @auraEnabled 
        public String linkRedirect;
        @auraEnabled
        public List<subtopics> subtopics;
    }
    
    public class subtopics {
        @auraEnabled
        public String name;
        public subtopics(String name) {
            this.name = name;
        }
    }
}