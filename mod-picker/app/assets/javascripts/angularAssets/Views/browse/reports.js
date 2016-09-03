app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.reportFilters();
    var state = indexFactory.buildState('submitted', 'desc', 'reports', filterPrototypes);
    state.controller = 'reportsIndexController';
    $futureState.futureState(state);
});

app.controller('reportsIndexController', function ($scope, $rootScope, $stateParams, $state, reportService, columnsFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.globalPermissions = angular.copy($rootScope.permissions);

    // sort options for view
    $scope.sortOptions = sortFactory.reportSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.reportFilters();
    $scope.dateFilters = filtersFactory.reportDateFilters();

    // build generic controller stuff
    $scope.route = 'reports';
    $scope.retrieve = articleService.retrieveReports;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});
