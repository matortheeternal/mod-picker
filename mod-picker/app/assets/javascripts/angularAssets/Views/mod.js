app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/mod.html',
            controller: 'modController'
        }
    );
}]);

app.controller('modController', function ($rootscope, $scope, $q, $routeParams, modService) {
    $rootScope.twoColumns = true;;

    $scope.tabs = [
        { name: 'Compatibility', url: '/resources/partials/modPage/compatibilityTab.html'},
        { name: 'Installation', url: '/resources/partials/modPage/installationTab.html'},
        { name: 'Reviews', url: '/resources/partials/modPage/reviewsTab.html'},
        { name: 'Analysis', url: '/resources/partials/modPage/analysisTab.html'}
    ];

    $scope.currentTab = $scope.tabs[0];

    $scope.expandedState = {
        compabilityNotes: true,
        reviews: false
    };

    modService.retrieveMod($routeParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.changeVersion(mod.mod_versions[0].id);
        $scope.version = mod.mod_versions[0].id;
    });

    $scope.showReviews = function () {
        $scope.expandedState = {
            reviews: true
        }
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