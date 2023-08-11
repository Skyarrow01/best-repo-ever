@isTest
public class agi_CustomMenuControllerTest {

    @isTest (seeAllData=true)
    static void test1(){
        agi_CustomMenuController.allTopics t = agi_CustomMenuController.fetchTopicInformation('notgoingtobehere','notgoingtobehere');
		System.assert(t.firstTopicList.size() == 0);
		System.assert(t.SecondTopicList.size() == 0);

    }
    
    @isTest
    static void test2(){
        String profInfo = agi_CustomMenuController.fetchProfileInformation();
        System.assert(profInfo != '');
    }
    
    @isTest (seeAllData=true)
    static void test3(){
        agi_CustomMenuController.allTopics t = agi_CustomMenuController.fetchTopicInformation('New Product Announcements, FW/SW Updates Announcements, Testing Section For New Members, Community Forum Feedback and Suggestions',
                                                                                              'Open Source Devices, PLC/Field I/O, HMI/Industrial Monitors, Drives/Motors, Motion Control, Communications Products, Process Control, Power Products/Circuit Protection, Relays/Timers, Wiring, Mechanical, Electrical Field Devices');
		System.debug(t);
        System.assert(t.firstTopicList.size() > 0);
		System.assert(t.SecondTopicList.size() > 0);

    }
    
}