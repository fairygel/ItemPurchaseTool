@IsTest
public class CartControllerTest {

	@IsTest
	static void testAddItemToCart_NewCart_NewItem() {
		Account acc = new Account(Name = 'Test Account');
		insert acc;

		Item__c item = new Item__c(Name__c = 'Test Item', Price__c = 10);
		insert item;

		Test.startTest();
		Decimal quantity = CartController.addItemToCart(acc.Id, item.Id, false);
		Test.stopTest();

		System.assertEquals(1, quantity, 'Quantity should be 1 on first insert');
	}

	@IsTest
	static void testAddItemToCart_ExistingCart_ExistingItem() {
		Account acc = new Account(Name = 'Test Account 2');
		insert acc;

		Item__c item = new Item__c(Name__c = 'Test Item 2', Price__c = 15);
		insert item;

		Cart__c cart = new Cart__c(Account__c = acc.Id, Status__c = 'New');
		insert cart;

		CartItem__c cartItem = new CartItem__c(Cart__c = cart.Id, Item__c = item.Id, Quantity__c = 1);
		insert cartItem;

		Test.startTest();
		Decimal quantity = CartController.addItemToCart(acc.Id, item.Id, false);
		Test.stopTest();

		System.assertEquals(2, quantity, 'Quantity should increment to 2');
	}

	@IsTest
	static void testGetCartItems_WithItems() {
		Account acc = new Account(Name = 'Test Account 3');
		insert acc;

		Item__c item = new Item__c(Name__c = 'Test Item 3', Price__c = 20);
		insert item;

		Cart__c cart = new Cart__c(Account__c = acc.Id, Status__c = 'New');
		insert cart;

		CartItem__c cartItem = new CartItem__c(Cart__c = cart.Id, Item__c = item.Id, Quantity__c = 3);
		insert cartItem;

		Test.startTest();
		List<CartItem__c> items = CartController.getCartItems(acc.Id);
		Test.stopTest();

		System.assertEquals(1, items.size(), 'Should return one cart item');
		System.assertEquals(3, items[0].Quantity__c, 'Quantity should match');
		System.assertEquals(item.Id, items[0].Item__c);
	}
}
