app.directive('correction', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/correction.html',
        controller: 'correctionController',
        scope: {
            correction: '=',
            index: '=',
            edit: '=?',
            showUserColumn: '=',
            eventPrefix: '=?',
            showCorrectable: '=?'
        }
    }
});

app.controller('correctionController', function($scope, $rootScope) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

    // initialize local variables
    switch($scope.correction.correctable_type) {
        case "CompatibilityNote":
            $scope.label = "Compatibility Note";
            $scope.tabState = "compatibility";
            break;
        case "InstallOrderNote":
            $scope.label = "Install Order Note";
            $scope.tabState = "install-order";
            break;
        case "LoadOrderNote":
            $scope.label = "Load Order Note";
            $scope.tabState = "load-order";
            break;
        case "Mod":
            $scope.isAppeal = true;
            break;
    }
});