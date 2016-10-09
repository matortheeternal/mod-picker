app.directive('historyModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/historyModal.html',
        controller: 'historyModalController',
        scope: false
    };
});

app.controller('historyModalController', function($scope, contributionFactory) {
    $scope.showHistory = function(entry) {
        $scope.activeHistoryEntry = angular.copy($scope.target);
        if (entry) {
            for (var property in entry) {
                if (entry.hasOwnProperty(property)) {
                    $scope.activeHistoryEntry[property] = entry[property];
                }
            }
            if (entry.edited == $scope.target.submitted) {
                $scope.activeHistoryEntry.edited = null;
            }
        }
    };

    $scope.showHistory();
});