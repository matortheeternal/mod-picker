app.directive('tagSelector', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tagSelector.html',
        controller: 'tagSelectorController',
        scope: {
        	tags: '=',
        	activeTags: '=',
            newTags: '=',
            maxTags: '=?',
            showModsCount: '=?',
            showModListsCount: '=?',
            showAuthor: '=?',
            showRemove: '=?',
            showAdd: '=?'
        }
    }
});

app.controller('tagSelectorController', function ($scope) {
    $scope.addTag = function() {
        $scope.newTags.push({
            text: "Test",
            mods_count: 0
        });
    }
});
