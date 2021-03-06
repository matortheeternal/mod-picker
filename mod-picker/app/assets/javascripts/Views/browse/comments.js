app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.commentFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'comments', filterPrototypes);
    state.controller = 'commentsIndexController';
    $futureState.futureState(state);
});

app.controller('commentsIndexController', function($scope, $rootScope, $stateParams, $state, contributionService, columnsFactory, helpFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Comments');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

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
    indexFactory.buildIndex($scope, $stateParams, $state);
});
