public with sharing class ItemController {
	@AuraEnabled(cacheable=true)
	public static List<Item__c> getItemsBySearch(String searchKey, List<String> familyFilters, List<String> typeFilters) {
		String search = '%' + searchKey + '%';

		List<String> filters = new List<String>();
		filters.add('(Name__c LIKE :search OR Description__c LIKE :search)');

		if (familyFilters != null && !familyFilters.isEmpty()) {
			filters.add('Family__c IN :familyFilters');
		}
		if (typeFilters != null && !typeFilters.isEmpty()) {
			filters.add('Type__c IN :typeFilters');
		}

		String whereClause = String.join(filters, ' AND ');
		String query = 'SELECT Id, Name__c, Description__c, Type__c, Family__c, Price__c, Image__c FROM Item__c WHERE ' + whereClause + ' LIMIT 50';

		return Database.query(query);
	}


	@AuraEnabled(cacheable=true)
	public static Map<String, List<String>> getPicklistValues() {
		Map<String, List<String>> picklists = new Map<String, List<String>>();

		Schema.DescribeFieldResult familyField = Item__c.Family__c.getDescribe();
		List<Schema.PicklistEntry> familyEntries = familyField.getPicklistValues();
		List<String> familyValues = new List<String>();
		for (Schema.PicklistEntry entry : familyEntries) {
			familyValues.add(entry.getValue());
		}
		picklists.put('Family', familyValues);

		Schema.DescribeFieldResult typeField = Item__c.Type__c.getDescribe();
		List<Schema.PicklistEntry> typeEntries = typeField.getPicklistValues();
		List<String> typeValues = new List<String>();
		for (Schema.PicklistEntry entry : typeEntries) {
			typeValues.add(entry.getValue());
		}
		picklists.put('Type', typeValues);

		return picklists;
	}
}
