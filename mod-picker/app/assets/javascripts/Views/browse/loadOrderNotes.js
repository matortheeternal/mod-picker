app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.loadOrderNoteFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'loadOrderNotes', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('loadOrderNotesController', function($scope, $rootScope, $stateParams, $state, contributionService, indexService, helpFactory, filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Load Order Notes');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // sort options for view
    $scope.sortOptions = sortFactory.loadOrderNoteSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.loadOrderNoteFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.noteStatisticFilters();
    $scope.filters = { game: $scope.currentGame.id };

    // build generic controller stuff
    $scope.route = 'load_order_notes';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state, true);
});