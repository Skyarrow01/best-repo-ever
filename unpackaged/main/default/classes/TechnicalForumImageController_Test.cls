@IsTest
public class TechnicalForumImageController_Test {

    @testSetup
    public static void setupRecords() {
        Network networkRecord = [SELECT Id, Name FROM Network LIMIT 1];
        
        List<Topic> allTOpics = new List<Topic>();
        Topic eachTopic1 = new Topic();
        eachTopic1.Name = 'TOpic 1';
        eachTopic1.NetworkId = networkRecord.Id;
        allTOpics.add(eachTopic1);
        
        Topic eachTopi2 = new Topic();
        eachTopi2.Name = 'TOpic 2';
        eachTopi2.NetworkId = networkRecord.Id;
        allTOpics.add(eachTopi2);
        
        Topic eachTopi3 = new Topic();
        eachTopi3.Name = 'TOpic 3';
        eachTopi3.NetworkId = networkRecord.Id;
        allTOpics.add(eachTopi3);
        
        Topic eachTopi4 = new Topic();
        eachTopi4.Name = 'TOpic 4';
        eachTopi4.NetworkId = networkRecord.Id;
        allTOpics.add(eachTopi4);
        
        insert allTOpics;
    }
    
    @isTest
    public static void testFetchImageTiles(){
        List<TechnicalForumImageController.Tiles> allRecords = TechnicalForumImageController.fetchImageTiles('TOpic 1', 'https://test.com', '', 'TOpic 2', 'https://test.com', '', 'TOpic 3', 'https://test.com','','TOpic 4','https://test.com','');
        
    }
}