app.controller('themesController', function($scope, $rootScope) {
    $rootScope.$on('themeChanged', function(event, newTheme) {
        $scope.currentTheme = newTheme;
    });
});
