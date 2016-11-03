app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.reportFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'reports', filterPrototypes);
    state.controller = 'reportsIndexController';
    $futureState.futureState(state);
});

app.controller('reportsIndexController', function($scope, $rootScope, $stateParams, $state, reportService, helpFactory, columnsFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // set page title
    $scope.$emit('setPageTitle', 'Reports');
    // set help context
    helpFactory.setHelpContexts($scope, []);

    // sort options for view
    $scope.sortOptions = sortFactory.reportSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.reportFilters();
    $scope.dateFilters = filtersFactory.reportDateFilters();
    $scope.statFilters = filtersFactory.reportStatisticFilters();

    // build generic controller stuff
    $scope.route = 'reports';
    $scope.retrieve = reportService.retrieveReports;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});
