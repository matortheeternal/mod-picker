app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.curatorRequestFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'curatorRequests', filterPrototypes);
    state.controller = 'curatorRequestsIndexController';
    $futureState.futureState(state);
});

app.controller('curatorRequestsIndexController', function($scope, $rootScope, $stateParams, $state, curatorRequestService, helpFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = $rootScope.permissions;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Curator Requests');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // sort options for view
    $scope.sortOptions = sortFactory.curatorRequestSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.curatorRequestFilters();
    $scope.dateFilters = filtersFactory.curatorRequestDateFilters();
    $scope.filters = { game: $scope.currentGame.id };

    // build generic controller stuff
    $scope.route = 'curator_requests';
    $scope.retrieve = curatorRequestService.retrieveCuratorRequests;
    indexFactory.buildIndex($scope, $stateParams, $state);
});
