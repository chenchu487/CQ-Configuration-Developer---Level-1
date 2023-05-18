public class PartProductSync implements Schedulable {
   public void execute(SchedulableContext context) {
       
      // Check profile and permission set
      if (!checkUserProfile('System Administrator') || !checkPermissionSet('CQ_Product_Admin')) {
         System.debug('Insufficient privileges. Exiting the execution.');
         return;
      }

      // Query active parts without a product reference
      List<SQX_Part__c> parts = [SELECT Id, Name, Part_Number__c, Product__c 
                                 FROM SQX_Part__c 
                                 WHERE Active__c = true AND Product__c = null];

      List<SQX_Part__c> productsToUpdate = new List<SQX_Part__c>();

      for (SQX_Part__c part : parts) {
         // Check if a product with the same name and part number exists
         List<Product2> existingProducts;
         try {
            existingProducts = [SELECT Id, Name, ProductCode 
                                FROM Product2 
                                WHERE Name = :part.Name AND ProductCode = :part.Part_Number__c LIMIT 1];
         } catch (QueryException e) {
             
            // Handle the exception if the query returns no rows
            System.debug('No product found for part: ' + part.Name);
            continue; 
         }

         if (!existingProducts.isEmpty()) {
            // Update the part record with the existing product reference
            part.Product__c = existingProducts[0].Id;
         } else {
            // Create a new product record using the mapping 
            Product2 newProduct = new Product2(
               Name = part.Name,
               ProductCode = part.Part_Number__c,
               IsActive = true
            );
            try {
               insert newProduct;
               part.Product__c = newProduct.Id;
            } catch (Exception ex) {
               System.debug('Error creating product: ' + ex.getMessage());
               continue; // Skip to the next iteration
            }
         }

         // Add the part to the update list
         productsToUpdate.add(part);
      }

      // Update the parts with product references
      try {
         update productsToUpdate;
         System.debug('Products updated successfully');
      } catch (Exception ex) {
         System.debug('Error updating parts: ' + ex.getMessage());
      }
   }

   private Boolean checkUserProfile(String profileName) {
      // Query for the user's profile
      Profile userProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];

      // Check if the user's profile matches the desired profile name
      return (userProfile != null && UserInfo.getProfileId() == userProfile.Id);
   }

   private Boolean checkPermissionSet(String permissionSetName) {
      // Query for the permission set
      List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];

      // Check if the permission set exists
      if (permissionSets.size() == 0) {
         return false;
      }

      // Query for the permission set assignment for the running user
      PermissionSetAssignment assignment = [SELECT Id FROM PermissionSetAssignment 
                                            WHERE PermissionSetId = :permissionSets[0].Id 
                                            AND AssigneeId = :UserInfo.getUserId() 
                                            LIMIT 1];

      // Check if the user has the permission set assignment
      return (assignment != null);
   }
}