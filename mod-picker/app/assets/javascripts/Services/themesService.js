app.service('themesService', function($rootScope) {
    var currentTheme;

    this.changeTheme = function(newTheme) {
        currentTheme = newTheme;
        $rootScope.$broadcast('themeChanged', _stylesheets[currentTheme]);
    };

    this.getTheme = function() {
        return currentTheme;
    };
});