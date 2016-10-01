app.service('userSettingsService', function (backend, $q, objectUtils, userTitleService) {
    this.retrieveSettings = function (userId) {
        var action = $q.defer();
        backend.retrieve('/settings/' + userId).then(function(data) {
            var user = data.user;
            //get user title if it's not custom
            if (!user.title) {
                userTitleService.getUserTitle(user.reputation.overall).then(function(title) {
                    user.title = title;
                });
            }
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.updateUserSettings = function (user) {
        var userData = {
            user: {
                title: user.title,
                about_me: user.about_me,
                settings_attributes: user.settings
            }
        };
        objectUtils.deleteEmptyProperties(userData, 1);

        return backend.update('/settings/' + user.id, userData);
    };

    this.updateUserRegistration = function(user) {
        var userData = {
            user: {
                email: user.email,
                password: user.password,
                password_confirmation: user.password_confirmation,
                current_password: user.current_password
            }
        };
        objectUtils.deleteEmptyProperties(userData, 1);

        return backend.update('/users', userData);
    };

    this.submitAvatar = function (avatar) {
        return backend.postFile('/settings/avatar', 'avatar', avatar);
    };

    this.verifyAccount = function (site, user_path) {
        var params = { site: site, user_path: user_path };
        return backend.post('/settings/link_account', params);
    };
});
