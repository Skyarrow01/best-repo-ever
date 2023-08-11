@isTest
public class AddressSearchController_Test {
    
    @isTest
    public static void addressSetTest() {

		AddressSearchController.getAddressSet('Test');
		AddressSearchController.getAddressDetailsByPlaceId('Test');        
    }

}