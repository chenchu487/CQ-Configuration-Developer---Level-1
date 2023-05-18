@IsTest
public class PartProductSyncTest {
   @IsTest
   public static void testPartProductSync() {
      // Create test data: parts without product references
      List<SQX_Part__c> parts = new List<SQX_Part__c>();
      
      // Create parts without product references
      SQX_Part__c part1 = new SQX_Part__c(Name = 'Part 1', Part_Number__c = 'P001', Active__c = true);
      SQX_Part__c part2 = new SQX_Part__c(Name = 'Part 2', Part_Number__c = 'P002', Active__c = true);
      
      parts.add(part1);
      parts.add(part2);
      
      insert parts;
      
      // Call the scheduler
      Test.startTest();
      PartProductSync partProductSync = new PartProductSync();
      partProductSync.execute(null);
      Test.stopTest();
      
      // Verify the product references are added to the parts
      List<SQX_Part__c> updatedParts = [SELECT Id, Product__c FROM SQX_Part__c WHERE Id IN :parts];
      
      
      
      for (SQX_Part__c part : updatedParts) {
         
      }
   }
}