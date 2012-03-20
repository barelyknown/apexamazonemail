public virtual class AWS {
  
  public final String KEY = 'YOUR_KEY_GOES_HERE';
  public final String SECRET = 'YOUR_SECRET_GOES_HERE';
  	
	public string signature(String awsNow, String secret) {
		Blob bsig = Crypto.generateMac('HmacSHA256', Blob.valueOf(awsNow), Blob.valueOf(secret));          
		return EncodingUtil.base64Encode(bsig); 
	} 
	
	public string formatDateForAWS(Datetime now) {
		return now.formatGmt('EEE, d MMM yyyy HH:mm:ss Z');           
	}
	
	public string headerForAmazonAuthorization(String accessKey, String signature) {
		return 'AWS3-HTTPS AWSAccessKeyId='+accessKey+', Algorithm=HmacSHA256, Signature='+signature;
	}
	
}