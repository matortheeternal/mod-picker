app.service('userService', function (backend, $q, userSettingsService, userTitleService, pageUtils) {
    var service = this;

    this.retrieveUsers = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/users/index', options).then(function (data) {
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
        var output = $q.defer();
        backend.retrieve('/users/' + userId).then(function(userData) {
            //moving collections into a separate array
            userData.collections = [];
            for (var i = userData.mod_lists.length - 1; i >= 0; i--) {
                if (userData.mod_lists[i].is_collection) {
                    userData.collections.push(userData.mod_lists.splice(i, 1)[0]);
                }
            }

            //get user title if it's not custom
            if (!userData.title) {
                userTitleService.getUserTitle(userData.reputation.overall).then(function(title) {
                    userData.title = title;
                });
            }
            output.resolve(userData);
        });
        return output.promise;
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
        backend.retrieve('/current_user').then(function (userData) {
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
        // TODO: Remove this when beta is over
        permissions.canSubmitMod = true;
        //permissions.canSubmitMod = permissions.isAdmin || permissions.isModerator || user.reputation.overall > 160;
        permissions.canUseCustomSources = permissions.isAdmin || permissions.isModerator;
        permissions.canSetGeneralModInfo = permissions.isAdmin || permissions.isModerator;
        permissions.canChangeAvatar = (rep >= 10) || permissions.isAdmin || permissions.isModerator;
        permissions.canChangeTitle = (rep >= 1280) || permissions.isAdmin || permissions.isModerator;
        permissions.canCreateTags = (rep >= 20) || permissions.isAdmin || permissions.isModerator;
        permissions.canAppeal = (rep >= 40) || permissions.isModerator || permissions.isAdmin;
        permissions.canModerate = permissions.isModerator || permissions.isAdmin;

        var numEndorsed = user.reputation.rep_to_count;
        permissions.canEndorse = (rep >= 40 && numEndorsed <= 5) || (rep >= 160 && numEndorsed <= 10) || (rep >= 640 && numEndorsed <= 15);

        return permissions;
    };
});
