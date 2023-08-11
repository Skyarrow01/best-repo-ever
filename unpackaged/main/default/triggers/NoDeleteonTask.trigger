trigger NoDeleteonTask on Task (before delete)
{
    Id profileId = UserInfo.getProfileId();
    Profile userProfile = [Select Id, Name from Profile where Id=:profileId];
    String profileName = userProfile.Name;
    Boolean noTaskDeletes = profileName == 'FIT User' || profileName == 'CSI User' || profileName == 'PIM User' ||
        profileName == 'Documentation User' || profileName == 'Product Engineer User'  || profileName == 'Product Availability';
    Boolean canDeleteTask = FeatureManagement.checkPermission('DeleteTaskAllowed');

    for (Task a : Trigger.old) {
        /* This prevents the following profiles from Deleting a Tasks Product Engineering, CSI, FIT, PIM, Documentation, Product Availability */
        if (noTaskDeletes && !canDeleteTask) {
            a.addError('You do not have permission to delete this record!');
        }
    }
}