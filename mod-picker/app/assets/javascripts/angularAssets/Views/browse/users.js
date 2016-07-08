app.run(function($futureState, indexService, filtersFactory) {
    // base params
    var params = {
        //column sort
        scol: 'username',
        sdir: 'desc',

        //searches
        q: '',
        l: '',

        //roles
        adm: true,
        mod: true,
        ma: true,
        usr: true
    };

    // build slider filter params
    filtersFactory.userFilters().forEach(function(filter) {
        params[filter.param] = '';
    });

    // construct state
    var state = {
        stateName: 'base.users',
        name: 'base.users',
        templateUrl: '/resources/partials/browse/users.html',
        controller: 'usersController',
        url: indexService.getUrl('users', params),
        params: params,
        type: 'lazy'
    };

    // dynamically apply state
    $futureState.futureState(state);
});

app.controller('usersController', function ($scope, $q, $stateParams, $state, userService, sliderFactory, columnsFactory, filtersFactory, currentUser, indexService) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // initialize local variables
    $scope.availableColumnData = [];
    $scope.extendedFilterVisibility = {};
    $scope.sort = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.userColumns();
    $scope.columnGroups = columnsFactory.userColumnGroups();
    $scope.actions = [];

    // initialize filters
    $scope.filterPrototypes = filtersFactory.userFilters();
    $scope.filters = {
        roles: {
            admin: $stateParams.adm,
            moderator: $stateParams.mod,
            author: $stateParams.ma,
            user: $stateParams.usr
        }
    };
    //load name and author from url parameters
    indexService.setFilterFromParam($scope.filters, 'search', $stateParams.q);
    indexService.setFilterFromParam($scope.filters, 'linked', $stateParams.l);
    //load slider values from url parameters
    indexService.setSliderFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);
    //load tags and categories from url parameters
    indexService.setListFilterFromParam($scope.filters, 'tags', $stateParams.t);
    indexService.setListFilterFromParam($scope.filters, 'categories', $stateParams.c);

    // load filter prototypes
    $scope.dateFilters = filtersFactory.userDateFilters();
    $scope.statFilters = filtersFactory.userStatisticFilters();

    /* filter helper functions */
    $scope.toggleExtendedFilterVisibility = function(filterId) {
        var extendedFilter = $scope.extendedFilterVisibility[filterId] = !$scope.extendedFilterVisibility[filterId];
        if (extendedFilter) {
            $scope.$broadcast('rerenderSliders');
        }
    };

    /* data */
    var firstGet = false;
    $scope.getUsers = function(page) {
        delete $scope.users;
        var options = {
            filters: $scope.filters,
            sort: $scope.sort,
            page: page || 1
        };
        userService.retrieveUsers(options, $scope.pages).then(function(data) {
            $scope.users = data.users;
            firstGet = true;
        });
    };

    // fetch users when we load the page
    $scope.getUsers();

    // create a watch
    var getUsersTimeout;
    $scope.$watch('[filters, sort]', function() {
        // get users
        if ($scope.filters && firstGet) {
            clearTimeout(getUsersTimeout);
            $scope.pages.current = 1;
            getUsersTimeout = setTimeout($scope.getUsers, 700);
        }

        // set url parameters
        if ($scope.filters && firstGet) {
            var params = indexService.getParamsFromSliderFilters($scope.filters, $scope.filterPrototypes);

            // set general params
            indexService.setParamFromFilter($scope.filters.roles, 'admin', params, 'adm');
            indexService.setParamFromFilter($scope.filters.roles, 'moderator', params, 'mod');
            indexService.setParamFromFilter($scope.filters.roles, 'author', params, 'ma');
            indexService.setParamFromFilter($scope.filters.roles, 'user', params, 'usr');
            indexService.setParamFromFilter($scope.filters, 'search', params, 'q');
            indexService.setParamFromFilter($scope.filters, 'linked', params, 'l');

            // transition to the new state
            $state.transitionTo('base.users', params, { notify: false });
        }
    }, true);
});
