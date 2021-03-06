app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.articleFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'articles', filterPrototypes);
    state.controller = 'articlesIndexController';
    $futureState.futureState(state);
});

app.controller('articlesIndexController', function($scope, $rootScope, $stateParams, $state, articleService, helpFactory, columnsFactory, filtersFactory, indexService, indexFactory, sortFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = $rootScope.permissions;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Articles');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // sort options for view
    $scope.sortOptions = sortFactory.articleSortOptions();

    // filters for view
    $scope.filterPrototypes = filtersFactory.articleFilters();
    $scope.dateFilters = filtersFactory.articleDateFilters();

    // build generic controller stuff
    $scope.route = 'articles';
    $scope.retrieve = articleService.retrieveArticles;
    indexFactory.buildIndex($scope, $stateParams, $state);
});
