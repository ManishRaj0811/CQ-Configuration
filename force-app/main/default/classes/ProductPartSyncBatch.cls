public with sharing class ProductPartSyncBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Part_Number__c, Active__c FROM SQX_Part__c WHERE Active__c = true AND Product__c = null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<SQX_Part__c> parts = (List<SQX_Part__c>) scope;
        if (parts.isEmpty()){
            return;            
        }

        Set<String> names = new Set<String>();
        Set<String> codes = new Set<String>();
        
        for (SQX_Part__c part : parts) {
            if (part.Name == null || part.Part_Number__c == null){
                continue;
            }
            names.add(part.Name);
            codes.add(part.Part_Number__c);
        }

        Map<String, Product2> keyToProduct = new Map<String, Product2>();
        
        if (names.isEmpty() || codes.isEmpty()) {
            return;
        }
        
        for (Product2 product : [SELECT Id, Name, ProductCode FROM Product2 WHERE Name IN :names AND ProductCode IN :codes AND IsActive = true]) {
            keyToProduct.put(product.Name + product.ProductCode, product);
       	}

        List<Product2> productsToInsert = new List<Product2>();
        List<SQX_Part__c> partsToSync = new List<SQX_Part__c>();

        for (SQX_Part__c part : parts) {
            String key = part.Name + part.Part_Number__c;
            if (keyToProduct.containsKey(key)) {
                SQX_Part__c partToUpdate = new SQX_Part__c(Id = part.Id);
                partToUpdate.Product__c  = keyToProduct.get(key).Id;
                partsToSync.add(partToUpdate);
            } else {
                Product2 newProduct = new Product2();
                newProduct.Name = part.Name;
                newProduct.ProductCode = part.Part_Number__c;
                newProduct.IsActive = true;
                productsToInsert.add(newProduct);
            }
        }

        if (!productsToInsert.isEmpty()) {
            insert productsToInsert;
            
			Map<String, Product2> keyToNewProducts = new Map<String, Product2>();
            
            for (Product2 product : productsToInsert) {
                keyToNewProducts.put(product.Name + product.ProductCode, product);
            }

            for (SQX_Part__c part : parts) {
                String key = part.Name + part.Part_Number__c;
                if (keyToNewProducts.containsKey(key)) {
                	SQX_Part__c partToUpdate = new SQX_Part__c(Id = part.Id);
                	partToUpdate.Product__c  = keyToNewProducts.get(key).Id;
                	partsToSync.add(part);
            	} 
            }
        }

        if (!partsToSync.isEmpty()) {
            update partsToSync;
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}