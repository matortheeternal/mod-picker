//everything in one file currently 'cause I'm to lazy to implement a merging tool or add a script tag for each separated
//module. Should be changed when the Filesize is way to heavy (let's say 500 lines).

var app = angular.module('modPicker', [
    'ngRoute'
])

.config(['$routeProvider',
    function($routeProvider){
        $routeProvider.
            when('/search', {
                templateUrl: '/resources/partials/search.html',
                controller: 'searchController',
                reloadOnSearch: false
            })
            .when('/browse', {
                templateUrl: '/resources/partials/browse.html',
                controller: 'browseController'
            })
            .when('/', {
                templateUrl: '/resources/partials/home.html'
            })
            .when('/mod/:modId', {
                templateUrl: '/resources/partials/mod.html',
                controller: 'modController'
            })
            .otherwise({
                redirectTo: '/'
            });
}])

.directive('modList', function(){
  return {
      restrict: 'E',
      templateUrl: '/resources/directives/modList.html',
      scope: {
          data: '='
      }
  }
})

.directive('loader', function() {
        return {
            restrict: 'E',
            templateUrl: '/resources/directives/loader.html',
            scope: {
                condition: '='
            },
            controller: 'loaderController'
        }
})

.controller('loaderController', function ($scope) {
        var diameter = 100;
        document.getElementById('loader').style.width = diameter+'px';
        var cl = new CanvasLoader('loader');
        cl.setColor('#56b7c4'); // default is '#000000'
        cl.setDiameter(diameter); // default is 40
        cl.setDensity(64); // default is 40
        cl.setRange(0.8); // default is 1.3
        cl.setFPS(60); // default is 24

        if($scope.condition) {
            cl.show();
        }

        $scope.$watch('condition', function(newValue) {
            if(newValue) {
                cl.show();
            } else {
                cl.hide();
            }
        });
})

.controller('browseController', function($scope, $q, backend) {
        $scope.loading = true;
        backend.retrieveMods().then(function(data) {
            $scope.mods = data;
            $scope.loading = false;
        });
})

.controller('modController', function($scope, $q, $routeParams, backend){
        $scope.loading = true;
        backend.retrieveMod($routeParams.modId).then(function (data) {
            $scope.loading = false;
            $scope.mod = data;
        });
})

.controller('searchController', function($scope, $q, backend, $location){
        $scope.search = {};

        //TODO: make the search parameter shorter, similar to imgur URLs. -> implement two way hashing
        if($location.search().s) {
            $scope.search.name = $location.search().s;
            processSearch();
        }

        function processSearch() {
            delete $scope.results;
            delete $scope.errorMessage;
            $location.search('s', $scope.search.name);
            $scope.loading = true;
            backend.search($scope.search).then(function (data) {
                $scope.loading = false;
                if(data.length) {
                    $scope.results = data;
                } else {
                    $scope.errorMessage = "no mod found!"
                }
            });
        }
        $scope.processSearch = processSearch;
})

.factory('backend', function ($q, $http) {

        //Constant to be flexible in the future. Us as prefix for ALL requests
        var BASE_LOCATION = '';

        //TODO: replace with REST Calls
        function retrieve(context) {
            var promise = $q.defer();
            $http.get(BASE_LOCATION + context + '.json').then(function(data) {
                promise.resolve(data.data);
            });
            return promise.promise;
        }

        function mockRetrieve(location, additionalParam) {
            var currentPromise = $q.defer();

            var returnData = [];

            switch(location) {
                case '/search':
                    if (additionalParam && additionalParam.name) {
                        retrieve('/mods').then(function (mods) {
                            mods.forEach(function (mod) {
                                if (mod.name.toLowerCase().indexOf(additionalParam.name.toLowerCase()) > -1) {
                                    returnData.push(mod);
                                }
                            });
                        });
                    }
                    break;
            }
            //I currently work with Timeout to give it the feel of needing to load stuff from the server
            setTimeout(function () {
                currentPromise.resolve(returnData);
            }, 1000);

            return currentPromise.promise;
        }

        return {
            //caching layer and exposure
            retrieveMods: function() {
                return retrieve('/mods');
            },
            retrieveMod: function (id) {
                return retrieve('/mods/' + id);
            },
            search: function (searchParams) {
                //not implemented in the Backend yet
                return mockRetrieve('/search', searchParams);
            },
            retrieveUpdateRanges: function() {
                return mockRetrieve('/updateRanges');
            }
        }
});