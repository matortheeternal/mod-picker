app.service('userService', function(backend, $q, userSettingsService, userTitleService, pageUtils) {
    var service = this;

    this.retrieveUsers = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/users/index', options).then(function(data) {
            data.users.forEach(userTitleService.associateUserTitle);
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
            userTitleService.associateUserTitle(user);
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
            if (userData) {
                userData.signed_in = true;
                userData.permissions = service.getPermissions(userData);
            } else {
                userData = { permissions: {} };
            }
            output.resolve(userData);
        });
        return output.promise;
    };

    this.getPermissions = function(user) {
        var permissions = {};
        var rep = user.reputation.overall;
        permissions.isAdmin = user.role === 'admin';
        permissions.isModerator = user.role === 'moderator';
        permissions.isNewsWriter = user.role === 'writer';
        permissions.isHelper = user.role === 'helper';
        permissions.isRestricted = user.role === 'restricted';
        permissions.isBanned = user.role === 'banned';
        permissions.canModerate = permissions.isAdmin || permissions.isModerator;
        permissions.canManageArticles = permissions.isAdmin || permissions.isNewsWriter;
        permissions.canSubmitMods = !permissions.isRestricted;
        permissions.canContribute = !permissions.isRestricted;
        permissions.canManageMods = permissions.canModerate || permissions.isHelper;
        permissions.canUseCustomSources = permissions.canModerate;
        permissions.canSetGeneralModInfo = permissions.canModerate;
        permissions.canChangeAvatar = (rep >= 10) || permissions.canModerate;
        permissions.canChangeTitle = (rep >= 1280) || permissions.canModerate;

        // permissions block for actions users who are NOT restricted can do
        if(!permissions.isRestricted) {
            permissions.canCreateTags = (rep >= 20) || permissions.canModerate;
            permissions.canAppeal = (rep >= 40) || permissions.canModerate;
            permissions.canCorrect = (rep >= 40) || permissions.canModerate;
            permissions.canAgree = (rep >= 40) || permissions.canModerate;
            permissions.canReport = true;

            var numEndorsed = user.reputation.rep_to_count;
            permissions.canEndorse = (rep >= 80 && numEndorsed < 5) || (rep >= 160 && numEndorsed < 10) || (rep >= 640 && numEndorsed < 15);
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
