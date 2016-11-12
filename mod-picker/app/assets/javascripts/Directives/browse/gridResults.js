app.directive('gridResults', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/gridResults.html',
        controller: 'gridResultsController',
        scope: {
            label: '@',
            message: '@',
            data: '=',
            details: '=?',
            detailGroups: '=?',
            availableDetailData: '=?',
            sort: '=?',
            actions: '=?'
        }
    }
});

app.controller('gridResultsController', function($scope, $rootScope, tableUtils) {
    // inherit rootScope variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // inherit scope attributes
    angular.inherit($scope, 'details');
    angular.inherit($scope, 'detailGroups');
    angular.inherit($scope, 'availableDetailData');
    angular.inherit($scope, 'actions');

    // default scope attributes
    var defaultMessage = 'No ' + $scope.label + ' were found matching your search criteria.';
    angular.default($scope, 'message', defaultMessage);

    // inherited functions
    $scope.groupDetails = tableUtils.groupColumns;

    // toggles the visibility of the configure details modal
    $scope.toggleModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showModal = visible;
    };

    // this function resolves a variable as a function if it is one,
    // else returns its value
    $scope.resolve = function(attribute, item, context) {
        if (typeof attribute === 'function') {
            return attribute($scope, item, context);
        } else {
            return attribute;
        }
    };

    $scope.buildItemData = function() {
        $scope.builtItemData = true;
        $scope.data.forEach(function(item) {
            tableUtils.buildItemData(item, $scope.details, $scope.resolve, 'detailData');
        });
    };

    $scope.$watch('data', function() {
        if (!$scope.data) return;
        $scope.buildItemData();
    }, true);

    $scope.$on('configureDetails', function() {
        $scope.toggleModal(true);
    });
});