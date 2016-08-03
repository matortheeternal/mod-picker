app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modQueueFilters();
    var state = indexFactory.buildState('submitted', 'desc', 'modQueue', filterPrototypes);
    state.controller = 'modQueueController';
    $futureState.futureState(state);
});

app.controller('modQueueController', function ($scope, $stateParams, $state, currentUser, reportService, columnsFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // sort options for view
    $scope.sortOptions = sortFactory.modQueueSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.modQueueFilters();
    $scope.dateFilters = filtersFactory.modQueueDateFilters();

    // build generic controller stuff
    $scope.route = 'reports';
    $scope.retrieve = reportService.retrieveReports;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});
