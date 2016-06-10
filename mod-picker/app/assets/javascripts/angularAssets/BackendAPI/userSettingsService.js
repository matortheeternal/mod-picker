app.service('userSettingsService', function (backend, $q) {

    this.retrieveUserSettings = function () {
        var userSettings = $q.defer();
        try {
        	backend.retrieve('/user_settings').then(function (data) {
                userSettings.resolve(data);
        	});
        } catch (errors) {
        	throw errors;
        }
        return userSettings.promise;
    };

    this.submitAvatar = function (avatar) {
        var post = $q.defer();
        backend.postFile('/avatar', 'avatar', avatar).then(function (data) {
            post.resolve(data);
        });
        return post.promise;
    };

    this.verifyAccount = function (site, user_path) {
        var verified = $q.defer();
        try {
        	backend.retrieve('/link_account', { site: site, user_path: user_path }).then(function (data) {
                verified.resolve(data);
        	});
        } catch (errors) {
        	throw errors;
        }
        return verified.promise;
    };

    //TODO: move this to userservice
    this.submitUser = function (user) {
        //TODO: reformat this into the function directly, as the var gets used only once
        var user_object = {
            user: user
        };
        var update = $q.defer();
    	backend.update('/users/' + user.id, user_object).then(function (data) {
            update.resolve(data);
    	});
        return update.promise;
    };

    this.submitUserSettings = function (user_settings) {
        //TODO: reformat this into the function directly, as the var gets used only once
        var user_settings_object = {
            user_setting: user_settings
        };
        var update = $q.defer();
        backend.update('/user_settings/' + user_settings.id, user_settings_object).then(function (data) {
            update.resolve(data);
        });
        return update.promise;
    };

    this.cloneModList = function (modlist) {
        var clone = $q.defer();
        backend.post('/mod_lists/clone/' + modlist.id, {}).then(function (data) {
            clone.resolve(data);
        });
        return clone.promise;
    };

    this.deleteModList = function (modlist) {
        var remove = $q.defer();
        backend.delete('/mod_lists/' + modlist.id).then(function (data) {
            remove.resolve(data);
        });
        return remove.promise;
    };
});
