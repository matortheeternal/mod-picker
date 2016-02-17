app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/mod.html',
            controller: 'modController'
        }
    );
}]);

app.controller('modController', function ($scope, $q, $routeParams, modService) {
    $scope.loading = true;

    $scope.expandedState = {
        compabilityNotes: true,
        reviews: false
    };

    modService.retrieveMod($routeParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.version = mod.mod_versions[0].id;
    });

    $scope.showReviews = function () {
        $scope.expandedState = {
            compabilityNotes: false,
            reviews: true
        }
    };

    $scope.$watch('version', function (newVal, oldVal) {
        if(newVal && newVal !== oldVal && $scope.mod.id) {
            $scope.loading = true;
            modService.retrieveCompabilityNotes($scope.mod.id, newVal).then(function (compatibilityNotes) {
                $scope.compatibilityNotes = compatibilityNotes;
                $scope.loading = false;
            });
        }
    });
});