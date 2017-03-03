app.directive('sortControl', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/sortControl.html',
        controller: 'sortController',
        scope: {
            sort: '=?',
            sortOptions: '=?',
            changeCallback: '&onChange'
        }
    }
});

app.controller('sortController', function($scope) {
    // inherited scope attributes
    angular.inherit($scope, 'sort');
    angular.inherit($scope, 'sortOptions');
});
