app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.compatibilityNoteFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'compatibilityNotes', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('compatibilityNotesController', function($scope, $rootScope, $stateParams, $state,  contributionService, indexService, helpFactory, filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Compatibility Notes');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // sort options for view
    $scope.sortOptions = sortFactory.compatibilityNoteSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.compatibilityNoteFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.noteStatisticFilters();
    $scope.filters = { game: $scope.currentGame.id };

    // build generic controller stuff
    $scope.route = 'compatibility_notes';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state);
});