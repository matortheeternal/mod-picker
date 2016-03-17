app.service('userSettingsService', function (backend, $q) {
    this.retrieveUserSettings = function (userSettingsId) {
        var userSettings = $q.defer();
        backend.retrieve('/user_settings/' + userSettingsId).then(function (data) {
            setTimeout(function () {
                userSettings.resolve(data);
            }, 1000);
        });
        return userSettings.promise;
    };

    this.submitUser = function (user) {
        var user_object = {
            user: user
        };
        var update = $q.defer();
    	backend.update('/users/' + user.id, user_object).then(function (data) {
            setTimeout(function () {
                update.resolve(data);
            }, 1000);
    	});
        return update.promise
    };

    this.submitUserSettings = function (user_settings) {
        var user_settings_object = {
            user_setting: user_settings
        };
        var update = $q.defer();
        backend.update('/user_settings/' + user_settings.id, user_settings_object).then(function (data) {
            setTimeout(function () {
                update.resolve(data);
            }, 1000);
        });
        return update.promise
    };

});
