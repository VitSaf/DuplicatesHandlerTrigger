public with sharing class AgreementHelper {
    private AgreementHelper() {}

/**
 * Actualizing records in junction table: removes depricated records and creates new
 * oldRecords != null only when called from afterUpdate
 */
    public static void actualizeJunctionRecords(Map<Id, Agreement__c> newRecords, Map<Id, Agreement__c> oldRecords) { 
        Agreement_Product_Junction__c[] newJunctionRecords = new List<Agreement_Product_Junction__c>();
        if (oldRecords == null) {//when called from after insert/undelete we just create new junction records
            newJunctionRecords = AgreementHelper.createJunctionRecords([SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :AgreementHelper.getAllProductCodesInList(newRecords.values())]
                                                                    ,newRecords.values());
        } else {//when called from after update
            Id[] modifiedAgreements = AgreementHelper.getRecordIdsWithModifiedCodes(newRecords, oldRecords);//check if Products__c field was modified
            if (modifiedAgreements.size() > 0) {//looking for difference if Products__c was modified
                Agreement__c[] agreementsToCheck = [SELECT  Id, 
                                                            Products__c, 
                                                            (SELECT Product__c, Agreement__c, Product_code__c FROM Agreement_Products__r)
                                                    FROM Agreement__c 
                                                    WHERE Id IN :modifiedAgreements];
                
                Map<Product2[], Agreement__c[]> forNewJunctions = AgreementHelper.getDataForNewJunctionRecords(agreementsToCheck, newRecords);

                AgreementHelper.removeOldJunctions(agreementsToCheck, newRecords);

                for (Product2[] pr : forNewJunctions.keySet()) {
                    newJunctionRecords.addAll(AgreementHelper.createJunctionRecords(pr, forNewJunctions.get(pr)));  
                }
            } else {//just return if no changes found
                return;
            }
        }
        if (newJunctionRecords != null) {
            try {
                upsert newJunctionRecords;
            } catch (DmlException dmle) {
                newRecords.get(dmle.getDmlId(0)).addError('Error during creation of junction records. ' + dmle.getDmlMessage(0));
            }
        }
    }
/**
 * removes depricated junction records after Products__c field update
 * agreementsToCheck - list of Agreements with relational fields including Agreement_Products__r
 * newRecords - Trigger.new
 */
    private static void removeOldJunctions(Agreement__c[] agreementsToCheck, Map<Id, Agreement__c> newRecords) {
        String[] tmpCodesNew;
        Agreement_Product_Junction__c[] junctionsToDelete = new List<Agreement_Product_Junction__c>();
        for (Agreement__c agr : agreementsToCheck) {
            tmpCodesNew = newRecords.get(agr.Id).Products__c.split(',');
            for (Agreement_Product_Junction__c junction : agr.Agreement_Products__r) {
                if (!tmpCodesNew.contains(junction.Product_code__c)) {
                    junctionsToDelete.add(junction);
                }
            }
        }
        try {
            delete junctionsToDelete;
        } catch (DmlException dmle) {
            newRecords.get(dmle.getDmlId(0)).addError('Error during creation of junction records. ' + dmle.getDmlMessage(0));
        }

    }
    /**
     * returns data that we have to add to a junction table
     * agreementsToCheck - list of Agreements with relational fields including Agreement_Products__r
     * newRecords - TRigger.new
     */
    private static Map<Product2[], Agreement__c[]> getDataForNewJunctionRecords(Agreement__c[] agreementsToCheck, Map<Id, Agreement__c> newRecords) {
        String[] tmpCodesNew;
        String[] listOfCodes = new List<String>();
        Agreement__c[] listOfAgreements = new List<Agreement__c>();
        Map<Product2[], Agreement__c[]> forNewJunctions = new Map<Product2[], Agreement__c[]> ();
        for (Agreement__c agr : agreementsToCheck) {
            tmpCodesNew = newRecords.get(agr.Id).Products__c.split(',');
            for (String newCode : newRecords.get(agr.Id).Products__c.split(',')) {
                for (Agreement_Product_Junction__c junction : agr.Agreement_Products__r) {
                    if (junction.Product_code__c == newCode) {
                        tmpCodesNew.remove(tmpCodesNew.indexOf(newCode));
                    }
                }
            }
            if (tmpCodesNew.size() > 0) {
                listOfCodes.addAll(tmpCodesNew);
                listOfAgreements.add(agr);
            }
        }
        forNewJunctions.put([SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN :listOfCodes], listOfAgreements);
        return forNewJunctions;
   
    }

    /**
     * Creates new junction records
     * products - list of products associated with Agreement
     * agreements - list of agreements for junction records
     */
    private static Agreement_Product_Junction__c[] createJunctionRecords(Product2[] products, Agreement__c[] agreements) {
        Agreement_Product_Junction__c[] junctionRecords = new List<Agreement_Product_Junction__c>();
        for(Product2 prod : products) {
            for(Agreement__c agr : agreements) {
                if (agr.Products__c.split(',').contains(prod.ProductCode)) {
                    junctionRecords.add(new Agreement_Product_Junction__c(Agreement__c = agr.Id, Product__c = prod.Id));
                }
            }
        }
        return junctionRecords;
    }

    /**
     * returns list of ids of Agreement__c with modified field Products__c
     * newRecords - Trigger.new
     * oldRecords - Trigger.old
     */
    private static Id[] getRecordIdsWithModifiedCodes(Map<Id, Agreement__c> newRecords, Map<Id, Agreement__c> oldRecords) {
        Id[] modifiedAgreementIds = new List<Id>();
        for (Id agrId : newRecords.keySet()) {
            if (newRecords.get(agrId).Products__c != oldRecords.get(agrId).Products__c) {
                modifiedAgreementIds.add(agrId);
            }
        }
        return modifiedAgreementIds;
    }

/**
 * returns list of all Product Codes in list
 */
    private static String[] getAllProductCodesInList(Agreement__c[] agreements) {
        String[] codes = new List<String>();
        for (Agreement__c agr : agreements) {
            if (agr.Products__c != null && agr.Products__c.length() > 0) {
                codes.addAll(agr.Products__c.split(','));
            }
        }
        codes.sort();
        return codes;
    }
}
