public class lookUpController {
    @AuraEnabled
    public static List <Product2> fetchProduct(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List <Product2> lstOfProducts = [SELECT Id, Name FROM PRODUCT2 WHERE Name LIKE: searchKey];
        
        return lstOfProducts;
    }
}