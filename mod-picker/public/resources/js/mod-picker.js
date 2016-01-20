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
                condition: '=',
                size: '='
            },
            controller: 'loaderController'
        }
})

.controller('searchInputController', function ($scope) {
        $scope.loading = false;
    $scope.processSearch = function () {
        $scope.loading = true;
        setTimeout(function () {
            $scope.loading = false;
            $scope.$apply();
        }, 1000);
    }
})

.controller('loaderController', function ($scope) {
        var diameter = $scope.size || 100;
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

        //-------------------------------
        //MOCK DATA
        //-------------------------------

        var templateData = {
            mods:   [
                {
                    id: 1,
                    name: 'Skyfart: Replace Shouts with Farts',
                    authors: ['Farterarter', 'mr. shout'],
                    versions: ["1.3", "1.2", "1.11"],
                    shortDescription: "Replace your shouts with specialized farts. Works with all shouts. Works best in use with Immersive Smells"
                },
                {
                    id: 2,
                    name: 'Immersive Smells',
                    authors: ['Farterarter'],
                    versions: ["1.0"],
                    shortDescription: "Make your Smells more immersive."
                },
                {
                    id: 3,
                    name: 'Neo from Matrix as Follower',
                    authors: ['R79'],
                    //this will be a tough test
                    versions: ["0.1", "0.7", "0.6"],
                    shortDescription: "also comes with a bluepill"
                },
                {
                    id: 4,
                    name: 'Immersive Dogs',
                    authors: ["barker1338", "whooofie", "Furbeast"],
                    versions: ["1.3"],
                    shortDescription: "Whoof"
                },
                {
                    id: 5,
                    name: 'Become a Cow',
                    authors: ['Taurenlover123', 'Cowburger'],
                    versions: ['1.1.1','2.3'],
                    shortDescription: "mooooo, we love Cows."
                },
                {
                    id: 6,
                    name: 'Furryrim: Everyone is a Khajiit',
                    authors: ['R79', 'Taurenlover123', 'Furbeast'],
                    versions: ['0.1', '0.2', '0.3'],
                    shortDescription: "Furries fur-ever"
                },
                {
                    id: 7,
                    name: 'MLP Dragon Replacement',
                    authors: ['Sunshine', 'clopclopper'],
                    versions: ['1.3.2'],
                    shortDescription: "Replaces all Dragons with My Little Pony characters."
                },
                {
                    id: 8,
                    name: 'Breed your own Dragons!',
                    authors: ['nukelears'],
                    versions: ['1.0'],
                    shortDescription: "Like in How to train your dragon!"
                },
                {
                    id: 9,
                    name: '16k Parallax Texture pack (Performance version included)',
                    authors: ['Pfuscherrrrrr'],
                    versions: ['0.0.1'],
                    shortDescription: "not even working on 4x TitanX PC"
                }
            ],
            updateRanges: [
                {
                    id: 1,
                    text: 'Skyrim'
                },
                {
                    id: 2,
                    text: 'Dawnguard'
                }
            ]
        };

        //simulates browsercaching
        var promises = {};

        //TODO: replace with REST Calls
        function retrieve(location, additionalParam) {
            if(promises[location] && !additionalParam) {
                return promises[location].promise;
            }
            var currentPromise = $q.defer();

            if(!additionalParam) {
                promises[location] = currentPromise;
            }

            var returnData = [];

            switch(location) {
                case '/mods':
                    if (additionalParam) {
                        templateData.mods.forEach(function (mod) {
                            if (mod.id == additionalParam) {
                                returnData = mod;
                            }
                        });
                    } else {
                        templateData.mods.forEach(function (mod) {
                            returnData.push({id: mod.id, name: mod.name});
                        });
                    }
                    break;

                case '/updateRanges':
                    returnData.push(templateData.updateRanges);
                    break;

                case '/search':
                    if (additionalParam && additionalParam.name) {
                        templateData.mods.forEach(function (mod) {
                            if (mod.name.toLowerCase().indexOf(additionalParam.name.toLowerCase()) > -1) {
                                returnData.push(mod);
                            }
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
                return retrieve('/mods', id);
            },
            search: function (searchParams) {
                return retrieve('/search', searchParams);
            },
            retrieveUpdateRanges: function() {
                return retrieve('/updateRanges');
            }
        }
});
