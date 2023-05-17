public class PartProductSync implements Schedulable {
   public void execute(SchedulableContext context) {
      // Query active parts without a product reference
      List<SQX_Part__c> parts = [SELECT Id, Name, Part_Number__c, Product__c 
                                 FROM SQX_Part__c 
                                 WHERE Active__c = true AND Product__c = null];

      List<Product2> productsToUpdate = new List<Product2>();

      
      for (SQX_Part__c part : parts) {
         // Check if a product with the same name and part number exists
         list<Product2> existingProduct = [SELECT Id, Name, ProductCode 
                                     FROM Product2 
                                     WHERE Name = :part.Name AND ProductCode = :part.Part_Number__c LIMIT 1];
         /*Product2 existingProduct = [SELECT Id, Name, ProductCode 
                                     FROM Product2 
                                     WHERE Name = :part.Name AND ProductCode = :part.Part_Number__c LIMIT 1];*/
          

         if (!existingProduct.isempty()) {
            // Update the part record with the existing product reference
            part.Product__c = existingProduct[0].Id;
         } else {
            // Create a new product record using the mapping details
            Product2 newProduct = new Product2(
               Name = part.Name,
               ProductCode = part.Part_Number__c,
               IsActive = true
            );
             insert newProduct;
            //productsToUpdate.add(newProduct);
            part.Product__c = newProduct.Id; 
         }
          update parts;
      }

            // Insert new product records
      /*if (!productsToUpdate.isEmpty()) {
         insert productsToUpdate;
      }*/
   }
}