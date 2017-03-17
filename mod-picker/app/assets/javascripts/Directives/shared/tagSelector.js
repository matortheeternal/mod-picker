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
            addTagCaption: '@?',
            showCount: '=?',
            showAuthor: '=?',
            showRemove: '=?',
            showAdd: '=?',
            saveCallback: '=?'
        }
    }
});

app.controller('tagSelectorController', function($scope, $element, $timeout, tagService) {
    angular.default($scope, 'addTagCaption', 'Add a tag');

    $scope.rawNewTags = [];
    $scope.removedTags = [];
    $scope.showModsCount = $scope.type === "mod" && $scope.showCount;
    $scope.showModListsCount = $scope.type === "mod-list" && $scope.showCount;

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
        var loader = $element[0].firstChild;
        var addTagButton = loader.lastChild.firstElementChild.lastElementChild;
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
        $scope.savingTags = true;
        $scope.saveCallback(updatedTags).then(function(data) {
            $scope.rawNewTags = [];
            $scope.removedTags = [];
            $scope.newTags = [];
            $scope.activeTags = data.tags;
            $timeout(function() {
                $scope.savingTags = false;
            }, 300);
        }, function() {
            $scope.savingTags = false;
        });
    };

    $scope.applyTag = function(index, tag) {
        $scope.$applyAsync(function() {
            if (!tag) return;
            angular.copyProperties(tag, $scope.rawNewTags[index]);
            $scope.storeTags();
            $scope.focusAddTag();
        });
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
