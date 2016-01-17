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
                controller: 'searchController'
            })
            .when('/browse', {
                templateUrl: '/resources/partials/browse.html',
                controller: 'browseController'
            })
            .when('/', {
                templateUrl: '/resources/partials/home.html'
            })
            .when('/mod/:id', {
                templateUrl: '/resources/partials/mod.html'
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

.controller('searchController', function($scope, $q, backend){
        $scope.loading = true;
        backend.retrieveUpdateRanges().then(function(updateRanges) {
            $scope.options = {
                updateRanges: updateRanges
            };
            $scope.loading = false;
        });

        $scope.search = {};

        function processSearch() {
            delete $scope.results;
            delete $scope.errorMessage;
            $scope.loading = true;
            console.log('searchQuery: name=\'' + $scope.search.name + '\' | range: \'' + $scope.search.lastUpdated + '\'');
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

.factory('backend', function ($q) {
        var templateModData = [
            {
                id: 1,
                name: 'Skyfart: Replace Shouts with Farts'
            },
            {
                id: 2,
                name: 'Immersive Smells'
            },
            {
                id: 3,
                name: 'Neo from Matrix as Follower'
            },
            {
                id: 4,
                name: 'Immersive Dogs'
            },
            {
                id: 5,
                name: 'Become a Cow'
            },
            {
                id: 6,
                name: 'Furryrim: Everyone is a Khajiit'
            },
            {
                id: 7,
                name: 'MLP Dragon Replacement'
            },
            {
                id: 8,
                name: 'Breed your own Dragons!'
            },
            {
                id: 9,
                name: '16k Parallax Texture pack (Performance version included)'
            }
        ];

        var templateUpdateRangesData = [
            {
                id: 1,
                text: 'Skyrim'
            },
            {
                id: 2,
                text: 'Dawnguard'
            }
        ];

        var data = {};

        function retrieve(location) {
            var retrievePromise = $q.defer();

            //here we should implement the REST-API as soon as it's working. Mind that we need to work with promises.
            //location would be replaced with static locations we store in a array, at that point we might also need to
            //add arguments.

            //I currently work with Timeout to give it the feel of needing to load stuff from the server
            setTimeout(function () {
                retrievePromise.resolve(location);
            }, 1000);

            return retrievePromise.promise;
        }


        //this is a Mock-function. As soon as the server is hooked up, we will need the regular retrieve function and
        //let the server search through the DB.
        function search(searchOptions) {
            var searchPromise = $q.defer();
            var found = [];
            if(searchOptions && searchOptions.name) {
                templateModData.forEach(function(mod) {
                    if(mod.name.toLowerCase().indexOf(searchOptions.name.toLowerCase())>-1) {
                        found.push(mod);
                    }
                });
            }

            setTimeout(function () {
                searchPromise.resolve(found);
            }, 1000);

            return searchPromise.promise;
        }

        return {
            //caching layer and exposure
            retrieveMods: function() {
                if(!data.mods) {
                    data.mods = retrieve(templateModData);
                }
                return data.mods;
            },
            retrieveUpdateRanges: function() {
                if(!data.updateRanges) {
                    data.updateRanges = retrieve(templateUpdateRangesData)
                }
                return data.updateRanges;
            },
            search: search
        }
});
