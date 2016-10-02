app.service('notificationsFactory', function() {
    var factory = this;
    this.currentUserID = 0;

    var contributionAddedTemplate = function(label) {
        return "A new "+label+" has been added to ((contentLink))";
    };
    this.added = {
        Review: contributionAddedTemplate("review"),
        CompatibilityNote: contributionAddedTemplate("compatibility note"),
        InstallOrderNote: contributionAddedTemplate("install order note"),
        LoadOrderNote: contributionAddedTemplate("load order note"),
        Correction: "A new ((correctionType)) has been posted on ((contentLink))",
        Comment: "A new comment has been posted on ((contentLink))",
        ModTag: contributionAddedTemplate("tag"),
        ModListTag: contributionAddedTemplate("tag"),
        ModAuthor: "((authorUserClause)) been added as ((authorRole)) for ((contentLink))",
        ReputationLink: "((endorser)) has endorsed you"
    };

    this.updated = {
        Mod: "((contentLink)) has been updated",
        ModList: "((contentLink)) has been updated"
    };

    this.removed = {
        ModTag: "Your tag ((tagText)) was removed from ((contentLink))",
        ModListTag: "Your tag ((tagText)) was removed from ((contentLink))",
        ModAuthor: "((authorUserClause)) been removed as ((authorRole)) for ((contentLink))",
        ReputationLink: "((endorser)) has unendorsed you"
    };

    // Handles hidden, unhidden, approved, and unapproved events
    var contributionChangedTemplate = function(label) {
        return "((ownershipClause)) "+label+" for ((contentLink)) has been ((changeVerb))";
    };
    this.changed = {
        Review: contributionChangedTemplate("review"),
        CompatibilityNote: contributionChangedTemplate("compatibility note"),
        InstallOrderNote: contributionChangedTemplate("install order note"),
        LoadOrderNote: contributionChangedTemplate("load order note"),
        Correction: contributionChangedTemplate("((correctionType))"),
        Comment: "((ownershipClause)) comment on ((contentLink)) has been ((changeVerb))",
        Mod: "((contentLink)) has been ((changeVerb))",
        ModList: "((contentLink)) has been ((changeVerb))"
    };

    this.status = {
        Correction: "((correctionDescription)) has ((statusChange))",
        User: "((statusChange))"
    };

    var contributionMessageTemplate = function(label) {
        return "A moderator left a message on your "+label+" for ((contentLink))";
    };
    this.message = {
        Message: "((message))",
        Review: contributionMessageTemplate("review"),
        CompatibilityNote: contributionMessageTemplate("compatibility note"),
        InstallOrderNote: contributionMessageTemplate("install order note"),
        LoadOrderNote: contributionMessageTemplate("load order note")
    };

    this.milestones = {
        Mod: "((contentLink)) has ((getMilestoneValue)) stars.",
        ModList: "((contentLink)) has ((getMilestoneValue)) stars.",
        UserReputation: "You have ((getMilestoneValue)) reputation. ((getPermissions))"
    };

    this.permissions = [
        "",
        "You can now use a custom avatar and create new tags.",
        "You can now submit, discuss, and vote on corrections.",
        "You can now endorse up to 5 other users.",
        "You can now submit mods to the platform.",
        "You can now endorse up to 10 other users.",
        "You can now endorse up to 15 other users.",
        "You can now set your own user title."
    ];

    var noteContentLink =
        '<a href="#/mod/{{content.first_mod.id}}">{{content.first_mod.name}}</a> and ' +
        '<a href="#/mod/{{content.second_mod.id}}">{{content.second_mod.name}}</a>';
    var associatedModLink =
        '<a href="#/mod/{{content.mod.id}}">{{content.mod.name}}</a>';
    var associatedModListLink =
        '<a href="#/mod-list/{{content.mod_list.id}}">{{content.mod_list.name}}</a>';
    var noteCorrectionCommentLink = function(noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="#/mod/{{content.commentable.correctable.first_mod.id}}/' + noteTypeDashed + '/{{content.commentable.correctable_id}}">your ' + noteType + ' note correction</a>';
    };
    var noteCorrectionLink = function(noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="#/mod/{{content.correctable.first_mod.id}}/' + noteTypeDashed + '/{{content.correctable_id}}">your ' + noteType + ' note</a>';
    };
    this.contentLinks = {
        Review: associatedModLink,
        CompatibilityNote: noteContentLink,
        InstallOrderNote: noteContentLink,
        LoadOrderNote: noteContentLink,
        ModTag: associatedModLink,
        ModListTag: associatedModListLink,
        ModAuthor: associatedModLink,
        Mod: '<a href="#/mod/{{event.content_id}}">{{content.name}}</a>',
        ModList: '<a href="#/mod-list/{{event.content_id}}">{{content.name}}</a>',
        Comment: {
            key: "commentable",
            Article: '<a href="#/article/{{content.commentable_id}}">{{content.commentable.title}}</a>',
            User: '<a href="#/user/{{content.commentable_id}}">your profile</a>',
            Correction: {
                key: "correctable",
                Mod: '<a href="#/mod/{{content.commentable.correctable_id}}">your appeal</a>',
                CompatibilityNote: noteCorrectionCommentLink("compatibility"),
                InstallOrderNote: noteCorrectionCommentLink("install order"),
                LoadOrderNote: noteCorrectionCommentLink("load order")
            },
            ModList: '<a href="#/mod-list/{{content.commentable_id}}/comments">your mod list</a>'
        },
        Correction: {
            key: "correctable",
            Mod: '<a href="#/mod/{{content.correctable_id}}">your appeal</a>',
            CompatibilityNote: noteCorrectionLink("compatibility"),
            InstallOrderNote: noteCorrectionLink("install order"),
            LoadOrderNote: noteCorrectionLink("load order")
        }
    };

    var noteCorrectionDescription = function(noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return 'Your correction on <a href="#/user/{{content.correctable.submitter.id}}">{{content.correctable.submitter.username}}\'s</a> <a href="#/mod/{{content.correctable.first_mod.id}}/'+noteTypeDashed+'/{{content.correctable_id}}">'+noteType+' note</a>';
    };
    this.correctionDescriptions = {
        Mod: 'Your appeal to mark <a href=""></a> as ',
        CompatibilityNote: noteCorrectionDescription('compatibility'),
        InstallOrderNote: noteCorrectionDescription('install order'),
        LoadOrderNote: noteCorrectionDescription('load order')
    };

    this.statusChanges = {
        Correction: {
            key: "status",
            open: "has been re-opened",
            passed: "has passed",
            failed: "has failed",
            closed: "has been closed"
        },
        User: {
            key: "role",
            banned: "You have been banned.",
            restricted: "Your account has been restricted.  You can no longer make public contributions.",
            user: "Your account has been returned to normal status.",
            moderator: "You are now a moderator on Mod Picker!",
            admin: "You are now a site admin.  Remember, with great power comes great responsibility."
        }
    };

    this.starMilestones = [10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000];
    this.reputationMilestones = [10, 20, 40, 80, 160, 320, 640, 1280];

    this.getNotificationTemplate = function(event) {
        var storedEvents = ["added", "removed", "updated", "status", "message"];
        var changeEvents = ["hidden", "unhidden", "approved", "unapproved"];
        var eventType = event.event_type, contentType = event.content_type;
        if (storedEvents.contains(eventType)) {
            return factory[eventType][contentType];
        } else if (changeEvents.contains(eventType)) {
            return factory.changed[contentType];
        } else if (eventType.startsWith("milestone")) {
            return factory.milestones[contentType];
        }
    };

    this.getNotification = function(event) {
        var template = factory.getNotificationTemplate(event);
        return template.replace(/\(\(([\w]+)\)\)/g, function(match) {
            return factory[match.slice(2, -2)](event);
        });
    };

    this.setCurrentUserID = function(currentUserID) {
        factory.currentUserID = currentUserID;
    };

    // HELPER FUNCTIONS
    this.extractMilestoneNumber = function(eventType) {
        return parseInt(eventType.slice(9));
    };

    this.getTemplateObject = function(object, content, key, keysfx) {
        var result = object[key];
        if (typeof result === "object") {
            var nextContent = content[result.key];
            return factory.getTemplateObject(result, nextContent, content[result.key + keysfx], keysfx);
        } else {
            return result;
        }
    };

    this.contentLink = function(event) {
        return factory.getTemplateObject(factory.contentLinks, event.content, event.content_type, "_type");
    };

    this.correctionType = function(event) {
        return (event.content.correctable_type === "Mod" ? "appeal" : "correction");
    };

    this.authorUserClause = function(event) {
        if (factory.currentUserID !== event.content.user.id) {
            return '<a href="#/user/{{content.user.id}}">{{content.user.username}}</a> has';
        } else {
            return 'You have';
        }
    };

    this.authorRole = function(event) {
        if (event.content.role === "author") {
            return "an " + event.content.role;
        } else {
            return "a " + event.content.role;
        }
    };

    this.endorser = function(event) {
        return '<a href="#/user/{{content.source_user.id}}">{{content.source_user.name}}</a>';
    };

    this.changeVerb = function(event) {
        return event.event_type;
    };

    this.correctionDescription = function(event) {
        return factory.correctionDescriptions[event.content.correctable_type];
    };

    this.statusChange = function(event) {
        return factory.getTemplateObject(factory.statusChanges, event.content, event.content_type, "");
    };

    this.message = function(event) {
        if (!event.content.sent_to) {
            return event.content.text;
        } else {
            // TODO: link to inbox
            // TODO: include sender username
            return "You've recieved a new message";
        }
    };

    this.getMilestoneValue = function(event) {
        var index = factory.extractMilestoneNumber(event.event_type) - 1;
        if (event.content_type === "UserReputation") {
            return factory.reputationMilestones[index];
        } else {
            return factory.starMilestones[index];
        }
    };

    this.getPermissions = function(event) {
        var index = factory.extractMilestoneNumber(event.event_type) - 1;
        return factory.permissions[index];
    };

    this.ownershipClause = function(event) {
        if (factory.currentUserID !== event.content.submitted_by) {
            return "A";
        } else {
            return "Your"
        }
    };

    return this;
});