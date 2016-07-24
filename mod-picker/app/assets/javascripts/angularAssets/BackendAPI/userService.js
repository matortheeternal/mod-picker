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
            var userObject = userData.user;
            //moving collections into a separate array
            userObject.collections = [];
            for (var i = userObject.mod_lists.length - 1; i >= 0; i--) {
                if (userObject.mod_lists[i].is_collection) {
                    userObject.collections.push(userObject.mod_lists.splice(i, 1)[0]);
                }
            }

            //get user title if it's not custom
            if (!userObject.title) {
                userTitleService.getUserTitle(userObject.reputation.overall).then(function(title) {
                    userObject.title = title;
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

    this.retrieveProfileComments = function(userId, options, pageInformation) {
        var output = $q.defer();
        backend.post('/users/' + userId + '/comments', options).then(function(response) {
            userTitleService.associateTitles(response.comments);
            pageUtils.getPageInformation(response, pageInformation, options.page);
            output.resolve(response.comments);
        }, function(response) {
            output.reject(response);
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
        permissions.canEndorse = (rep >= 40 && numEndorsed < 5) || (rep >= 160 && numEndorsed < 10) || (rep >= 640 && numEndorsed < 15);

        return permissions;
    };

    this.giveRep = function(userId, repped) {
        if (repped) {
            return backend.delete('/users/' + userId + '/rep');
        } else {
            return backend.post('/users/' + userId + '/rep', {});
        }
    };
});
