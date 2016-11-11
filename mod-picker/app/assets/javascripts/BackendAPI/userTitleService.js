app.service('userTitleService', function(backend, $q) {
    var service = this;
    var allTitles, gameTitles;

    this.retrieveUserTitles = function() {
        var userTitles = $q.defer();
        backend.retrieve('/user_titles').then(function(titles) {
            userTitles.resolve(titles);
            allTitles = titles;
            gameTitles = service.getSortedGameTitles(titles);
        });
        return userTitles.promise;
    };

    this.getSortedGameTitles = function(titles) {
        var gameTitles = titles.filter(function(title) {
            return (title.game_id === window._current_game_id);
        });
        gameTitles.sort(function(a, b) {
            return a.rep_required - b.rep_required;
        });
        return gameTitles;
    };


    this.getUserTitle = function(reputation) {
        var prevTitle = gameTitles[0];
        for (var i = 0; i < gameTitles.length; i++) {
            var title = gameTitles[i];
            if (reputation < title.rep_required) {
                return prevTitle.title;
            }
            prevTitle = title;
        }
        return prevTitle.title;
    };

    this.associateUserAvatar = function(user, title) {
        var avatarBase = user.image_type ? user.id : title || 'Default';
        var avatarExt = user.image_type || 'png';
        user.avatars = {
            big: '/users/' + avatarBase + '-big.' + avatarExt,
            medium: '/users/' + avatarBase + '-medium.' + avatarExt,
            small: '/users/' + avatarBase + '-small.' + avatarExt
        };
    };

    this.associateUserTitle = function(user) {
        if (!user) return;
        if (!user.title && user.reputation) {
            // get their default title
            var title = service.getUserTitle(user.reputation.overall);
            user.title = title;
            service.associateUserAvatar(user, title);
        } else {
            service.associateUserAvatar(user);
        }
    };

    this.associateTitles = function(data) {
        data.forEach(function(item) {
            service.associateUserTitle(item.submitter);
        });
    };

    this.associateCommentTitles = function(comments) {
        comments.forEach(function(comment) {
            service.associateUserTitle(comment.submitter);
            if (comment.children && comment.children.length) {
                comment.children.forEach(function(child) {
                    service.associateUserTitle(child.submitter);
                });
            }
        });
    };

    this.associateReportableTitles = function(data) {
        data.forEach(function(report) {
            if(report.reportable_type === 'User') {
                service.associateUserTitle(report.reportable);
            } else {
                service.associateUserTitle(report.reportable.submitter);
            }
        });
    }
});
