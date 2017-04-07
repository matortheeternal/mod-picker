app.controller('modClassificationController', function($scope, $rootScope, $timeout, categoryService, tagService, viewUtils) {
    var sortTagGroupColumns = function(tagGroupColumns) {
        tagGroupColumns.forEach(function(column) {
            column.items.sortAlphabetically('name');
        });
        tagGroupColumns.sort(function(a, b) {
            if (a.items[0].name > b.items[0].name) {
                return 1;
            }
            if (a.items[0].name < b.items[0].name) {
                return -1;
            }
            return 0;
        });
        return tagGroupColumns;
    };

    $scope.applyTagGroups = function() {
        var categoryIds = categoryService.includeSuperCategories($scope.categories, $scope.mod.categories);
        var tagGroups = angular.copy(tagService.categoryTagGroups($rootScope.tagGroups, categoryIds));
        var tagGroupColumns = viewUtils.splitIntoColumns(tagGroups, 3, 'tag_group_tags', 46, 20);
        $scope.tagGroupColumns = sortTagGroupColumns(tagGroupColumns);
    };

    $scope.findTagGroupTag = function(tagText) {
        for (var i = 0; i < $scope.tagGroupColumns.length; i++) {
            var column = $scope.tagGroupColumns[i];
            for (var j = 0;  j < column.items.length; j++) {
                var group = column.items[j];
                for (var k = 0; k < group.tag_group_tags.length; k++) {
                    var tagGroupTag = group.tag_group_tags[k];
                    if (tagGroupTag.tag_text === tagText) {
                        return tagGroupTag;
                    }
                }
            }
        }
    };

    $scope.toggleTagGroupTag = function(tagText, enabled) {
        var tagGroupTag = $scope.findTagGroupTag(tagText);
        if (tagGroupTag) {
            tagGroupTag.enabled = enabled;
            return true;
        }
    };

    $scope.toggleTag = function(tag) {
        if (tag.enabled) {
            $scope.$broadcast('addTag', tag.tag_text);
        } else {
            $scope.$broadcast('removeTag', tag.tag_text);
        }
    };

    $scope.loadTagGroupTags = function() {
        $scope.mod.tags.forEach(function(tag) {
            $scope.toggleTagGroupTag(tag.text, true)
        });
    };

    // category management
    $scope.$watch('mod.categories', function() {
        // clear messages when user changes the category
        if ($scope.categoryMessages && $scope.categoryMessages.length) {
            if ($scope.categoryMessages[0].klass == "cat-error-message" ||
                $scope.categoryMessages[0].klass == "cat-success-message") {
                $scope.categoryMessages = [];
            }
        }

        // set primary_category_id and secondary_category_id
        $scope.mod.primary_category_id = $scope.mod.categories[0];
        $scope.mod.secondary_category_id = $scope.mod.categories[1];

        // apply tag groups
        $scope.applyTagGroups();
        $scope.loadTagGroupTags();
    }, true);

    // tag group management
    $scope.$on('tagAdded', function(tagText) {
        $scope.toggleTagGroupTag(tagText, true);
    });

    $scope.$on('tagRemoved', function(tagText) {
        $scope.toggleTagGroupTag(tagText, false);
    });
});
