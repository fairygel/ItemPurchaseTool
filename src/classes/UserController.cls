public with sharing class UserController {
	@AuraEnabled(cacheable=true)
	public static Boolean isUserManager() {
		return [SELECT IsManager__c FROM User WHERE Id = :UserInfo.getUserId()].IsManager__c;
	}
}