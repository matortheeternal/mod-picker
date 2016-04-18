app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController'
        }
    );
}]);

app.filter('percentage', function() {
  return function(input) {
    if (isNaN(input)) {
      return input;
    }
    return Math.floor(input * 100) + '%';
  };
});

app.controller('modController', function ($rootScope, $scope, $q, $routeParams, modService, categoryService) {
    $rootScope.twoColumns = true;

    //initialization
    //of the mod object
    modService.retrieveMod($routeParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.currentVersion = mod.mod_versions[0];

        categoryService.getCategoryById(mod.primary_category_id).then(function (data) {
            $scope.firstCategory = data.name;
        });
        categoryService.getCategoryById(mod.secondary_category_id).then(function (data) {
            $scope.secondCategory = data.name;
        });
    });

    //of the tab data
    $scope.tabs = [
        { name: 'Compatibility notes', url: '/resources/partials/showMod/compatibility.html' },
        { name: 'Installation', url: '/resources/partials/showMod/installation.html' },
        { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
        { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

    //this prevents the sort by dropdowns from displaying an undefined option
    $scope.filter = 'compatibility_type';

    //variables for the stat block expandables
    $scope.nexusExpanded = false;
    $scope.steamExpanded = false;
    $scope.loversExpanded = false;

});
