@isTest
public class lookUpController_Test {

    @isTest
    public static void testFetchProduct() {
        String keyWord = 'ZVProduct';
        List <Product2> allProducts = lookUpController.fetchProduct(keyWord);
    }
}