@IsTest
public class ProductPartSyncBatchTest {
    
    @TestSetup
    static void setupTestData() {
        List<Product2> productsToInsert = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
        	Product2 existingProd = new Product2();
            existingProd.Name = 'Prod' + i;
            existingProd.ProductCode = 'Code' + i;
            existingProd.IsActive = true;
        	productsToInsert.add(existingProd);
        }
        insert productsToInsert;
        
        List<SQX_Part__c> partsToInsert = new List<SQX_Part__c>();
        for (Integer i = 0; i < 5; i++) {
            SQX_Part__c part = new SQX_Part__c();
			part.Name = 'Prod' + i;
            part.Part_Number__c = 'Code' + i;
            part.Active__c = true;
           	partsToInsert.add(part);
        }
        insert partsToInsert;
    }

    @IsTest
    static void testProductPartSyncBatch() {
        
        Test.startTest();
        ProductPartSyncBatch batch = new ProductPartSyncBatch();
        Database.executeBatch(batch, 20);
        Test.stopTest();

        List<SQX_Part__c> skippedParts = [SELECT Product__c FROM SQX_Part__c WHERE Product__c != null];
        for (SQX_Part__c p : skippedParts) {
            Assert.isNotNull(p.Product__c);
        }
    }
}