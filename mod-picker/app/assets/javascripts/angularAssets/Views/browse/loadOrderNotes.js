app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.loadOrderNoteFilters();
    var state = indexFactory.buildState('reputation', 'desc', 'loadOrderNotes', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('loadOrderNotesController', function ($scope, $stateParams, $state, currentUser, contributionService, indexService,  filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // sort options for view
    $scope.sortOptions = sortFactory.loadOrderNoteSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.loadOrderNoteFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.noteStatisticFilters();

    // build generic controller stuff
    $scope.route = 'load_order_notes';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});