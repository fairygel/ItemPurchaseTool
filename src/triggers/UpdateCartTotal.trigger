trigger UpdateCartTotal on CartItem__c(after insert, after update, after delete) {
	Set<Id> cartIds = new Set<Id>();

	if (Trigger.isInsert || Trigger.isUpdate) {
		for (CartItem__c item : Trigger.new) {
			cartIds.add(item.Cart__c);
		}
	}

	if (Trigger.isDelete) {
		for (CartItem__c item : Trigger.old) {
			cartIds.add(item.Cart__c);
		}
	}

	List<Cart__c> cartsToUpdate = new List<Cart__c>();

	for (Id cartId : cartIds) {
		List<AggregateResult> result = [
			SELECT SUM(Total__c) total
			FROM CartItem__c
			WHERE Cart__c = :cartId
		];

		Decimal total = (Decimal)result[0].get('total');

		if (total == null) {
			total = 0;
		}

		cartsToUpdate.add(new Cart__c(Id = cartId, TotalAmount__c = total));
	}

	update cartsToUpdate;
}