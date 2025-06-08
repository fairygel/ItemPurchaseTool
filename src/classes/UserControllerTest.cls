@IsTest
public class UserControllerTest {

	@IsTest
	static void testIsUserManager() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		User u = new User(
				FirstName = 'Test',
				LastName = 'Manager',
				Alias = 'tman',
				Email = 'testmanager@example.com',
				Username = 'testmanager' + DateTime.now().getTime() + '@example.com',
				TimeZoneSidKey = 'Europe/Moscow',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				LanguageLocaleKey = 'en_US',
				ProfileId = p.Id,
				IsManager__c = true
		);
		insert u;

		Test.startTest();
		Boolean isManager;
		System.runAs(u) {
			isManager = UserController.isUserManager();
		}
		Test.stopTest();

		System.assertEquals(true, isManager, 'Expected user to be recognized as manager');
	}
}
