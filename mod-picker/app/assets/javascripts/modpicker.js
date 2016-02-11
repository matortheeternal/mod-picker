//everything in one file currently 'cause I'm to lazy to implement a merging tool or add a script tag for each separated
//module. Should be changed when the Filesize is way to heavy (let's say 500 lines).

var app = angular.module('modPicker', [
    'ngRoute'
]);

//--------------------------------------------------------------------------------------------------------
// ROUTES
//--------------------------------------------------------------------------------------------------------

//____________________________________________________
// Home / Basic settings
//____________________________________________________
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider
        .when('/', {
            templateUrl: '/resources/partials/home.html'
        })
        .otherwise({
            redirectTo: '/'
        });
}]);

app.controller('searchInputController', function ($scope, $location) {
    $scope.loading = false;
    $scope.processSearch = function () {
        $scope.loading = true;
        //$location.search('s', $scope.search.name);
        setTimeout(function () {
            $scope.loading = false;
            $scope.$apply();
        }, 1000);
    }
});


//____________________________________________________
// Browse
//____________________________________________________

app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/browse', {
        templateUrl: '/resources/partials/browse.html',
        controller: 'browseController'
        }
    );
}]);

app.controller('browseController', function ($scope, $q, backend) {
    $scope.loading = true;
    backend.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});


//____________________________________________________
// Mod
//____________________________________________________
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
        templateUrl: '/resources/partials/mod.html',
        controller: 'modController'
        }
    );
}]);

app.controller('modController', function ($scope, $q, $routeParams, backend) {
    $scope.loading = true;
    backend.retrieveMod($routeParams.modId).then(function (data) {
        $scope.loading = false;
        $scope.mod = data;
    });
});


//____________________________________________________
// Search
//____________________________________________________


app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/search', {
            templateUrl: '/resources/partials/search.html',
            controller: 'searchController',
            reloadOnSearch: false
        }
    );
}]);

app.controller('searchController', function ($scope, $q, backend, $location) {
    $scope.search = {};

    //TODO: make the search parameter shorter, similar to imgur URLs. -> implement two way hashing
    if ($location.search().s) {
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
            if (data.length) {
                $scope.results = data;
            } else {
                $scope.errorMessage = "no mod found!"
            }
        });
    }

    $scope.processSearch = processSearch;
});


//____________________________________________________
// submitMod
//____________________________________________________
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/submitMod', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend) {

    $scope.submit = function () {
        if ($scope.submitModForm.$valid) {
            var primaryCategoryId = $scope.primaryCategory.subCategoryId || $scope.primaryCategory.mainCategoryId;
            var secondaryCategoryId = $scope.secondaryCategory && ($scope.secondaryCategory.subCategoryId || $scope.secondaryCategory.mainCategoryId);
            alert('data that would be sent to the server now' +
                '\nUrl: ' + $scope.url +
                '\nName: ' + $scope.name +
                '\nPrimaryCategoryId: ' + primaryCategoryId +
                (secondaryCategoryId ? '\nSecondaryCategoryId: ' + secondaryCategoryId : ''));
            window.location = '#/browse';
        }
    }
});


//--------------------------------------------------------------------------------------------------------
// DIRECTIVES
//--------------------------------------------------------------------------------------------------------

//____________________________________________________
// <mod-list>
//____________________________________________________

app.directive('modList', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList.html',
        scope: {
            data: '='
        }
    }
});


//____________________________________________________
// <loader>
//____________________________________________________

app.directive('loader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/loader.html',
        scope: {
            condition: '=',
            size: '='
        },
        controller: 'loaderController'
    }
});

app.controller('loaderController', function ($scope) {
    var diameter = $scope.size || 100;
    document.getElementById('loader').style.width = diameter + 'px';
    var cl = new CanvasLoader('loader');
    cl.setColor('#c0a060'); // default is '#000000'
    cl.setDiameter(diameter); // default is 40
    cl.setDensity(64); // default is 40
    cl.setRange(0.8); // default is 1.3
    cl.setFPS(60); // default is 24

    if ($scope.condition) {
        cl.show();
    }

    $scope.$watch('condition', function (newValue) {
        if (newValue) {
            cl.show();
        } else {
            cl.hide();
        }
    });
});


//____________________________________________________
// <expandable>
//____________________________________________________

app.directive('expandable', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/expandable.html',
        controller: 'expandableController',
        scope: {
            expanded: '=',
            title: '='
        },
        transclude: true
    }
});

app.controller('expandableController', function ($scope) {
    $scope.toggle = function () {
        $scope.expanded = !$scope.expanded;
    }
});


//____________________________________________________
// <category-picker>
//____________________________________________________

app.directive('categoryPicker', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/categoryPicker.html',
        controller: 'categoryPickerController',
        scope: {
            model: '=',
            required: '='
        }
    }
});

app.controller('categoryPickerController', function ($scope, backend) {
        backend.retrievePrimaryCategory().then(function (data) {
            $scope.mainCategories = data;
            $scope.loading = false;
        });
    
        $scope.$watch('model.mainCategoryId', function (mainCategoryId) {
            if(mainCategoryId) {
                backend.retrieveSecondaryCategory(mainCategoryId).then(function (data) {
                    $scope.subCategories = data;
                })
            } else {
                $scope.subCategories = undefined;
            }
        });
});


//--------------------------------------------------------------------------------------------------------
// FACTORIES
//--------------------------------------------------------------------------------------------------------

app.factory('backend', function ($q, $http) {

    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';

    //TODO: replace with REST Calls
    function retrieve(context) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            cache: true
        }).then(function (data) {
            promise.resolve(data.data);
        });
        return promise.promise;
    }

    function mockRetrieve(location, additionalParam) {
        var currentPromise = $q.defer();

        var returnData = [];

        var async = false;

        switch (location) {
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

            case '/category':
                async = true;
                retrieve('/categories').then(function (data) {
                    data.forEach(function (category) {
                        if (additionalParam === 'primary' ? !category.parent_id : category.parent_id == additionalParam) {
                            returnData.push(category);
                        }
                    });
                    currentPromise.resolve(returnData);
                });
        }

        if (!async) {
            //I currently work with Timeout to give it the feel of needing to load stuff from the server
            setTimeout(function () {
                currentPromise.resolve(returnData);
            }, 1000);
        }

        return currentPromise.promise;
    }

    return {
        //caching layer and exposure
        retrieveMods: function () {
            return retrieve('/mods');
        },
        retrieveMod: function (id) {
            return retrieve('/mods/' + id);
        },
        search: function (searchParams) {
            //not implemented in the Backend yet
            return mockRetrieve('/search', searchParams);
        },
        retrievePrimaryCategory: function () {
            return mockRetrieve('/category', 'primary');
        },
        retrieveSecondaryCategory: function (primaryCategoryId) {
            return mockRetrieve('/category', primaryCategoryId);
        }
    }
});