public with sharing class AccountController {
	@AuraEnabled(cacheable=true)
	public static Account getAccountDetails(Id accountId) {
		if (accountId == null) {
			throw new AuraHandledException('Account Id is required');
		}
		return [
				SELECT Id, Name, AccountNumber, Industry
				FROM Account
				WHERE Id = :accountId
				LIMIT 1
		];
	}
}
