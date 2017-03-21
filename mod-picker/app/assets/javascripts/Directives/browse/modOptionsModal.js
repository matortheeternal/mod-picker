app.directive('modOptionsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/modOptionsModal.html',
        scope: false,
        controller: 'modOptionsModalController'
    };
});

app.controller('modOptionsModalController', function($scope, columnsFactory, formUtils, tableUtils, sortUtils) {
    $scope.unfocusDetailsModal = formUtils.unfocusModal($scope.toggleModOptionsModal);

    // initialize variables
    $scope.moColumns = columnsFactory.modListModDetailsColumns();

    $scope.moSort = {
        column: '',
        direction: 'ASC'
    };

    // expose service function to be usable in html
    $scope.sortColumn = tableUtils.sortColumn;

    // load sort into view
    if ($scope.columns && $scope.moSort && $scope.moSort.column) {
        sortUtils.loadSort($scope.moColumns, $scope.sortedColumn, $scope.moSort);
    }
});
