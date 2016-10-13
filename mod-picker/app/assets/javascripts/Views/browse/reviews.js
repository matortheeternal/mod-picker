app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.reviewFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'reviews', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('reviewsController', function($scope, $rootScope, $stateParams, $state, contributionService, indexService,  filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = $rootScope.permissions;

    // sort options for view
    $scope.sortOptions = sortFactory.reviewSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.reviewFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.reviewStatisticFilters();

    // build generic controller stuff
    $scope.route = 'reviews';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state);
});