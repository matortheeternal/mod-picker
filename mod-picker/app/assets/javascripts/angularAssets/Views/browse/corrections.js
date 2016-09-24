app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.correctionFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'corrections', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('correctionsController', function ($scope, $rootScope, $stateParams, $state, contributionService, indexService,  filtersFactory, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = $rootScope.permissions;

    // sort options for view
    $scope.sortOptions = sortFactory.correctionSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.correctionFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.correctionStatisticFilters();

    // build generic controller stuff
    $scope.route = 'corrections';
    $scope.contributions = true;
    $scope.retrieve = contributionService.retrieveContributions;
    indexFactory.buildIndex($scope, $stateParams, $state);
});