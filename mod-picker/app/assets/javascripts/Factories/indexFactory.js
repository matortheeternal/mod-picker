app.service('indexFactory', function(indexService, objectUtils, $timeout) {
    this.buildIndex = function($scope, $stateParams, $state) {
        // initialize local variables
        $scope.availableColumnData = [];
        $scope.actions = [];
        $scope.expanded = {};
        $scope.pages = {};

        // load sort values from url parameters
        $scope.sort = {};
        indexService.setSortFromParams($scope.sort, $stateParams);

        //  load filter values from url parameters
        angular.default($scope, 'filters', {});
        indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

        // load current page value from url params
        $scope.pages.current = parseInt($scope.filters.page);

        /* data fetching functions */
        $scope.getData = function(page) {
            delete $scope[$scope.route];
            var options = {
                filters: angular.copy($scope.filters),
                sort: $scope.sort,
                page: page || 1
            };
            objectUtils.deleteEmptyProperties(options.filters, 0, true);
            var dataCallback = function(data) {
                $scope[$scope.route] = data[$scope.route];
                delete $scope.error;
                if ($scope.dataCallback) $scope.dataCallback();
            };
            var errorCallback = function(response) {
                $scope.error = response;
            };
            if ($scope.contributions) {
                $scope.retrieve($scope.route, options, $scope.pages).then(dataCallback, errorCallback);
            } else {
                $scope.retrieve(options, $scope.pages).then(dataCallback, errorCallback);
            }
        };

        $scope.refreshFilters = function(page) {
            //change pages instantly
            //but only update params and retrieve new data 500ms after the last filter change
            var timeoutLength = page ? 0 : 500;
            $timeout.cancel($scope.refreshTimeout);
            $scope.refreshTimeout = $timeout(function() {
                $scope.pages.current = page || 1;
                //set the page filter, so the url can be updated
                $scope.filters.page = $scope.pages.current;

                // set url parameters
                var params = indexService.getParams($scope.filters, $scope.sort, $scope.filterPrototypes);
                $state.transitionTo($state.current.name, params, { notify: false });
                //retreive new data
                $scope.getData($scope.pages.current);
            }, timeoutLength);
        };

        //retrieve the initial mods using the initial url params
        $scope.getData($scope.pages.current);
    };

    this.buildState = function(scol, sdir, label, filterPrototypes) {
        // convert label to dash format
        var dashLabel = label.underscore('-');

        // base params
        var params = {
            //column sort
            scol: scol,
            sdir: sdir
        };
        indexService.setDefaultParamsFromFilters(params, filterPrototypes);

        // construct and return the state
        return {
            stateName: 'base.' + dashLabel,
            name: 'base.' + dashLabel,
            templateUrl: '/resources/partials/browse/' + label + '.html',
            controller: label + 'Controller',
            url: indexService.getUrl(dashLabel, params),
            params: params,
            type: 'lazy'
        };
    };
});
