public class ProductPartSyncScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        if(isUserAuthorized()){
    		Database.executeBatch(new ProductPartSyncBatch(), 20);
        }
    }
    
    private static Boolean isUserAuthorized() { 
        Id profileId = UserInfo.getProfileId();
        List<Profile> pro = [SELECT Name FROM Profile WHERE Id = :profileId];
        if (!pro.isEmpty() && pro[0].Name == 'System Administrator'){
            return true;
        } 
        
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'CQ_Product_Admin'];
        if(!psa.isEmpty()){
            return true;
        }
        return false;
    }
}