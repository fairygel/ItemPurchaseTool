public with sharing class PurchaseController {
	@AuraEnabled(cacheable=true)
	// return purchases and its content
	public static List<Purchase__c> getPurchases(Id accountId) {
		return [
			SELECT Id, Name__c, GrandTotal__c, CreatedDate, TotalItems__c,
				(SELECT Id, ItemId__r.Name__c, Amount__c, UnitCost__c FROM Purchase_Lines__r)
			FROM Purchase__c
			WHERE ClientId__c = :accountId
			ORDER BY CreatedDate DESC
		];
	}

	@AuraEnabled
	public static void checkoutCart(Id accountId) {
		// active cart
		List<Cart__c> carts = [
				SELECT Id FROM Cart__c
				WHERE Account__c = :accountId AND Status__c != 'Ordered' LIMIT 1
		];
		if (carts.isEmpty()) throw new AuraHandledException('no active cart');

		Cart__c cart = carts[0];

		// cart content
		List<CartItem__c> cartItems = [
				SELECT Item__c, Quantity__c, Item__r.Price__c
				FROM CartItem__c
				WHERE Cart__c = :cart.Id
		];
		if (cartItems.isEmpty()) throw new AuraHandledException('cart is empty');

		Purchase__c p = new Purchase__c(ClientId__c = accountId);
		insert p;

		List<PurchaseLine__c> lines = new List<PurchaseLine__c>();

		// fill purchase line from cart items
		for (CartItem__c ci : cartItems) {
			lines.add(new PurchaseLine__c(
					PurchaseId__c = p.Id,
					ItemId__c = ci.Item__c,
					Amount__c = ci.Quantity__c,
					UnitCost__c = ci.Item__r.Price__c
			));
		}

		insert lines;

		cart.Status__c = 'Ordered';
		update cart;
	}
}