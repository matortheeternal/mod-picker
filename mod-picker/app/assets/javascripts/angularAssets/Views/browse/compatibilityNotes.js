app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.compatibilityNoteFilters();
    var state = indexFactory.buildState('reputation', 'desc', 'compatibilityNotes', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('compatibilityNotesController', function ($scope, $stateParams, $state, currentUser, contributionService, indexService, filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // sort options for view
    $scope.sortOptions = sortFactory.compatibilityNoteSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.compatibilityNoteFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.noteStatisticFilters();

    // build generic controller stuff
    $scope.route = 'compatibility_notes';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});