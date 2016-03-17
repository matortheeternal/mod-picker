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

});