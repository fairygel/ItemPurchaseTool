@IsTest
public class ItemControllerTest {

	static String getFirstPicklistValue(Schema.SObjectField field) {
		List<Schema.PicklistEntry> entries = field.getDescribe().getPicklistValues();
		return entries.isEmpty() ? null : entries[0].getValue();
	}

	@TestSetup
	static void setupData() {
		String typeValue = getFirstPicklistValue(Item__c.Type__c);
		String familyValue = getFirstPicklistValue(Item__c.Family__c);

		insert new Item__c(
				Name__c = 'Test Item A',
				Description__c = 'This is a test description A',
				Family__c = familyValue,
				Type__c = typeValue,
				Price__c = 100,
				Image__c = 'imageA.png'
		);

		insert new Item__c(
				Name__c = 'Test Item B',
				Description__c = 'Another description B',
				Family__c = familyValue,
				Type__c = typeValue,
				Price__c = 200,
				Image__c = 'imageB.png'
		);
	}

	@IsTest
	static void testGetItemsBySearch_AllFilters() {
		String typeValue = getFirstPicklistValue(Item__c.Type__c);
		String familyValue = getFirstPicklistValue(Item__c.Family__c);

		Test.startTest();
		List<Item__c> results = ItemController.getItemsBySearch(
				'Item A',
				new List<String>{ familyValue },
				new List<String>{ typeValue }
		);
		Test.stopTest();

		System.assertEquals(1, results.size());
		System.assertEquals('Test Item A', results[0].Name__c);
	}

	@IsTest
	static void testGetItemsBySearch_NoFilters() {
		Test.startTest();
		List<Item__c> results = ItemController.getItemsBySearch('description', null, null);
		Test.stopTest();
		System.assert(results.size() > 0);
	}

	@IsTest
	static void testCreateItem() {
		String typeValue = getFirstPicklistValue(Item__c.Type__c);
		String familyValue = getFirstPicklistValue(Item__c.Family__c);
		Test.startTest();
		ItemController.createItem(
				'NewItem',
				'Created by test',
				150,
				typeValue,
				familyValue,
				'new.png'
		);
		Test.stopTest();
		List<Item__c> items = [SELECT Id FROM Item__c WHERE Name__c = 'NewItem'];
		System.assertEquals(1, items.size());
	}
}
