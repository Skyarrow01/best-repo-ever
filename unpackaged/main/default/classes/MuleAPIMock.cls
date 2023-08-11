@isTest
global class MuleAPIMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/plain');
        response.setBody('OK');
        response.setStatusCode(200);
        return response; 
    }
}