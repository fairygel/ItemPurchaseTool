public class FilterService {
	@AuraEnabled(cacheable = true)
	public static List<String> getFamilyOptions() {
		return getPicklistValues(Item__c.Family__c);
	}

	@AuraEnabled(cacheable = true)
	public static List<String> getTypeOptions() {
		return getPicklistValues(Item__c.Type__c);
	}

	private static List<String> getPicklistValues(SObjectField field) {
		DescribeFieldResult objField = field.getDescribe();
		List<PicklistEntry> entries = objField.getPicklistValues(); // all picklist fields

		List<String> values = new List<String>();

		for (PicklistEntry entry : entries) {
			values.add(entry.getValue());
		}

		return values;
	}
}