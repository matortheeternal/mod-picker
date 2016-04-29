app.service('userService', function (backend, $q, userSettingsService) {
    this.retrieveUser = function (userId) {
        return backend.retrieve('/users/' + userId);
    };

    //TODO: there has to be a better way to do this right? -Sirius
    this.retrieveThisUser = function () {
        var user = $q.defer();
    	userSettingsService.retrieveUserSettings().then(function (user_settings) {
	    	backend.retrieve('/users/' + user_settings.user_id).then(function (data) {
	            user.resolve(data);
	        });
        });
        return user.promise;
    };

});
