global with sharing class GetSkillsIdsAction {
@InvocableMethod(label='Get Skills Ids' description='Return Ids of Skills') 
global static List<List<Id>> getSkillsIds() {
List<Id> skillsIds = new List<Id> ();

/*
* 18 char Skills Ids in the org:
*
* Dutch - 0C5RM000000028I0AQ
* French - 0C5RM000000028D0AQ
* Spanish - 0C5RM000000026R0AQ
*/

skillsIds.add('0C5RM000000028I0AQ');
skillsIds.add('0C5RM000000026R0AQ');
skillsIds.add('0C53u000000L2OtCAK');
skillsIds.add('0C53u000000L2OuCAK');
skillsIds.add('0C53u000000L2OvCAK');
skillsIds.add('0C53u000000L2OwCAK');
skillsIds.add('0C53u000000L2OxCAK');
skillsIds.add('0C53u000000L2OyCAK');
skillsIds.add('0C53u000000L2OzCAK');
skillsIds.add('0C53u000000L2P0CAK');
skillsIds.add('0C53u000000L2P1CAK');
skillsIds.add('0C53u000000L2P2CAK');
skillsIds.add('0C53u000000L2P3CAK');
skillsIds.add('0C53u000000L2P4CAK');
skillsIds.add('0C53u000000L2P5CAK');
skillsIds.add('0C53u000000L2P6CAK');
skillsIds.add('0C53u000000L2P7CAK');
skillsIds.add('0C53u000000L2P8CAK');
skillsIds.add('0C53u000000L2P9CAK');


return new List<List<Id>> {skillsIds};
}
}