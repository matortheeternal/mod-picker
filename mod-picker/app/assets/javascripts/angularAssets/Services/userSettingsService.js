app.service('userSettingsService', function (backend, $q) {

    this.retrieveUserSettings = function () {
        var userSettings = $q.defer();
        backend.retrieve('/user_settings').then(function (data) {
            //TODO: remove mocked delay
            setTimeout(function () {
                userSettings.resolve(data);
            }, 1000);
        });
        return userSettings.promise
    };

    this.submitAvatar = function (avatar) {
        var post = $q.defer();
        backend.postFile('/avatar', 'avatar', avatar).then (function (data) {
            setTimeout(function () {
                post.resolve(data);
            }, 1000);
        });
        return post.promise;
    };

    this.submitUser = function (user) {
        //TODO: reformat this into the function directly, as the var gets used only once
        var user_object = {
            user: user
        };
        var update = $q.defer();
    	backend.update('/users/' + user.id, user_object).then(function (data) {
            //TODO: remove mocked delay
            setTimeout(function () {
                update.resolve(data);
            }, 1000);
    	});
        return update.promise
    };

    this.submitUserSettings = function (user_settings) {
        //TODO: reformat this into the function directly, as the var gets used only once
        var user_settings_object = {
            user_setting: user_settings
        };
        var update = $q.defer();
        backend.update('/user_settings/' + user_settings.id, user_settings_object).then(function (data) {
            //TODO: remove mocked delay
            setTimeout(function () {
                update.resolve(data);
            }, 1000);
        });
        return update.promise
    };

    this.cloneModList = function (modlist) {
        var clone = $q.defer();
        backend.post('/mod_lists/clone/' + modlist.id, {}).then(function (data) {
            setTimeout(function () {
                clone.resolve(data);
            }, 1000);
        });
        return clone.promise
    };

    this.deleteModList = function (modlist) {
        var remove = $q.defer();
        backend.delete('/mod_lists/' + modlist.id).then(function (data) {
            setTimeout(function () {
                remove.resolve(data);
            }, 1000);
        });
        return remove.promise
    };
});