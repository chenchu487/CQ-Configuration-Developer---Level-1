@isTest
public class PartProductSyncTest {
    @isTest
    static void testPartProductSync() {
        // Create test data - Parts without product references
        List<SQX_Part__c> parts = new List<SQX_Part__c>();
        for (Integer i = 0; i < 5; i++) {
            SQX_Part__c part = new SQX_Part__c(
                Name = 'test ' + i,
                Part_Number__c = '100' + i,
                Active__c = true
            );
            parts.add(part);
        }
        insert parts;

        // Create test data - Existing products
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            Product2 product = new Product2(
                Name = 'test ' + i,
                ProductCode = '100' + i,
                IsActive = true
            );
            products.add(product);
        }
        insert products;

        // Run the scheduler
        Test.startTest();
        PartProductSync scheduler = new PartProductSync();
        scheduler.execute(null);
        Test.stopTest();

        
        List<SQX_Part__c> updatedParts = [SELECT Id, Name, Part_Number__c, Product__c FROM SQX_Part__c];
        
        for (SQX_Part__c part : updatedParts) {
            
        }
    }
}