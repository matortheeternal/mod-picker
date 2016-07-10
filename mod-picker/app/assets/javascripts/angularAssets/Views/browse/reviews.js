app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.reviewFilters();
    var state = indexFactory.buildState('reputation', 'asc', 'reviews', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('reviewsController', function ($scope, $stateParams, $state, currentUser, contributionService, indexService,  filtersFactory, indexFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // filters for view
    $scope.filterPrototypes = filtersFactory.reviewFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.reviewStatisticFilters();

    // build generic controller stuff
    $scope.route = 'reviews';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});