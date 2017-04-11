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

    $scope.buildTagsMap = function(tagGroups) {
        $scope.tagsMap = {};
        tagGroups.forEach(function(group) {
            group.tag_group_tags.forEach(function(tag) {
                $scope.tagsMap[tag.tag_text] = tag;
            });
        });
    };

    $scope.applyTagGroups = function() {
        var categoryIds = categoryService.includeSuperCategories($scope.categories, $scope.mod.categories);
        var tagGroups = angular.copy(tagService.categoryTagGroups($rootScope.tagGroups, categoryIds));
        var tagGroupColumns = viewUtils.splitIntoColumns(tagGroups, 3, 'tag_group_tags', 46, 20);
        $scope.buildTagsMap(tagGroups);
        $scope.tagGroupColumns = sortTagGroupColumns(tagGroupColumns);
    };

    $scope.toggleTagGroupTag = function(tagText, enabled) {
        if ($scope.tagsMap.hasOwnProperty(tagText)) {
            $scope.tagsMap[tagText].enabled = enabled;
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
    $scope.$on('tagAdded', function(event, tagText) {
        $scope.toggleTagGroupTag(tagText, true);
    });

    $scope.$on('tagRemoved', function(event, tagText) {
        $scope.toggleTagGroupTag(tagText, false);
    });
});
