# SnapPaySigGenerator
The instructions for creating an HMAC signature for SnapPay authentication were quite terrible. To that end, here is an open source class in Apex for those of you who have to do this in Salesforce.
## Example Usage
Create your HTTPRequest as always, but sign the request before you send it.

    // These are my connection variables
    String accountId = '1000000001';
    String apiSecret = '2374fSF8RKJF8/aD08QFJHC874K3E5fg3=';
    String username = '1000000001';
    String password = 'fake-password';
    String merchantId = 'mikecsfdx0';
    
    // Set up my HTTP Request
    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setEndpoint('https://restapi-stage.snappayglobal.com/api/interop/GetPaymentDetails');
    request.setBody('{"accountid":"1001665093","token":"fake-token"}');
    
    // Before sending, use nifty class to sign the request
    SnapPaySigGenerator.signRequest(request, username, password, accountId, merchantId, apiSecret);
    
    // Now enjoy success!
    Http http = new Http();
    HttpResponse response = http.send(request);
    System.debug(response);
    System.debug(response.getBody());
