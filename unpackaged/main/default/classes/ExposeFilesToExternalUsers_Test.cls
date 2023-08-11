@isTest
public class ExposeFilesToExternalUsers_Test {

    @isTest
    public static void testFileVisibility() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.Email__c = 'test@test.com.invalid';
        acc.Phone = '987654245';
        insert acc;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.LinkedEntityId = acc.Id;
        insert cdl;
        
        //System.assertEquals([SELECT Visibility FROM ContentDocumentLink WHERE Id = :cdl.Id].Visibility, 'AllUsers');
        System.Test.StartTest();
    }
}