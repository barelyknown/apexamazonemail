public class SES extends AWS {

	public final String ENDPOINT = 'https://email.us-east-1.amazonaws.com';
	public final String METHOD = 'POST';

	public SES () {
	  
	}
    
	public HttpResponse sendSimpleEmail(String amazonSimpleEmail) {	
	  String awsFormattedNow = formatDateForAWS(Datetime.now());
		HttpRequest httpReq = new HttpRequest();
		httpReq.setMethod(METHOD);
		httpReq.setEndpoint(ENDPOINT);
		httpReq.setHeader('X-Amzn-Authorization', headerForAmazonAuthorization(key,signature(awsFormattedNow,this.secret)));
		httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		httpReq.setHeader('Date', awsFormattedNow);
		httpReq.setBody(amazonSimpleEmail);
		Http http = new Http();
		HttpResponse response = http.send(httpReq);
		return response;
	}
	
	
	
}