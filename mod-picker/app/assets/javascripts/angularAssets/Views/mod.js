app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController'
        }
    );
}]);

app.controller('modController', function ($scope, $q, $routeParams, modService) {
    useTwoColumns(true);
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
        $scope.expandedState = {
            reviews: true
        };
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
