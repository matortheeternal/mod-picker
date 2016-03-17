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

    this.submit = function (user, user_settings) {
        var user_object = {
            user: user
        };
        var user_setting_object = {
            user_setting: user_settings
        };

        var _user = $q.defer();
        var _user_settings = $q.defer();
        backend.update('/user_settings/' + user_settings.id, user_setting_object).then(function (data2) {
            setTimeout(function () {
                _user_settings.resolve(data2);
            }, 1000);
        });
    	backend.update('/users/' + user.id, user_object).then(function (data) {
            setTimeout(function () {
                _user.resolve(data);
            }, 1000);
    	});
        return [_user.promise, _user_settings.promise];
    };

});
