app.directive('searchFilterSection', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/searchFilterSection.html',
        scope: false,
        controller: 'searchFilterSectionController'
    }
});

app.controller('searchFilterSectionController', function($scope) {
    var searchTerms = $scope.filterPrototypes.find(function(filter) {
        return filter.data === 'search';
    }).terms;
    $scope.searchHint = searchTerms.map(function(term) {
        return term.name + ": " + term.description;
    }).join('\n');
});