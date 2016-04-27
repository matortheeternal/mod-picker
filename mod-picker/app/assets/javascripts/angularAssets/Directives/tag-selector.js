app.directive('tagSelector', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tagSelector.html',
        controller: 'tagSelectorController',
        scope: {
        	activeTags: '=',
            newTags: '=',
            maxTags: '=',
            canCreate: '=',
            showModsCount: '=?',
            showModListsCount: '=?',
            showAuthor: '=?',
            showRemove: '=?',
            showAdd: '=?'
        }
    }
});

app.controller('tagSelectorController', function ($scope, tagService) {
    $scope.rawNewTags = [];

    tagService.retrieveTags().then(function(data) {
        $scope.tags = data;
    });

    $scope.addTag = function() {
        if ($scope.rawNewTags.length + $scope.activeTags.length < $scope.maxTags) {
            $scope.rawNewTags.push({
                text: "Test", //TODO: replace with something else
                mods_count: 0,
                mod_lists_count: 0
            });
        }
    };

    $scope.removeTag = function($index) {
        $scope.rawNewTags.splice($index, 1);
        $scope.storeTags();
    };

    $scope.applyTag = function(index, tag) {
        $scope.rawNewTags[index] = tag;
        $scope.storeTags();
    };

    $scope.storeTags = function() {
        $scope.newTags = [];
        for (var i = 0; i < $scope.rawNewTags.length; i++) {
            rawTag = $scope.rawNewTags[i];
            $scope.newTags.push(rawTag.text);
        }
    };
});