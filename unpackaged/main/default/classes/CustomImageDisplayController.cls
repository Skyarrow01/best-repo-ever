public class CustomImageDisplayController {

    @auraEnabled
    public static List<tiles> fetchImageTiles(String FirstTileName, String FirstTileLink, String FirstTileImageLink, String SecondTileName, String SecondTileLink, String SecondTileImageLink,
                                             String ThirdTileName, String ThirdTileLink, String ThirdTileImageLink, String FourthTileName, String FourthTileLink, String FourthTileImageLink) {
        List<tiles> allTiles = new List<tiles>();
        
        if (String.isNotBlank(FirstTileName)) {
            tiles firstTile = new tiles();
            firstTile.name = FirstTileName;
            FirstTileImageLink = GetResourceURL(FirstTileImageLink);
            firstTile.imageLink = FirstTileImageLink;
            firstTile.linkRedirect = FirstTileLink;
            allTiles.add(firstTile);
        }
        
        if (String.isNotBlank(SecondTileName)) {
            tiles secondTile = new tiles();
            secondTile.name = SecondTileName;
            SecondTileImageLink = GetResourceURL(SecondTileImageLink);
            secondTile.imageLink = SecondTileImageLink;
            secondTile.linkRedirect = SecondTileLink;
            allTiles.add(secondTile);
        }
                                                 
        if (String.isNotBlank(ThirdTileName)) {
            tiles thirdTile = new tiles();
            thirdTile.name = ThirdTileName;
            ThirdTileImageLink = GetResourceURL(ThirdTileImageLink);
            thirdTile.imageLink = ThirdTileImageLink;
            thirdTile.linkRedirect = ThirdTileLink;
            allTiles.add(thirdTile);
        }
                                                 
        if (String.isNotBlank(FourthTileName)) {
            tiles fourthTile = new tiles();
            fourthTile.name = FourthTileName;
            FourthTileImageLink = GetResourceURL(FourthTileImageLink);
            fourthTile.imageLink = FourthTileImageLink;
            fourthTile.linkRedirect = FourthTileLink;
            allTiles.add(fourthTile);
        }
        
        return allTiles;
    }
    
    // Pass the resource name
    public static String GetResourceURL(String resourceName){

        // Fetching the resource
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
		// Checking if the result is returned or not
        if(resourceList.size() == 1){

           // Getting namespace
           String namespace = resourceList[0].NamespacePrefix;
           // Resource URL
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        else return '';
    }
    
    public class tiles {
        @auraEnabled
        public String name;
        @auraEnabled
        public String imageLink;
        @auraEnabled 
        public String linkRedirect;
    }
    
    @auraEnabled
    public static String fetchProfileInformation() {
        return CustomMenuController.fetchProfileInformation();
    }
}