app.run(function($futureState, indexService, filtersFactory) {
    // base params
    var params = {
        //column sort
        scol: 'reputation',
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

app.controller('commentsIndexController', function ($scope, $q, $stateParams, $state, contributionService, sliderFactory, columnsFactory, filtersFactory, currentUser, indexService) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // initialize local variables
    $scope.availableColumnData = [];
    $scope.actions = [];
    $scope.extendedFilterVisibility = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.commentColumns();
    $scope.columnGroups = columnsFactory.commentColumnGroups();

    // load sort values from url parameters
    $scope.sort = {};
    indexService.setSortFromParams($scope.sort, $stateParams);

    // initialize filters
    $scope.filterPrototypes = filtersFactory.commentFilters();
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.commentStatisticFilters();
    $scope.filters = {};
    //load filter values from url parameters
    indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

    /* data fetching functions */
    var firstGet = false;
    $scope.getComments = function(page) {
        delete $scope.comments;
        var options = {
            filters: $scope.filters,
            sort: $scope.sort,
            page: page || 1
        };
        contributionService.retrieveContributions('comments', options, $scope.pages).then(function(data) {
            $scope.comments = data.comments;
            firstGet = true;
        });
    };

    // fetch comments when we load the page
    $scope.getComments();

    // fetch comments again when filters or sort changes
    var getCommentsTimeout;
    $scope.$watch('[filters, sort]', function() {
        // get users
        if ($scope.filters && firstGet) {
            clearTimeout(getCommentsTimeout);
            $scope.pages.current = 1;
            getCommentsTimeout = setTimeout($scope.getComments, 700);
        }

        // set url parameters
        if ($scope.filters && firstGet) {
            var params = indexService.getParamsFromFilters($scope.filters, $scope.filterPrototypes);
            $state.transitionTo('base.comments', params, { notify: false });
        }
    }, true);
});
