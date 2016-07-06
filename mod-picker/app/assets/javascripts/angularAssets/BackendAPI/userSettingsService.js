app.service('userSettingsService', function (backend, $q) {
    this.retrieveUserSettings = function () {
        return backend.retrieve('/user_settings');
    };

    this.submitAvatar = function (avatar) {
        return backend.postFile('/avatar', 'avatar', avatar);
    };

    this.verifyAccount = function (site, user_path) {
         return backend.retrieve('/link_account', { site: site, user_path: user_path });
    };

    //TODO: move this to userservice
    this.submitUser = function (user) {
        return backend.update('/users/' + user.id, { user: user });
    };

    this.submitUserSettings = function (user_settings) {
        return backend.update('/user_settings/' + user_settings.id, { user_setting: user_settings });
    };

    this.cloneModList = function (modlist) {
        return backend.post('/mod_lists/clone/' + modlist.id, {});
    };

    this.deleteModList = function (modlist) {
        return backend.delete('/mod_lists/' + modlist.id);
    };
});
