/*
    Class Name : Docuvault_CopyAWSFile
    Created By : Docuvault Team
    Description: To copy the AWS content from parent file to child
*/
public without Sharing Class Docuvault_CopyAWSFile implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    List <ID> cloudFileIds;
    
    public Docuvault_CopyAWSFile (List <ID> cloudFileIds) {
        this.cloudFileIds = cloudFileIds;
    }
    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Name, TVA_CFB__Bucket_Name__c, TVA_CFB__Region__c, TVA_CFB__External_File_Name__c, '
                    +' TVA_CFB__File_Size_in_Bytes__c, TVA_CFB__File_Type__c, TVA_CFB__Folder__c, Parent_Cloud_File_Id__c '
                    +' FROM TVA_CFB__Cloud_Files__c WHERE ID IN: cloudFileIds';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<TVA_CFB__Cloud_Files__c> scope){
        List <TVA_CFB__Cloud_Files__c> cloudFilesToUpdate = new List <TVA_CFB__Cloud_Files__c> ();
        List <TVA_CFB__Cloud_Files__c> cloudFilesToDelete = new List <TVA_CFB__Cloud_Files__c> ();
        for (TVA_CFB__Cloud_Files__c cloudFile : scope) {
            TVA_CFB__Cloud_Files__c returnedFile = doAWSCopyCallout (cloudFile);
            if (returnedFile.TVA_CFB__Reponse_Code__c == '200') {
                cloudFilesToUpdate.add (returnedFile);
            } else {
                cloudFilesToDelete.add (returnedFile);
            }
        }
        
        if (!cloudFilesToUpdate.isEmpty ()) {
            update cloudFilesToUpdate;
        } 
        if (!cloudFilesToDelete.isEmpty ()) {
            delete cloudFilesToDelete;
        }
    }
    public void finish(Database.BatchableContext BC){
    
    }
    
    public static TVA_CFB__Cloud_Files__c doAWSCopyCallout (TVA_CFB__Cloud_Files__c cloudFile) {
        Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll();
        TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance(userInfo.getUserId());
        Datetime now = Datetime.now();
        String amzDate = now.formatGmt('yyyyMMdd') + 'T' + now.formatGmt('HHmmss') + 'Z';
    
        Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(''));
        String payloadaction = EncodingUtil.convertToHex(hash);
    
        String parentCloudFileName = cloudFile.Parent_Cloud_File_Id__c+'.'+cloudFile.TVA_CFB__File_Type__c;
        String newCloudFilename = cloudFile.Id+'.'+cloudFile.TVA_CFB__File_Type__c;
        
        String amazonUrl = TVA_CFB.AmazonS3Authentication.getAmazonURL(cloudFile.TVA_CFB__Bucket_Name__c, cloudFile.TVA_CFB__Region__c, regionEndpoints);
        
        String canonicalRequest = 'PUT\n/' + newCloudFilename + '\n\ncontent-type:application/json' 
                                +'\nhost:' + amazonUrl.removeStart('https://') 
                                +'\nx-amz-content-sha256:' + Payloadaction 
                                +'\nx-amz-copy-source:' + amazonURL + '/' + parentCloudFileName
                                +'\nx-amz-date:' + amzDate 
                                +'\nx-amz-target:s3:*' 
                                +'\n\ncontent-type;host;x-amz-content-sha256;x-amz-copy-source;x-amz-date;x-amz-target\n'
                                +payloadaction;
    
        Blob hashCanonical = Crypto.generateDigest('SHA-256', Blob.valueOf(CanonicalRequest));
        String canonicalHash = EncodingUtil.convertToHex(hashCanonical);
    
        String stringtoSign = 'AWS4-HMAC-SHA256\n'+amzDate+'\n' 
                                +DateTime.Now().formatGmt('yyyyMMdd')
                                +'/'+cloudFile.TVA_CFB__Region__c
                                +'/s3/aws4_request\n'+canonicalHash;
    
        Blob kDate = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(DateTime.Now().formatGmt('yyyyMMdd')), 
                                                    Blob.valueOf('AWS4' + credentials.TVA_CFB__secret_key__c));
                                                    
        Blob kRegion = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(cloudFile.TVA_CFB__Region__c), kDate);
        blob kService = Crypto.generateMac('HMAC-SHA256', Blob.valueOf('s3'), kRegion);
        blob kSigning = Crypto.generateMac('HMAC-SHA256', Blob.valueOf('aws4_request'), kService);
        Blob bsig = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(StringtoSign), kSigning);
    
        String signature = EncodingUtil.convertToHex(bsig);
    
        String authHeader = 'AWS4-HMAC-SHA256 Credential='
                            +credentials.TVA_CFB__Access_Key__c+'/' 
                            +DateTime.Now().formatGmt('yyyyMMdd')+'/'+cloudFile.TVA_CFB__Region__c+'/s3/aws4_request,' 
                            +'SignedHeaders=content-type;host;x-amz-target;'
                            +'x-amz-content-sha256;x-amz-copy-source;'
                            +'x-amz-date,Signature=' + signature;
        
        HttpRequest con = NEW HttpRequest();
        con.setMethod ('PUT');
        con.setEndPoint (amazonURL+'/'+newCloudFilename);
        con.setHeader ('x-amz-copy-source', amazonURL + '/' + parentCloudFileName);
        con.setHeader ('host', amazonUrl.removeStart('https://'));
        con.setHeader ('Content-Type', 'application/json');
        con.setHeader ('x-amz-target', 's3:*');
        con.setHeader ('x-amz-content-sha256', payloadaction);
        con.setHeader ('x-amz-date', amzDate);
        con.setHeader ('Authorization', authHeader);
        con.setHeader ('Connection', 'keep-alive');
    
        Http http = NEW Http();
        HTTPResponse awsResponse = NEW HTTPResponse();
        if (!Test.isRunningTest()) {
            awsResponse = http.send(con);
        } else {
           awsResponse.setStatusCode(200);
           awsResponse.setHeader('x-amz-version-id','123'); 
        }
        if (awsResponse.getStatusCode() == 200) {
            cloudFile.TVA_CFB__E_Tag__c = awsResponse.getBody().subStringbetween('<ETag>"', '"</ETag>');
            cloudFile.TVA_CFB__Amazon_Version_ID__c = awsResponse.getHeader('x-amz-version-id');
        }
        cloudFile.TVA_CFB__Reponse_Code__c = String.valueOf(awsResponse.getStatusCode());
        return cloudFile;
        
    }
}