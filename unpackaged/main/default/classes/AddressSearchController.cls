public class AddressSearchController {
    
	//Method to call google API and fetch the address recommendations 
    @AuraEnabled
    public static String getAddressSet(String SearchText) {
        String result = null;
        String APIKey = getAPIKey();
        
        if (String.isNotBlank(APIKey)) {
            
            try{
                if(SearchText != null){
                    String APIUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + SearchText.replace(' ', '%20') + '&key=' + APIKey; 
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setEndpoint(APIURL);
                    Http http = new Http();
                    HttpResponse res ;
                    if (!Test.isRunningTest()) {
                        res = http.send(req);
                    } else {
                        res = new HttpResponse();
                        res.setStatusCode(200);
                        res.setBody('address');
                    }
                    
                    Integer statusCode = res.getStatusCode();
                    if(statusCode == 200){
                        result = res.getBody();
                    }
                }
            } catch(exception e){
                //Handling exception
                system.debug(e.getMessage());
            }
        }
        return result;
    }
    
    //Method to call google API and fetch the address details by addressID 
    @AuraEnabled
    public static String getAddressDetailsByPlaceId(String PlaceID){
        
        String APIKey = getAPIKey();
        String result = null;
        
        if (String.isNotBlank(APIKey)) {
            
            try{
                if(PlaceID != null){
                    String APIUrl = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + PlaceId.replace(' ', '%20') + '&key=' + APIKey; 
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setEndpoint(APIURL);
                    Http http = new Http();
                    HttpResponse res;
                    if (!Test.isRunningTest()) {
                        res = http.send(req);
                    } else {
                        res = new HttpResponse();
                        res.setStatusCode(200);
                        res.setBody('address');
                    }
                    Integer statusCode = res.getStatusCode();
                    if(statusCode == 200){
                        result = res.getBody();
                    }
                }
            }
            catch(exception e){
                //Handling exception
                system.debug(e.getMessage());
            }
        }
        return result;
    }
    
    private static String getAPIKey() {
        List<Google_API_Param__mdt> allAPIParams = [
            SELECT Id, MasterLabel, API_Key__c 
            FROM Google_API_Param__mdt
 			WHERE MasterLabel = 'Google APi Key'
        ];
        
        if (allAPIParams.size() > 0) {
            return allAPIParams[0].API_Key__c;
        }
        
        return null;
    }
    
    @AuraEnabled
    public static Contact getContactRecord(Id recordId) {
        System.debug('recordId'+recordId);
        Contact con = new Contact();
        if (String.valueOf(recordId).startsWith('003')) {
            con = [SELECT Id, AccountId, Account.Name, Email, Direct_Phone__c, MobilePhone From Contact WHERE Id = :recordId];
        } else {
            Ship_To_Addresses__c add = [SELECT Account__c, Account__r.Name, Contact__c FROM Ship_To_Addresses__c WHERE Id =:recordId];
            con.Id = add.Contact__c;
            con.AccountId = add.Account__c;
        }
        System.debug('con'+con);
        return con;
    }
}