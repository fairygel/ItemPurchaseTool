trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after update, after delete, after undelete) {
	Set<Id> purchaseIds = new Set<Id>();

	if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
		for (PurchaseLine__c line : Trigger.new) {
			if (line.PurchaseId__c != null) {
				purchaseIds.add(line.PurchaseId__c);
			}
		}
	}

	if (Trigger.isUpdate || Trigger.isDelete) {
		for (PurchaseLine__c line : Trigger.old) {
			if (line.PurchaseId__c != null) {
				purchaseIds.add(line.PurchaseId__c);
			}
		}
	}

	if (purchaseIds.isEmpty()) return;

	List<PurchaseLine__c> lines = [
			SELECT PurchaseId__c, Amount__c, UnitCost__c
			FROM PurchaseLine__c
			WHERE PurchaseId__c IN :purchaseIds
	];

	Map<Id, Decimal> grandTotalMap = new Map<Id, Decimal>();
	Map<Id, Integer> totalItemsMap = new Map<Id, Integer>();

	for (PurchaseLine__c line : lines) {
		Id purchaseId = line.PurchaseId__c;
		Decimal amount = line.Amount__c == null ? 0 : line.Amount__c;
		Decimal unitCost = line.UnitCost__c == null ? 0 : line.UnitCost__c;

		grandTotalMap.put(purchaseId,
				grandTotalMap.containsKey(purchaseId)
				? grandTotalMap.get(purchaseId) + (amount * unitCost)
				: amount * unitCost
		);

		totalItemsMap.put(purchaseId,
				totalItemsMap.containsKey(purchaseId)
				? totalItemsMap.get(purchaseId) + amount.intValue()
				: amount.intValue()
		);
	}

	List<Purchase__c> toUpdate = new List<Purchase__c>();
	for (Id purchaseId : purchaseIds) {
		toUpdate.add(new Purchase__c(
				Id = purchaseId,
				GrandTotal__c = grandTotalMap.get(purchaseId),
				TotalItems__c = totalItemsMap.get(purchaseId)
		));
	}

	update toUpdate;
}