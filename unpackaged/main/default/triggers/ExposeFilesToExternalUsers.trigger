trigger ExposeFilesToExternalUsers on ContentDocumentLink (before insert) {
    
    //make the file visibility to all users
    for(ContentDocumentLink link : Trigger.New) {
        try {
            link.ShareType = 'I';
            link.Visibility = 'AllUsers';
            
        } catch(Exception e) {
            
        }
    }
}