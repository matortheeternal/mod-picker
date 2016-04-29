app.controller('themesController', function($scope, $rootScope, themesService) {
    $rootScope.$on('themeChanged', function (event, newTheme) {
        $scope.currentTheme = newTheme;
    });

    themesService.changeTheme(_current_theme);
});