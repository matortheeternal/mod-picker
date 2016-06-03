app.controller('globalController', function($scope, $rootScope, themesService) {
    $rootScope.$on('themeChanged', function (event, newTheme) {
        $scope.currentTheme = newTheme;
    });

    $scope.$on('reloadCurrentUser', function() {
        userService.retrieveCurrentUser().then(function (user) {
            $scope.currentUser = user;
        });
    });
});
