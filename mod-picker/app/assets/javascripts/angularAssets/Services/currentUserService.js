app.service('currentUserService', function($q, userService, userSettingsService, themesService) {
    var thisService = this;
    this.settings = userSettingsService.retrieveUserSettings();
    this.user = $q.defer();

    this.settings.then(function(settings) {
        thisService.settings.theme = themesService.getTheme();
        thisService.user.resolve(userService.retrieveUser(settings.user_id));
    });
});
