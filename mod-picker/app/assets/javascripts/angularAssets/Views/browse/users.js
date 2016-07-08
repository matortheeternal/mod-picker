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
        adm: false,
        mod: false,
        ma: false,
        usr: false
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
            mod_author: $stateParams.ma,
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

    $scope.availableFilters = function(filters) {
        return filters.filter(function(item) {
            return $scope.filterAvailable(item);
        });
    };

    $scope.filterAvailable = function(filter) {
        var result = true;
        Object.keys($scope.filters.sources).forEach(function(key) {
            if ($scope.filters.sources[key] && !filter.sites[key]) {
                result = false;
            }
        });
        return result;
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
    // laod available stat filters
    $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

    // create a watch
    var getUsersTimeout;
    $scope.$watch('[filters, sort]', function() {
        // make columns that are no longer available no longer visible
        $scope.columns.forEach(function(column) {
            if (column.visibility && typeof column.data === 'object') {
                column.visibility = Object.keys(column.data).some(function(key) {
                    return $scope.availableColumnData.indexOf(key) > -1;
                });
            }
        });

        // hide statistic filters that no longer apply
        $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

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
            indexService.setParamFromFilter($scope.filters.roles, 'mod_author', params, 'ma');
            indexService.setParamFromFilter($scope.filters.roles, 'user', params, 'usr');
            indexService.setParamFromFilter($scope.filters, 'search', params, 'q');
            indexService.setParamFromFilter($scope.filters, 'linked', params, 'l');

            // transition to the new state
            $state.transitionTo('base.users', params, { notify: false });
        }
    }, true);
});
