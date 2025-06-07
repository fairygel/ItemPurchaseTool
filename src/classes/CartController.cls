public with sharing class CartController {
	// return total amount of item in cart TODO: use return value
	@AuraEnabled
	public static Decimal addItemToCart(Id accountId, Id itemId) {
		List<Cart__c> carts = [SELECT Id FROM Cart__c WHERE Account__c = :accountId AND Status__c != 'Ordered' LIMIT 1];
		Cart__c cart;

		if (carts.isEmpty()) {
			cart = new Cart__c(Account__c = accountId, Status__c = 'New');
			insert cart;
		} else {
			cart = carts[0];
		}

		Id cartId = cart.Id;

		List<CartItem__c> existingItems =
			[SELECT Id, Quantity__c FROM CartItem__c WHERE Cart__c=:cart.Id AND Item__c = :itemId LIMIT 1];
		CartItem__c item;

		if (existingItems.isEmpty()) {
			item = new CartItem__c(Cart__c = cartId, Item__c = itemId, Quantity__c = 1);
			insert item;
		} else {
			item = existingItems[0];
			item.Quantity__c += 1;
			update item;
		}

		return item.Quantity__c;
	}

	@AuraEnabled
	public static List<CartItem__c> getCartItems(Id accountId) {
		List<Cart__c> carts = [SELECT Id FROM Cart__c WHERE Account__c = :accountId AND Status__c != 'Ordered' LIMIT 1];

		if (carts.isEmpty()) {
			return new List<CartItem__c>();
		}

		return [
			SELECT Id, Item__r.Name__c, Quantity__c, Total__c, Cart__r.TotalAmount__c
				FROM CartItem__c
				WHERE Cart__c = :carts[0].Id
		];
	}

}