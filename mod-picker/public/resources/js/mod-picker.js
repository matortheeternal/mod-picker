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

.controller('browseController', function($scope, $q, backend) {
        backend.retrieveMods().then(function(data) {
           $scope.mods = data;
        });
})

.controller('searchController', function($scope, $q, backend){
        backend.retrieveUpdateRanges().then(function(updateRanges) {
            $scope.options = {
                updateRanges: updateRanges
            };
        });

        $scope.search = {};

        function processSearch() {
            console.log('searchQuery: name=\'' + $scope.search.name + '\' | range: \'' + $scope.search.lastUpdated + '\'');
            backend.retrieveMods().then(function (data) {
                $scope.results = data;
            });
        }
        $scope.processSearch = processSearch;
})

.factory('backend', function ($q) {
        var templateModData = [
            {
                name: 'Skyfart: Replace Shouts with Farts'
            },
            {
                name: 'Immersive Smells'
            },
            {
                name: 'Neo from Matrix as Follower'
            },
            {
                name: 'Immersive Dogs'
            },
            {
                name: 'Become a Cow'
            },
            {
                name: 'Furryrim: Everyone is a Khajiit'
            },
            {
                name: 'MLP Dragon Replacement'
            },
            {
                name: 'Breed your own Dragons!'
            },
            {
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
            //here we should implement the REST-API as soon as it's working. Mind that we need to work with promises.
            //I currently work with Timeout to give it the feel of needing to load stuff from the server
            var retrievePromise = $q.defer();

            setTimeout(function () {
                retrievePromise.resolve(location);
            }, 1000);

            return retrievePromise.promise;
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
            }
        }
});
