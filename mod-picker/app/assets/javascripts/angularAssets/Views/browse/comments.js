app.run(function($futureState, indexService, filtersFactory) {
    // base params
    var params = {
        //column sort
        scol: 'username',
        sdir: 'desc',

        //searches
        q: '', // search text body
        s: '', // submitted by

        // allow children comments
        c: true,

        // commentable types
        ml: true,
        cor: true,
        usr: true
    };

    // build slider filter params
    filtersFactory.commentFilters().forEach(function(filter) {
        params[filter.param] = '';
    });

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
    $scope.extendedFilterVisibility = {};
    $scope.sort = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.commentColumns();
    $scope.columnGroups = columnsFactory.commentColumnGroups();
    $scope.actions = [];

    // initialize filters
    $scope.filterPrototypes = filtersFactory.commentFilters();
    $scope.filters = {
        commentable: {
            ModList: $stateParams.ml,
            Correction: $stateParams.cor,
            User: $stateParams.usr
        }
    };
    //load submitter from url parameters
    indexService.setFilterFromParam($scope.filters, 'search', $stateParams.q);
    indexService.setFilterFromParam($scope.filters, 'submitter', $stateParams.s);
    indexService.setFilterFromParam($scope.filters, 'is_child', $stateParams.c);
    //load slider values from url parameters
    indexService.setSliderFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

    // load filter prototypes
    $scope.dateFilters = filtersFactory.contributionDateFilters();
    $scope.statFilters = filtersFactory.commentStatisticFilters();

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
            var params = indexService.getParamsFromSliderFilters($scope.filters, $scope.filterPrototypes);

            // set general params
            indexService.setParamFromFilter($scope.filters, 'search', params, 'q');
            indexService.setParamFromFilter($scope.filters, 'submitter', params, 's');
            indexService.setParamFromFilter($scope.filters, 'is_child', params, 'c');
            indexService.setParamFromFilter($scope.filters.commentable, 'ModList', params, 'ml');
            indexService.setParamFromFilter($scope.filters.commentable, 'Correction', params, 'cor');
            indexService.setParamFromFilter($scope.filters.commentable, 'User', params, 'usr');

            // transition to the new state
            $state.transitionTo('base.comments', params, { notify: false });
        }
    }, true);
});
