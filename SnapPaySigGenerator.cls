public with sharing class SnapPaySigGenerator {

    private static String prepareSignatureString(HttpRequest request, String accountId, String timestamp, String nonce) {
        String httpMethod = request.getMethod().toUpperCase();
        String requestUri = request.getEndpoint();
        String requestBody = httpMethod == 'POST' ? request.getBody() : '';

        // Generate MD5 hash of the request body and then encode it to base64
        String requestBodyContent;
        if (String.isNotBlank(requestBody)) {
            Blob md5Hash = Crypto.generateDigest('MD5', Blob.valueOf(requestBody));
            requestBodyContent = EncodingUtil.base64Encode(md5Hash);
        } else {
            requestBodyContent = '';
        }

        return accountId + httpMethod + requestUri + timestamp + nonce + requestBodyContent;
    }

    private static String generateSignature(String apiSecret, String dataToSign) {
        // Decode the private key (it is already a base64 string)
        Blob privateKeyBlob = EncodingUtil.base64Decode(apiSecret);
        // Convert the data to sign to a Blob
        Blob dataBlob = Blob.valueOf(dataToSign);
        // Encode the data with the private key as HMAC-SHA256
        Blob hmacSig = Crypto.generateMac('HmacSHA256', dataBlob, privateKeyBlob);

        // Convert the signature to Base64
        return EncodingUtil.base64Encode(hmacSig);
    }

    public static void signRequest(HttpRequest request, String username, String password, String accountId, String merchantId, String apiSecret) {
        Blob credentialsBlob = Blob.valueOf(username + ':' + password);
        String encodedCredentials = EncodingUtil.base64Encode(credentialsBlob);

        String nonce = UUID.randomUUID().toString().replaceAll('-', '');
        Long epochTime = Datetime.now().getTime() / 1000;
        String timestamp = String.valueOf(epochTime);
        String signatureString = prepareSignatureString(request, accountId, timestamp, nonce);

        // Create the HMAC signature
        String signature = generateSignature(apiSecret, signatureString);

        String hmacHeaderString = String.format('{0}:{1}:{2}:{3}', new List<String>{accountId, signature, nonce, timestamp});
        String hmacHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(hmacHeaderString));

        request.setHeader('Authorization', 'Basic ' + encodedCredentials);
        request.setHeader('accountid', accountId);
        request.setHeader('merchantid', merchantId);
        request.setHeader('signature', 'Hmac ' + hmacHeaderEncoded);
    }

}
