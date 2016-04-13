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

app.controller('modController', function ($rootScope, $scope, $q, $routeParams, modService) {
    $rootScope.twoColumns = true;
    $scope.expandedState = {
        compabilityNotes: true,
        reviews: false
    };

    $scope.tabs = [
    { name: 'Compatibility', url: '/resources/partials/showMod/compatibility.html' },
    { name: 'Installation', url: '/resources/partials/showMod/installation.html' },
    { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
    { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

    modService.retrieveMod($routeParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.changeVersion(mod.mod_versions[0].id);
        $scope.version = mod.mod_versions[0].id;
    });

    $scope.showReviews = function () {
        $scope.currentTab = $scope.tabs[2];
    };

    $scope.changeVersion = function(version) {
        if(version && version !== $scope.version && $scope.mod.id) {
            delete $scope.compabilityNotes;
            //$scope.loading = true;
            modService.retrieveCompabilityNotes($scope.mod.id, version).then(function (compatibilityNotes) {
                $scope.compatibilityNotes = compatibilityNotes;
            });
        }
    };

});
