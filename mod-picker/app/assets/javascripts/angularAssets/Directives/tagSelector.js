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
            showAdd: '=?',
            saveCallback: '=?'
        }
    }
});

app.controller('tagSelectorController', function ($scope, tagService) {
    $scope.rawNewTags = [];
    $scope.removedTags = [];

    tagService.retrieveTags().then(function(data) {
        $scope.tags = data;
    });

    $scope.addTag = function() {
        if ($scope.rawNewTags.length + $scope.activeTags.length < $scope.maxTags) {
            $scope.rawNewTags.push({
                text: "",
                mods_count: 0,
                mod_lists_count: 0
            });
        }
    };

    $scope.removeTag = function($index) {
        $scope.rawNewTags.splice($index, 1);
        $scope.storeTags();
    };

    $scope.removeActiveTag = function ($index) {
        var removedTag = $scope.activeTags.splice($index, 1);
        $scope.removedTags.push(removedTag);
    };

    $scope.resetTags = function () {
        $scope.activeTags = $scope.activeTags.concat($scope.removedTags);
        $scope.rawNewTags = [];
        $scope.storeTags();
        $scope.$applyAsync();
    };

    $scope.saveTags = function() {
        var updatedTags = $scope.newTags.slice(0);
        $scope.activeTags.forEach(function(tag) {
            updatedTags.push(tag.text);
        });
        $scope.saveCallback(updatedTags);
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