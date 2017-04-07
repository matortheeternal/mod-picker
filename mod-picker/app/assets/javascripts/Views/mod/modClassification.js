app.controller('modClassificationController', function($scope, $rootScope, categoryService, tagService, viewUtils) {
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

    // apply tag groups
    $scope.applyTagGroups();

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
    }, true);
});
