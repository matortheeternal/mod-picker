app.directive('tagSelector', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tagSelector.html',
        controller: 'tagSelectorController',
        scope: {
        	tags: '=',
        	activeTags: '=',
            showModsCount: '=',
            showModListsCount: '=',
            showAuthor: '=',
            showRemove: '=',
            newTags: '='
        }
    }
});

app.controller('tagSelectorController', function ($scope) {
});
