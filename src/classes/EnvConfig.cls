public class EnvConfig {
	public static String getValue(String key) {
		Unsplash_Setting__mdt setting = Unsplash_Setting__mdt.getInstance(key);
		return setting != null? setting.Value__c : null;
	}
}