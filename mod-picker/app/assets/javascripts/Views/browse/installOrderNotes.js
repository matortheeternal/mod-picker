app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.installOrderNoteFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'installOrderNotes', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('installOrderNotesController', function($scope, $rootScope, $stateParams, $state, contributionService, indexService, helpFactory, filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = $rootScope.permissions;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Install Order Notes');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // sort options for view
    $scope.sortOptions = sortFactory.installOrderNoteSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.installOrderNoteFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.noteStatisticFilters();

    // build generic controller stuff
    $scope.route = 'install_order_notes';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state);
});