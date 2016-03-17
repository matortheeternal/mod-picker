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

    this.flash_errors = function(data) {
        $scope.errors = data.errors;
    };

    this.submit = function (user, user_settings) {
        var usersSuccess = false;
        var userSettingsSuccess = false;

    	backend.update('/users/' + user.id, user).then(function (data) {
            usersSuccess = (data.status === "ok");
            if (!usersSuccess) {
                flash_errors(data);
            } else if (userSettingsSuccess) {
                $scope.success = true;
            }
    	});
    	backend.update('/user_settings/' + user_settings.id, user_settings).then(function (data) {
            userSettingsSuccess = (data.status === "ok");
            if (!userSettingsSuccess) {
                flash_errors(data);
            } else if (usersSuccess) {
                $scope.success = true;
            }
	    });
    };

});
