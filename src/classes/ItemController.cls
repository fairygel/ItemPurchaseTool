public with sharing class ItemController {
	@AuraEnabled(cacheable = true)
	public static List<Item__c> getItemsBySearch(String searchKey,
												 List<String> familyFilters,
												 List<String> typeFilters) {
		String search = '%' + searchKey + '%';

		// if some filter is null or empty, we will ignore it
		// just by placing %%, what means always TRUE (every word contains '' lol)
		String ignoreFamily;
		String ignoreType;

		if (familyFilters == null || familyFilters.isEmpty()) {
			ignoreFamily = '%%';
		}

		if (typeFilters == null || typeFilters.isEmpty()) {
			ignoreType = '%%';
		}

		List<Item__c> results = [
			SELECT ID, Name__c, Description__c, Type__c, Family__c, Price__c, Image__c
			FROM Item__c
				WHERE (Name__c LIKE :search OR Description__c LIKE :search)
				AND ( Family__c IN :familyFilters OR Family__c LIKE :ignoreFamily)
				AND ( Type__c IN :typeFilters OR Type__c LIKE :ignoreType)
				LIMIT 50
		];

		return results;
	}


	@AuraEnabled(cacheable = true)
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

	@AuraEnabled
	public static void createItem(String name,
								  String description,
								  Decimal price,
								  String type,
								  String family,
								  String image) {
		try {
			Item__c newItem = new Item__c(
					Name = name,
					Name__c = name,
					Description__c = description,
					Price__c = price,
					Type__c = type,
					Family__c = family,
					Image__c = image
			);
			insert newItem;
		} catch (Exception e) {
			throw new AuraHandledException('Failed to insert item: ' + e.getMessage());
		}
	}


	@AuraEnabled(cacheable = true)
	public static List<String> getTypeOptions() {
		return getPicklistValues().get('Type');
	}

	@AuraEnabled(cacheable = true)
	public static List<String> getFamilyOptions() {
		return getPicklistValues().get('Family');
	}

}
