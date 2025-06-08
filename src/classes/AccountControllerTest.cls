@isTest
private class AccountControllerTest {

	@isTest
	static void testGetAccountDetails_ValidId() {
		Account acc = new Account(Name = 'Test Account', AccountNumber = '12345', Industry = 'Technology');
		insert acc;

		Account result = AccountController.getAccountDetails(acc.Id);

		System.assertNotEquals(null, result, 'Result should not be null');
		System.assertEquals(acc.Id, result.Id, 'Ids should match');
		System.assertEquals('Test Account', result.Name, 'Names should match');
		System.assertEquals('12345', result.AccountNumber, 'AccountNumbers should match');
		System.assertEquals('Technology', result.Industry, 'Industries should match');
	}
}
