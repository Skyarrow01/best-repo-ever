({
	doInit : function(component, event, helper) {
        var action = component.get("c.getMemberSettings");
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.networkMember', resp);
            }
        });
        $A.enqueueAction(action);
	},
    toggled: function(component, event, helper) {
        var AllFeedsEmail = !component.find("AllFeedsEmail").get("v.checked");
        var toggleStatus = false;
		if (AllFeedsEmail)
            toggleStatus = true;
        else
            toggleStatus = false;
        
        var EndorsementEmail = !component.find("EndorsementEmail").set("v.disabled",toggleStatus);
        var ProfilePostEmail = !component.find("ProfilePostEmail").set("v.disabled",toggleStatus);
        var FollowersEmail = !component.find("FollowersEmail").set("v.disabled",toggleStatus);
        var LikeEmail = !component.find("LikeEmail").set("v.disabled",toggleStatus);
        var ChangeCommentEmail = !component.find("ChangeCommentEmail").set("v.disabled",toggleStatus);
        var ProfPostCommentEmail = !component.find("ProfPostCommentEmail").set("v.disabled",toggleStatus);
        var LaterCommentEmail = !component.find("LaterCommentEmail").set("v.disabled",toggleStatus);
        var BookmarkEmail = !component.find("BookmarkEmail").set("v.disabled",toggleStatus);
        var CommentAfterLikeEmail = !component.find("CommentAfterLikeEmail").set("v.disabled",toggleStatus);
        var MentionsPostEmail = !component.find("MentionsPostEmail").set("v.disabled",toggleStatus);
        var MentionsCommentEmail = !component.find("MentionsCommentEmail").set("v.disabled",toggleStatus);
        var BestAnswerEmail = !component.find("BestAnswerEmail").set("v.disabled",toggleStatus);
        var ItemFlaggedEmail = !component.find("ItemFlaggedEmail").set("v.disabled",toggleStatus);
        var DirectMessageEmail = !component.find("DirectMessageEmail").set("v.disabled",toggleStatus);
        var PendingReviewEmail = !component.find("PendingReviewEmail").set("v.disabled",toggleStatus);
        var CaseContactEmail = !component.find("CaseContactEmail").set("v.disabled",toggleStatus);

    },
    
    save: function(component, event, helper) {
        var AllFeedsEmail = !component.find("AllFeedsEmail").get("v.checked");
        var EndorsementEmail = !component.find("EndorsementEmail").get("v.checked");
        var ProfilePostEmail = !component.find("ProfilePostEmail").get("v.checked");
        var FollowersEmail = !component.find("FollowersEmail").get("v.checked");
        var LikeEmail = !component.find("LikeEmail").get("v.checked");
        var ChangeCommentEmail = !component.find("ChangeCommentEmail").get("v.checked");
        var ProfPostCommentEmail = !component.find("ProfPostCommentEmail").get("v.checked");
        var LaterCommentEmail = !component.find("LaterCommentEmail").get("v.checked");
        var BookmarkEmail = !component.find("BookmarkEmail").get("v.checked");
        var CommentAfterLikeEmail = !component.find("CommentAfterLikeEmail").get("v.checked");
        var MentionsPostEmail = !component.find("MentionsPostEmail").get("v.checked");
        var MentionsCommentEmail = !component.find("MentionsCommentEmail").get("v.checked");
        var BestAnswerEmail = !component.find("BestAnswerEmail").get("v.checked");
        var ItemFlaggedEmail = !component.find("ItemFlaggedEmail").get("v.checked");
        var DirectMessageEmail = !component.find("DirectMessageEmail").get("v.checked");
        var PendingReviewEmail = !component.find("PendingReviewEmail").get("v.checked");
        var CaseContactEmail = !component.find("CaseContactEmail").get("v.checked");

        var action = component.get("c.updateNetworkMember");
        action.setParams({"EndorsementEmail": EndorsementEmail, "ProfilePostEmail": ProfilePostEmail,
                          "FollowersEmail": FollowersEmail, "LikeEmail": LikeEmail,
                          "ChangeCommentEmail": ChangeCommentEmail, "ProfPostCommentEmail": ProfPostCommentEmail,
                          "LaterCommentEmail": LaterCommentEmail, "BookmarkEmail": BookmarkEmail,
                          "CommentAfterLikeEmail": CommentAfterLikeEmail, "MentionsPostEmail":MentionsPostEmail,
                          "MentionsCommentEmail": MentionsCommentEmail, "BestAnswerEmail": BestAnswerEmail,
                          "ItemFlaggedEmail": ItemFlaggedEmail, "DirectMessageEmail": DirectMessageEmail,
                          "PendingReviewEmail": PendingReviewEmail, "CaseContactEmail": CaseContactEmail,
                          "AllFeedsEmail": AllFeedsEmail});
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
            } else if (state === "INCOMPLETE") {
                // do something
            } else {
                console.log('FAILURE');
            }
        });
        $A.enqueueAction(action);
        
    }
})