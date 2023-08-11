({
    doInit : function(component, event, helper) {
        var showRestore = false;
        var action = component.get("c.fetchVersionRecords");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var records = response.getReturnValue();
            console.log(records);
            for ( var i = 0; i < records.length; i++ ) {
                
                if (records[i].showRestore) {
                    showRestore = records[i].showRestore;
                }
                if ( records[i].isCloudFile == false )  {
                    records[i].displayIconName = 'utility:change_record_type';
                }else if(records[i].isCloudFile == true){
                    records[i].displayIconName = '';
                }
            }
            var fields = [];
            
            fields.push ({
                type: 'button', 
                initialWidth: 10,
                typeAttributes: {
                    iconName: 'utility:download',
                    title: 'Download',
                    name: 'download',
                }
            });
            if (showRestore) {
                fields.push ({ 
                    initialWidth: 10,
                    type: 'button',
                    typeAttributes: {
                        iconName: {
                            fieldName: 'displayIconName'
                        },
                        name: 'restore',
                        title: 'Restore',
                    }
                });
                
            }
            
            fields.push ({fieldName: 'versionId', type: 'url', initialWidth: 10, hideDefaultActions: true,
                          typeAttributes: {
                              tooltip: { fieldName: 'version' },
                              label: {
                                  fieldName: 'version',
                              }, target: '_blank'
                          }
                         });
            
            fields.push ({label: 'File Name', initialWidth: 300, fieldName: 'fileName', type: 'text'});
            
            fields.push ({label: 'Check In Comments', fieldName: 'checkInComments', type: 'text', initialWidth: 300, wrapText: true, hideDefaultActions: true});
            fields.push ({label: 'Last Modified By', fieldName: 'lastModifiedBy', type: 'text', initialWidth: 300,hideDefaultActions: true});
            fields.push ({label: 'Last Modified Date', fieldName: 'lastModifiedDate', type: 'datetime', initialWidth: 200,hideDefaultActions: true});
            
            component.set('v.versionHistoryFields', fields);
            
            component.set("v.versionList",  records);
        });
        $A.enqueueAction(action);     
    },
    
    viewRecord : function(component, event, helper) {
        var recId = event.getParam('row').recordId;
        var actionName = event.getParam('action').name;
        if ( actionName == 'download' ) {
            var cloudObj = event.getParam('row').isCloudFile;
            var downloadUrl = '';
            if(cloudObj == true){
                downloadUrl = '/apex/TVA_CFB__DownloadFile?id='+recId;
                window.open(downloadUrl,'_blank');  
            }else{
                downloadUrl = '/apex/TVA_CFB__DownloadFileVersion?id='+recId;
                window.open(downloadUrl,'_blank');  
            }
        } else if ( actionName == 'restore' ) {
            var restoreUrl = '/apex/Docuvault_VersionRestore?id='+recId+'&cloudFileId='+component.get('v.recordId');
            window.open(restoreUrl,"_self"); 
        }
    }
})