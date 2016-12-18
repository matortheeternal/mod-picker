app.directive('tagSelector', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/tagSelector.html',
        controller: 'tagSelectorController',
        scope: {
            activeTags: '=',
            newTags: '=',
            maxTags: '=',
            canCreate: '=',
            type: '@',
            showCount: '=?',
            showAuthor: '=?',
            showRemove: '=?',
            showAdd: '=?',
            saveCallback: '=?'
        }
    }
});

app.controller('tagSelectorController', function($scope, $element, $timeout, tagService) {
    $scope.rawNewTags = [];
    $scope.removedTags = [];
    $scope.showModsCount = $scope.type === "mod" && $scope.showCount;
    $scope.showModListsCount = $scope.type === "mod-list" && $scope.showCount;
    var addTagButton = $element[0].firstChild.lastElementChild;

    tagService.retrieveAllTags().then(function(data) {
        $scope.tags = data;
        $scope.loadTags();
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

    $scope.focusAddTag = function() {
        $timeout(function() {
            addTagButton.focus();
        }, 50);
    };

    $scope.enterRemove = function(tag) {
        tag.tagBoxClass = 'red-box';
    };

    $scope.exitRemove = function(tag) {
        tag.tagBoxClass = '';
    };

    $scope.removeTag = function($index) {
        $scope.rawNewTags.splice($index, 1);
        $scope.storeTags();
    };

    $scope.removeActiveTag = function($index) {
        var removedTag = $scope.activeTags.splice($index, 1);
        $scope.removedTags.push(removedTag[0]);
    };

    $scope.resetTags = function() {
        $scope.activeTags = $scope.activeTags.concat($scope.removedTags);
        $scope.rawNewTags = [];
        $scope.removedTags = [];
        $scope.storeTags();
        $scope.$applyAsync();
    };

    $scope.saveTags = function() {
        var updatedTags = [];
        $scope.activeTags.forEach(function(tag) {
            updatedTags.push(tag.text);
        });
        $scope.rawNewTags.forEach(function(tag) {
            updatedTags.push(tag.text);
        });
        $scope.saveCallback(updatedTags).then(function(data) {
            $scope.activeTags = data.tags;
            $scope.rawNewTags = [];
            $scope.removedTags = [];
            $scope.storeTags();
        });
    };

    $scope.applyTag = function(index, tag) {
        $scope.rawNewTags[index] = tag;
        $scope.storeTags();
    };

    $scope.rawTagText = function() {
        return $scope.rawNewTags.map(function(rawTag) {
            return rawTag.text;
        });
    };

    $scope.storeTags = function() {
        $scope.newTags = $scope.rawTagText();
    };

    $scope.findTag = function(tagText) {
        return $scope.tags.find(function(tag) {
            return tag.text === tagText
        });
    };

    $scope.loadTags = function() {
        if (!$scope.newTags || $scope.newTags.equals($scope.rawTagText())) return;
        $scope.rawNewTags = $scope.newTags.map(function(newTag) {
            return $scope.findTag(newTag);
        }).filter(angular.isDefined);
    };

    $scope.$on('reloadTags', $scope.loadTags);
});
