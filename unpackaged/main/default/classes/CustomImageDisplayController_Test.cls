@isTest
public class CustomImageDisplayController_Test {

    @isTest
    public static void testFetchImageTiles() {
        List<CustomImageDisplayController.tiles> allRecords =  CustomImageDisplayController.fetchImageTiles('TOpic 1', 'https://test.com', '', 'TOpic 2', 'https://test.com', '', 'TOpic 3', 'https://test.com','','TOpic 4','https://test.com','');
    }
}