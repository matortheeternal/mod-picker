app.service('userService', function(backend, $q, userSettingsService, userTitleService, pageUtils) {
    var service = this;

    this.retrieveUsers = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/users/index', options).then(function(data) {
            // associate user titles
            data.users.forEach(function(user) {
                if (!user.title) {
                    userTitleService.getUserTitle(user.reputation.overall).then(function(title) {
                        user.title = title;
                    });
                }
            });

            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveUser = function(userId) {
        var action = $q.defer();
        backend.retrieve('/users/' + userId).then(function(userData) {
            var user = userData.user;
            //get user title if it's not custom
            if (!user.title) {
                userTitleService.getUserTitle(user.reputation.overall).then(function(title) {
                    user.title = title;
                });
            }
            action.resolve(userData);
        });
        return action.promise;
    };

    this.searchUsers = function(username) {
        var postData =  {
            filters: {
                search: username
            }
        };
        return backend.post('/users/search', postData);
    };

    this.retrieveCurrentUser = function() {
        var output = $q.defer();
        backend.retrieve('/current_user').then(function(userData) {
            userData.permissions = service.getPermissions(userData);
            output.resolve(userData);
        });
        return output.promise;
    };

    this.getPermissions = function(user) {
        var permissions = {};
        var rep = user.reputation.overall;
        permissions.isAdmin = user.role === 'admin';
        permissions.isModerator = user.role === 'moderator';
        permissions.isRestricted = user.role === 'restricted';
        permissions.isBanned = user.role === 'banned';
        permissions.canModerate = permissions.isAdmin || permissions.isModerator;
        permissions.canSubmitArticles = permissions.canModerate;
        // TODO: Switch this when beta is over
        permissions.canSubmitMods = true;
        //permissions.canSubmitMods = (rep > 160) || permissions.canModerate;
        permissions.canContribute = !permissions.isRestricted;
        permissions.canUseCustomSources = permissions.canModerate;
        permissions.canSetGeneralModInfo = permissions.canModerate;
        permissions.canChangeAvatar = (rep >= 10) || permissions.canModerate;
        permissions.canChangeTitle = (rep >= 1280) || permissions.canModerate;

        // permissions block for actions users who are NOT restricted can do
        if(!permissions.isRestricted) {
            permissions.canCreateTags = (rep >= 5) || permissions.canModerate;
            permissions.canAppeal = (rep >= 40) || permissions.canModerate;
            permissions.canCorrect = (rep >= 40) || permissions.canModerate;
            permissions.canAgree = (rep >= 40) || permissions.canModerate;
            permissions.canReport = true;

            var numEndorsed = user.reputation.rep_to_count;
            permissions.canEndorse = (rep >= 40 && numEndorsed < 5) || (rep >= 160 && numEndorsed < 10) || (rep >= 640 && numEndorsed < 15);
        }

        

        return permissions;
    };

    this.endorse = function(userId, endorsed) {
        if (endorsed) {
        //if the user is currently endorsed delete, otherwise post
            return backend.delete('/users/' + userId + '/rep');
        } else {
            return backend.post('/users/' + userId + '/rep', {});
        }
    };

    this.addRep = function(userId) {
        return backend.post('/users/' + userId + '/add_rep', {});
    };

    this.subtractRep = function(userId) {
        return backend.post('/users/' + userId + '/subtract_rep', {});
    };

    this.changeRole = function(userId, role) {
        return backend.post('/users/' + userId + '/change_role', {role: role});
    };

    this.retrieveUserModLists = function(userId) {
        return backend.retrieve('/users/' + userId + '/mod_lists');
    };

    this.retrieveUserMods = function(userId) {
        return backend.retrieve('/users/' + userId + '/mods');
    };
});
