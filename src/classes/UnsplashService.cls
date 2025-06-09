public with sharing class UnsplashService {
	private static final String UNSPLASH_URL = 'https://api.unsplash.com/search/photos?query=';

	@AuraEnabled(cacheable=true)
	public static String searchPhotoUrl(String query) {
		if (query==null) return null;

		String endPoint = UNSPLASH_URL + EncodingUtil.urlEncode(query, 'UTF-8');

		Http http = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint(endPoint);
		req.setHeader('Authorization', 'Client-ID ' + EnvConfig.getValue('Unsplash_Key'));
		req.setMethod('GET');

		HttpResponse res = http.send(req);

		if (res.getStatusCode() == 200) {
			// response
			Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
			List<Object> results = (List<Object>) payload.get('results');

			if (!results.isEmpty()) {
				// get first image url
				Map<String, Object> first = (Map<String, Object>) results[0];
				Map<String, Object> urls = (Map<String, Object>) first.get('urls');

				return (String) urls.get('regular');
			}
		}
		return null;
	}
}