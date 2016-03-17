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

    	backend.update('/users/' + user.id, user).then(function (data) {
    		done = (data.status === "ok");

    	};
    	backend.update('/user_settings/' + user_settings.id, user_settings).then(function (data) {

	    };

    };

});
