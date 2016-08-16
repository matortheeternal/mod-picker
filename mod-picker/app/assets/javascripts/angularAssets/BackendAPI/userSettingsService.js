app.service('userSettingsService', function (backend, objectUtils) {
    this.retrieveSettings = function (userId) {
        return backend.retrieve('/settings/' + userId);
    };

    this.updateUserSettings = function (user) {
        var userData = {
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
                title: user.title,
                about_me: user.about_me,
                newPassword: user.newPassword,
                newPassword_confirmation: user.newPassword_confirmation,
                password: user.password,
                settings_attributes: user.settings
            }
        };
        objectUtils.deleteEmptyProperties(userData, 1);

        return backend.update('/settings/' + user.id, userData);
    };

    this.submitAvatar = function (avatar) {
        return backend.postFile('/settings/avatar', 'avatar', avatar);
    };

    this.verifyAccount = function (site, user_path) {
        var params = { site: site, user_path: user_path };
        return backend.retrieve('/settings/link_account', params);
    };
});
