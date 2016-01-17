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
            .when('/', {
                templateUrl: '/resources/partials/home.html'
            })
            .otherwise({
                redirectTo: '/'
            });
    }])

.controller('mainController', function($scope) {
        $scope.testMessage = "Test works";
})

.controller('searchController', function($scope){
        $scope.options = {
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

        $scope.search = {};

        function processSearch() {
            console.log('searchQuery: name=\'' + $scope.search.name + '\' | range: \'' + $scope.search.lastUpdated + '\'');
            $scope.results = [
                {
                    link: '',
                    text: 'CBBE'
                },
                {
                    link: '',
                    text: 'Sky UI'
                },
                {
                    link: '',
                    text: 'Skyfart: Replace Shouts with Farts'
                },
                {
                    link: '',
                    text: 'immersive Smells'
                },
                {
                    link: '',
                    text: 'Neo from Matrix as Follower'
                }
            ]
        }
        $scope.processSearch = processSearch;
});
