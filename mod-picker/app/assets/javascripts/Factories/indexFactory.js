app.service('indexFactory', function(indexService, objectUtils, $timeout) {
    this.buildIndex = function($scope, $stateParams, $state) {
        // initialize local variables
        $scope.availableColumnData = [];
        $scope.actions = [];
        $scope.expanded = {};
        $scope.pages = {};
        $scope.dataRetrieved = false;

        // load sort values from url parameters
        $scope.sort = {};
        indexService.setSortFromParams($scope.sort, $stateParams);

        //  load filter values from url parameters
        angular.default($scope, 'filters', {});
        indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

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
                $scope.dataRetrieved = true;
                delete $scope.error;
                if ($scope.dataCallback) $scope.dataCallback();

                // set url parameters
                var params = indexService.getParams($scope.filters, $scope.sort, page, $scope.filterPrototypes);
                $state.transitionTo($state.current.name, params, { notify: false });
            };
            var errorCallback = function(response) {
                $scope.dataRetrieved = true;
                $scope.error = response;
            };
            if ($scope.contributions) {
                $scope.retrieve($scope.route, options, $scope.pages).then(dataCallback, errorCallback);
            } else {
                $scope.retrieve(options, $scope.pages).then(dataCallback, errorCallback);
            }
        };

        $scope.$watch('[filters, sort]', function(newValue, oldValue) {
            // fetch data again when filters or sort changes
            var dataWait = $scope.dataRetrieved ? 1000 : 0;
            $timeout.cancel($scope.getDataTimeout);
            //if the page is first being loaded, then load the page from params, otherwise go back to page 1
            if (newValue === oldValue) {
                $scope.pages.current = $stateParams.page || 1;
            } else {
                $scope.pages.current = 1;
            }
            $scope.getDataTimeout = $timeout($scope.getData($scope.pages.current), dataWait);
        }, true);
    };

    this.buildState = function(scol, sdir, label, filterPrototypes) {
        // convert label to dash format
        var dashLabel = label.underscore('-');

        // base params
        var params = {
            //column sort
            scol: scol,
            sdir: sdir,
            page: 1
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
