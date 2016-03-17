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
        user.settings = user_settings;
        var user_object = {
            user: user
        };

        var _user = $q.defer();
    	backend.update('/users/' + user.id, user_object).then(function (data) {
            setTimeout(function () {
                _user.resolve(data);
            }, 1000);
    	});

        // doesn't work yet
        return _user.promise
    };

});
