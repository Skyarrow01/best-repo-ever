@isTest
public class CommunityCaseController_Test {

    @testSetup static void setup() {
        // Create test product
        Product2 testProduct = new Product2(Name = 'TestProduct');
        insert testProduct;        
    }

    @isTest static void testControlMethods() {

        // Access private method annotated with TestVisible
        Account qc = CommunityCaseController.getQuickCallAccount();
        System.assertEquals('Quick Call (Do not change)', qc.name, 'Quick call Account name must match');

        String result = CommunityCaseController.createCase('Test Username', 'testemail-sfapex@javarich.com', '3213211234',
        '', 'Motors', 'Test Subject', 'Test Description');
        System.assert(result != null, 'Case Id should not be null');

        List<Product2> pList = CommunityCaseController.searchProducts('TestProduct');
        System.assert(pList.size() == 1, 'Found TestProduct');

        // Perform some verification
    }
}