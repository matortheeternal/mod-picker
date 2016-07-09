app.run(function($futureState, indexService, filtersFactory) {
    // base params
    var params = {
        //column sort
        scol: 'id',
        sdir: 'asc'
    };
    indexService.setDefaultParamsFromFilters(params, filtersFactory.commentFilters());

    // construct state
    var state = {
        stateName: 'base.comments',
        name: 'base.comments',
        templateUrl: '/resources/partials/browse/comments.html',
        controller: 'commentsIndexController',
        url: indexService.getUrl('comments', params),
        params: params,
        type: 'lazy'
    };

    // dynamically apply state
    $futureState.futureState(state);
});

app.controller('commentsIndexController', function ($scope, $stateParams, $state, currentUser, contributionService, columnsFactory, filtersFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // columns for view
    $scope.columns = columnsFactory.commentColumns();
    $scope.columnGroups = columnsFactory.commentColumnGroups();

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
