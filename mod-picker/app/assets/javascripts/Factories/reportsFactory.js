app.service('reportsFactory', function () {
    var factory = this;

    var noteContentLink = function (noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="#/mod/{{report.reportable.first_mod_id}}/' + noteTypeDashed + '/{{report.reportable.id}}">'+noteType.titleCase()+' Note</a>';
    };

    var associatedModReviewLink =
        '<a href="#/mod/{{report.reportable.mod.id}}/reviews/{{report.reportable.id}}">{{report.reportable.mod.name}}</a>';

    var noteCorrectionCommentLink = function (noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="#/mod/{{report.reportable.commentable.correctable.first_mod.id}}/' + noteTypeDashed + '/{{report.reportable.commentable.correctable.id}}">Comment, ' + noteType + ' Note</a>';
    };

    var noteCorrectionLink = function (noteType) {
        var noteTypeDashed = noteType.replace(' ', '-');
        return '<a href="#/mod/{{report.reportable.correctable.first_mod.id}}/' + noteTypeDashed + '/{{report.reportable.correctable.id}}">Correction, ' + noteType + ' Note</a>';
    };

    this.contentLinks = {
        Review: associatedModReviewLink,
        CompatibilityNote: noteContentLink('compatibility'),
        InstallOrderNote: noteContentLink('install order'),
        LoadOrderNote: noteContentLink('load order'),
        Tag: '<a href="#/mods?t={{report.reportable.text}}">Tag</a>',
        Mod: '<a href="#/mod/{{report.reportable.id}}">Mod</a>',
        ModList: '<a href="#/mod-list/{{report.reportable.id}}">Mod List</a>',
        Comment: {
            key: "commentable",
            Article: '<a href="#/article/{{report.reportable_id}}">Comment, Article</a>',
            User: '<a href="#/user/{{report.reportable.commentable_id}}">Comment, User Profile</a>',
            Correction: {
                key: "correctable",
                Mod: '<a href="#/mod/{{report.reportable.commentable.correctable.id}}">Comment, Correction</a>',
                CompatibilityNote: noteCorrectionCommentLink("compatibility"),
                InstallOrderNote: noteCorrectionCommentLink("install order"),
                LoadOrderNote: noteCorrectionCommentLink("load order")
            },
            ModList: '<a href="#/mod-list/{{report.reportable.commentable_id}}/comments">Comment, Mod List</a>'
        },
        Correction: {
            key: "correctable",
            Mod: '<a href="#/mod/{{report.reportable.correctable.id}}">Correction, Mod </a>',
            CompatibilityNote: noteCorrectionLink("compatibility"),
            InstallOrderNote: noteCorrectionLink("install order"),
            LoadOrderNote: noteCorrectionLink("load order")
        },
        User: '<a href="#/user/{{report.reportable.id}}">User</a>'
    };

    this.getTemplateObject = function (object, content, key, keysfx) {
        var result = object[key];
        if (typeof result === "object") {
            var nextContent = content[result.key];
            var nextKey = content[result.key + keysfx];
            return factory.getTemplateObject(result, nextContent, nextKey, keysfx);
        } else {
            return result;
        }
    };

    this.contentLink = function (report) {
        return factory.getTemplateObject(factory.contentLinks, report.reportable, report.reportable_type, "_type");
    };

    return this;
});