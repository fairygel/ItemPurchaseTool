@IsTest
private class PurchaseControllerTest {

	static String getFirstPicklistValue(Schema.sObjectField field) {
		Schema.DescribeFieldResult describe = field.getDescribe();
		for (Schema.PicklistEntry entry : describe.getPicklistValues()) {
			if (entry.isActive()) {
				return entry.getValue();
			}
		}
		return null;
	}

	@IsTest
	static void testCheckoutCartAndGetPurchases() {
		Account acc = new Account(Name = 'Test Account');
		insert acc;

		String type = getFirstPicklistValue(Item__c.Type__c);
		String family = getFirstPicklistValue(Item__c.Family__c);

		Item__c item = new Item__c(
				Name__c = 'Test Item',
				Description__c = 'Test Description',
				Price__c = 50,
				Type__c = type,
				Family__c = family
		);
		insert item;

		Cart__c cart = new Cart__c(Account__c = acc.Id, Status__c = 'New');
		insert cart;

		CartItem__c ci = new CartItem__c(
				Cart__c = cart.Id,
				Item__c = item.Id,
				Quantity__c = 2
		);
		insert ci;

		Test.startTest();
		PurchaseController.checkoutCart(acc.Id);
		List<Purchase__c> purchases = PurchaseController.getPurchases(acc.Id);
		Test.stopTest();

		System.assertEquals(1, purchases.size());
		Purchase__c purchase = purchases[0];
		System.assertEquals(1, purchase.Purchase_Lines__r.size());
		PurchaseLine__c line = purchase.Purchase_Lines__r[0];
		System.assertEquals(item.Id, line.ItemId__c);
		System.assertEquals(2, line.Amount__c);
		System.assertEquals(50, line.UnitCost__c);
	}
}
