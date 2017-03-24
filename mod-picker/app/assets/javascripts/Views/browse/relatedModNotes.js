app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.relatedModNoteFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'relatedModNotes', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('relatedModNotesController', function($scope, $rootScope, $stateParams, $state,  contributionService, indexService, helpFactory, filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Related Mod Notes');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // sort options for view
    $scope.sortOptions = sortFactory.relatedModNoteSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.relatedModNoteFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.relatedModNoteStatisticFilters();
    $scope.filters = { game: $scope.currentGame.id };

    // build generic controller stuff
    $scope.route = 'related_mod_notes';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state, true);
});