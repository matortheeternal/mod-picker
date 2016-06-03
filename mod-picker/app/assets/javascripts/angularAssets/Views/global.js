app.controller('globalController', function($scope, $rootScope, themesService) {
    $rootScope.$on('themeChanged', function (event, newTheme) {
        $scope.currentTheme = newTheme;
    });
});
