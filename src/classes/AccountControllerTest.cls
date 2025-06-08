@isTest
private class AccountControllerTest {

	@isTest
	static void testGetAccountDetails_ValidId() {
		// Arrange: создаём тестовую запись Account
		Account acc = new Account(Name = 'Test Account', AccountNumber = '12345', Industry = 'Technology');
		insert acc;

		// Act: вызываем метод контроллера
		Account result = AccountController.getAccountDetails(acc.Id);

		// Assert: проверяем, что полученные данные соответствуют сохранённым
		System.assertNotEquals(null, result, 'Result should not be null');
		System.assertEquals(acc.Id, result.Id, 'Ids should match');
		System.assertEquals('Test Account', result.Name, 'Names should match');
		System.assertEquals('12345', result.AccountNumber, 'AccountNumbers should match');
		System.assertEquals('Technology', result.Industry, 'Industries should match');
	}
}
