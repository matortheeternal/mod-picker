app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.commentFilters();
    var state = indexFactory.buildState('submitted', 'desc', 'comments', filterPrototypes);
    state.controller = 'commentsIndexController';
    $futureState.futureState(state);
});

app.controller('commentsIndexController', function ($scope, $stateParams, $state, currentUser, contributionService, columnsFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // sort options for view
    $scope.sortOptions = sortFactory.commentSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.commentFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.commentStatisticFilters();

    // build generic controller stuff
    $scope.route = 'comments';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});
