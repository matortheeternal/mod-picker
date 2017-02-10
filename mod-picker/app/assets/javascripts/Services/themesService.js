app.service('themesService', function($rootScope) {
    var service = this;

    var currentTheme;
    var defaultThemes = {
        skyrim: "High Hrothgar",
        skyrimse: "Falkreath"
    };

    this.resolveGameTheme = function(settings) {
        var gameKey = $rootScope.currentGame.url;
        var defaultTheme = defaultThemes[gameKey];
        if (!settings) return defaultTheme;
        return settings[gameKey + "_theme"] || defaultTheme;
    };

    this.changeTheme = function(settings) {
        currentTheme = service.resolveGameTheme(settings);
        $rootScope.$broadcast('themeChanged', _stylesheets[currentTheme]);
    };
});