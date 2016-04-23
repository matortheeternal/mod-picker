app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mod', {
            templateUrl: '/resources/partials/mod.html',
            controller: 'modController',
            url: '/mod/:modId'
        }
    );
}]);

app.controller('modController', function ($scope, $q, $stateParams, modService) {
    $scope.expandedState = {
        compabilityNotes: true,
        reviews: false
    };

    modService.retrieveMod($stateParams.modId).then(function (mod) {
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
            modService.retrieveCompatibilityNotes($scope.mod.id, version).then(function (compatibilityNotes) {
                $scope.compatibilityNotes = compatibilityNotes;
            });
        }
    };

});
