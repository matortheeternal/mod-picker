app.service('notificationsFactory', function() {
    var factory = this;
    this.currentUserID = 0;

    var contributionAddedTemplate = function(label) {
        return "A new "+label+" has been added to ((contentLink))";
    };
    this.added = {
        Mod: "A new mod, ((contentLink)), has been submitted",
        ModList: "A new mod list, ((contentLink)), has been created",
        Review: contributionAddedTemplate("review"),
        CompatibilityNote: contributionAddedTemplate("compatibility note"),
        InstallOrderNote: contributionAddedTemplate("install order note"),
        LoadOrderNote: contributionAddedTemplate("load order note"),
        Correction: "A new ((correctionType)) has been posted on ((contentLink))",
        Comment: "A ((commentContext)) comment has been posted on ((contentLink))",
        ModTag: contributionAddedTemplate("tag"),
        ModListTag: contributionAddedTemplate("tag"),
        ModAuthor: "((authorUserClause)) been added as ((authorRole)) for ((contentLink))",
        ReputationLink: "((endorser)) has endorsed ((endorsee))"
    };

    this.updated = {
        Mod: "((contentLink)) has been updated",
        ModList: "((contentLink)) has been updated"
    };

    this.removed = {
        ModTag: "((ownershipClause)) tag ((tagText)) was removed from ((contentLink))",
        ModListTag: "((ownershipClause)) tag ((tagText)) was removed from ((contentLink))",
        ModAuthor: "((authorUserClause)) been removed as ((authorRole)) for ((contentLink))",
        ReputationLink: "((endorser)) has unendorsed ((endorsee))"
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
        User: "((statusChange))",
        ModList: "((contentLink)) has been marked ((statusChange))"
    };

    var contributionMessageTemplate = function(label) {
        return "A moderator left a message on your "+label+" for ((contentLink))";
    };
    this.message = {
        Message: "((messageText))",
        Review: contributionMessageTemplate("review"),
        CompatibilityNote: contributionMessageTemplate("compatibility note"),
        InstallOrderNote: contributionMessageTemplate("install order note"),
        LoadOrderNote: contributionMessageTemplate("load order note")
    };

    this.milestones = {
        Mod: "((contentLink)) has ((getMilestoneValue)) stars.",
        ModList: "((contentLink)) has ((getMilestoneValue)) stars.",
        UserReputation: "((userClause)) ((getMilestoneValue)) reputation. ((getPermissions))"
    };

    this.permissions = [
        /*10*/ "You can now use a custom avatar and create help pages.",
        /*20*/ "You can create new tags and make curator requests.",
        /*40*/ "You can now submit, discuss, and vote on corrections.",
        /*80*/ "You can now endorse up to 5 other users.  Reviews and Notes you submit are now automatically approved.",
        /*160*/ "Mods you submit are now automatically approved.  You can now upload images for mods that have none.",
        /*320*/ "You can now endorse up to 10 other users.  You can now update notes made by inactive users.",
        /*640*/ "You can now endorse up to 15 other users.",
        /*1280*/ "You can now use a custom user title."
    ];

    var noteContentLink =
        '<a href="mods/{{content.first_mod.id}}">{{content.first_mod.name}}</a> and ' +
        '<a href="mods/{{content.second_mod.id}}">{{content.second_mod.name}}</a>';
    var associatedModLink =
        '<a href="mods/{{content.mod.id}}">{{content.mod.name}}</a>';
    var associatedModListLink =
        '<a href="mod-lists/{{content.mod_list.id}}">{{content.mod_list.name}}</a>';
    var noteCorrectionCommentLink = function(noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="mods/{{content.commentable.correctable.first_mod.id}}/' + noteTypeDashed + '/{{content.commentable.correctable_id}}">((commentableOwnerClause)) ' + noteType + ' note correction</a>';
    };
    var noteCorrectionLink = function(noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="mods/{{content.correctable.first_mod.id}}/' + noteTypeDashed + '/{{content.correctable_id}}">your ' + noteType + ' note</a>';
    };
    this.contentLinks = {
        Review: associatedModLink,
        CompatibilityNote: noteContentLink,
        InstallOrderNote: noteContentLink,
        LoadOrderNote: '<a href="plugins?q=filename:&quot;{{content.first_plugin_filename}}&quot;">{{content.first_plugin_filename}}</a> and <a href="plugins?q=filename:&quot;{{content.second_plugin_filename}}&quot;">{{content.second_plugin_filename}}</a>',
        ModTag: associatedModLink,
        ModListTag: associatedModListLink,
        ModAuthor: associatedModLink,
        Mod: '<a href="mods/{{event.content_id}}">{{content.name}}</a>',
        ModList: '<a href="mod-lists/{{event.content_id}}">{{content.name}}</a>',
        UserReputation: '<a href="user/{{event.content.user.id}}">{{content.user.username}}</a> has',
        Comment: {
            key: "commentable",
            Article: '<a href="articles/{{content.commentable_id}}">{{content.commentable.title}}</a>',
            User: '<a href="user/{{content.commentable_id}}">((commentableOwnerClause)) profile</a>',
            Correction: {
                key: "correctable",
                Mod: '<a href="mods/{{content.commentable.correctable_id}}">((commentableOwnerClause)) appeal</a>',
                CompatibilityNote: noteCorrectionCommentLink("compatibility"),
                InstallOrderNote: noteCorrectionCommentLink("install order"),
                LoadOrderNote: noteCorrectionCommentLink("load order")
            },
            ModList: '<a href="mod-lists/{{content.commentable_id}}/comments">((commentableOwnerClause)) mod list</a>',
            HelpPage: '<a href="/help/{{content.commentable.title}}">{{content.commentable.title}}</a>'
        },
        Correction: {
            key: "correctable",
            Mod: '<a href="mods/{{content.correctable.id}}">{{content.correctable.name}}</a>',
            CompatibilityNote: noteCorrectionLink("compatibility"),
            InstallOrderNote: noteCorrectionLink("install order"),
            LoadOrderNote: noteCorrectionLink("load order")
        }
    };

    var noteCorrectionDescription = function(noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '((ownershipClause)) correction on <a href="user/{{content.correctable.submitter.id}}">{{content.correctable.submitter.username}}\'s</a> <a href="mods/{{content.correctable.first_mod.id}}/'+noteTypeDashed+'/{{content.correctable_id}}">'+noteType+' note</a>';
    };
    this.correctionDescriptions = {
        Mod: '((ownershipClause)) appeal to mark <a href="mods/{{content.correctable.id}}">{{content.correctable.name}}</a> as {{content.mod_status}}',
        CompatibilityNote: noteCorrectionDescription('compatibility'),
        InstallOrderNote: noteCorrectionDescription('install order'),
        LoadOrderNote: noteCorrectionDescription('load order')
    };

    this.statusChanges = {
        Correction: {
            key: "status",
            open: "been re-opened",
            passed: "passed",
            failed: "failed",
            closed: "been closed"
        },
        User: {
            key: "role",
            banned: "You have been banned.",
            restricted: "Your account has been restricted.  You can no longer make public contributions.",
            user: "Your account has been returned to normal status.",
            helper: "You are now a helper on Mod Picker.",
            moderator: "You are now a moderator on Mod Picker!",
            admin: "You are now a site admin.  Remember, with great power comes great responsibility."
        },
        ModList: {
            key: "status",
            under_construction: "under construction",
            testing: "testing",
            complete: "complete"
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

    this.compile = function(template, event, depth) {
        var result = template.replace(/\(\(([\w]+)\)\)/g, function(match) {
            return factory[match.slice(2, -2)](event);
        });
        if (depth > 1) return factory.compile(result, event, depth - 1);
        return result;
    };

    this.getNotification = function(event) {
        var template = factory.getNotificationTemplate(event);
        return factory.compile(template, event, 2);
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
            return '<a href="user/{{content.user.id}}">{{content.user.username}}</a> has';
        } else {
            return 'You have';
        }
    };

    this.getCommentableOwnerId = function(event) {
        return event.content.commentable.submitted_by || event.content.commentable_id;
    };

    this.getCommentableOwnerUsername = function(event) {
        var commentable = event.content.commentable;
        return commentable.username || commentable.submitter && commentable.submitter.username;
    };

    this.commentableOwnerClause = function(event) {
        var ownerId = factory.getCommentableOwnerId(event);
        if (ownerId != factory.currentUserID) {
            return factory.getCommentableOwnerUsername(event) + "'s";
        } else {
            return "your";
        }
    };

    this.authorRole = function(event) {
        if (event.content.role === "author") {
            return "an " + event.content.role;
        } else {
            return "a " + event.content.role;
        }
    };

    this.commentContext = function(event) {
        var ownerId = factory.getCommentableOwnerId(event);
        if (ownerId != factory.currentUserID) {
            return "reply to your";
        } else {
            return "new";
        }
    };

    this.endorser = function(event) {
        return '<a href="user/{{content.source_user.id}}">{{content.source_user.username}}</a>';
    };

    this.endorsee = function(event) {
        if (event.content.target_user.id == factory.currentUserID) {
            return 'you';
        } else {
            return '<a href="user/{{content.target_user.id}}">{{content.target_user.username}}</a>'
        }
    };

    this.changeVerb = function(event) {
        return event.event_type;
    };

    this.correctionDescription = function(event) {
        var description = factory.correctionDescriptions[event.content.correctable_type];
        var bIsOwner = event.content.submitted_by == factory.currentUserID;
        var ownershipClause = bIsOwner ? 'Your' : 'The';
        return description.replace('((ownershipClause))', ownershipClause);
    };

    this.statusChange = function(event) {
        return factory.getTemplateObject(factory.statusChanges, event.content, event.content_type, "");
    };

    this.messageText = function(event) {
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

    this.userClause = function(event) {
        if (factory.currentUserID == event.content.user.id) {
            return 'You have';
        } else {
            return factory.contentLink(event);
        }
    };

    return this;
});