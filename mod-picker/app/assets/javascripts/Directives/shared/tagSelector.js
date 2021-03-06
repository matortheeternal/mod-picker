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

    $scope.atMaxTags = function() {
        return $scope.rawNewTags.length + $scope.activeTags.length >= $scope.maxTags;
    };

    $scope.focusLastTagInput = function() {
        $timeout(function() {
            var loader = $element[0].firstChild;
            var tagsContainer = loader.lastChild.firstElementChild;
            var lastTagBox = tagsContainer.lastElementChild.previousElementSibling;
            var tagInput = lastTagBox.firstElementChild.firstElementChild.firstElementChild;
            console.log('Focus tag input');
            tagInput.focus();
        }, 100);
    };

    $scope.addBlankTag = function() {
        if ($scope.atMaxTags()) return;
        console.log('addBlankTag');
        $scope.$applyAsync(function() {
            $scope.rawNewTags.push({
                text: "",
                mods_count: 0,
                mod_lists_count: 0
            });
            $scope.focusLastTagInput();
        });
    };

    $scope.restoreTag = function($index, skipEmit) {
        var restoredTag = $scope.removedTags.splice($index, 1)[0];
        $scope.activeTags.push(restoredTag);
        if (!skipEmit) {
            $scope.$emit('tagAdded', restoredTag.text);
        }
    };

    $scope.addNewTag = function(tagText) {
        var newTag = $scope.tags.find(function(tag) {
            return tag.text === tagText;
        });
        $scope.rawNewTags.push({
            text: newTag.text,
            mods_count: newTag.mods_count,
            mod_lists_count: newTag.mod_lists_count
        });
    };

    $scope.addTag = function(tagText) {
        if ($scope.atMaxTags()) return;
        var removedTagIndex = $scope.findTagIndex($scope.removedTags, tagText);
        if (removedTagIndex > -1) {
            $scope.restoreTag(removedTagIndex, true)
        } else {
            $scope.addNewTag(tagText);
            $scope.storeTags();
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

    $scope.findTagIndex = function(tags, tagText) {
        return tags.findIndex(function(tag) {
            return tag.text === tagText;
        });
    };

    $scope.removeNewTag = function($index, skipEmit) {
        var removedTag = $scope.rawNewTags.splice($index, 1)[0];
        $scope.storeTags();
        if (!skipEmit) {
            $scope.$emit('tagRemoved', removedTag.text);
        }
    };

    $scope.removeActiveTag = function($index, skipEmit) {
        var removedTag = $scope.activeTags.splice($index, 1)[0];
        $scope.exitRemove(removedTag);
        $scope.removedTags.push(removedTag);
        if (!skipEmit) {
            $scope.$emit('tagRemoved', removedTag.text);
        }
    };

    $scope.removeTag = function(tagText) {
        var activeTagIndex = $scope.findTagIndex($scope.activeTags, tagText);
        if (activeTagIndex > -1) {
            $scope.removeActiveTag(activeTagIndex, true);
        } else {
            var newTagIndex = $scope.findTagIndex($scope.rawNewTags, tagText);
            if (newTagIndex > -1) {
                $scope.removeNewTag(newTagIndex, true);
            }
        }
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
        console.log('ApplyTag: ' + tag.text);
        $scope.$applyAsync(function() {
            if (!tag || index >= $scope.rawNewTags.length) return;
            angular.copyProperties(tag, $scope.rawNewTags[index]);
            $scope.$emit('tagAdded', tag.text);
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
    $scope.$on('addTag', function($event, tagText) {
        $scope.addTag(tagText);
    });
    $scope.$on('removeTag', function($event, tagText) {
        $scope.removeTag(tagText);
    });
});
