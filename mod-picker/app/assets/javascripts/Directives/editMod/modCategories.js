app.directive('modCategories', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modCategories.html',
        scope: false,
        controller: 'modCategoriesController'
    }
});

app.controller('modCategoriesController', function($scope, categoryService, objectUtils) {
    $scope.getDominantIds = function(recessiveId) {
        var dominantIds = [];
        for (var i = 0; i < $scope.categoryPriorities.length; i++) {
            var priority = $scope.categoryPriorities[i];
            if (priority.recessive_id == recessiveId) {
                dominantIds.push(priority.dominant_id);
            }
        }
        return dominantIds;
    };

    $scope.getCategoryPriority = function(recessiveId, dominantId) {
        for (var i = 0; i < $scope.categoryPriorities.length; i++) {
            var priority = $scope.categoryPriorities[i];
            if (priority.recessive_id == recessiveId &&
                priority.dominant_id == dominantId)
                return priority;
        }
    };

    $scope.createPriorityMessage = function(recessiveId, dominantId) {
        var recessiveCategory = categoryService.getCategoryById($scope.categories, recessiveId);
        var dominantCategory = categoryService.getCategoryById($scope.categories, dominantId);
        var categoryPriority = $scope.getCategoryPriority(recessiveId, dominantId);
        var messageText = dominantCategory.name + " > " + recessiveCategory.name + "\n" + categoryPriority.description;
        $scope.categoryMessages.push({
            text: messageText,
            klass: "cat-warning-message"
        });
    };

    $scope.getCategory = function(categoryId) {
        return categoryService.getCategoryById($scope.categories, categoryId);
    };

    $scope.getPrimaryCategory = function() {
        if ($scope.mod.categories.length < 1) return;
        return categoryService.getCategoryById($scope.categories, $scope.mod.categories[0]);
    };

    $scope.getSecondaryCategory = function() {
        if ($scope.mod.categories.length < 2) return;
        return categoryService.getCategoryById($scope.categories, $scope.mod.categories[1]);
    };

    $scope.getSuperCategories = function() {
        var superCategories = [];
        $scope.mod.categories.forEach(function(id) {
            var superCategory = categoryService.getCategoryById($scope.categories, id).parent_id;
            if (superCategory && superCategories.indexOf(superCategory) == -1) {
                superCategories.push(superCategory);
            }
        });
        return superCategories;
    };

    $scope.checkCategoryPriorities = function() {
        var selectedCategories = Array.prototype.concat($scope.getSuperCategories(), $scope.mod.categories);
        selectedCategories.forEach(function(recessiveId) {
            var dominantIds = $scope.getDominantIds(recessiveId);
            dominantIds.forEach(function(dominantId) {
                var index = selectedCategories.indexOf(dominantId);
                if (index > -1) $scope.createPriorityMessage(recessiveId, dominantId);
            });
        });
    };

    $scope.checkTooManyCategories = function() {
        if ($scope.mod.categories.length <= 2) return;
        $scope.categoryMessages.push({
            text: "You have too many categories selected. \nThe maximum number of categories allowed is 2.",
            klass: "cat-error-message"
        });
    };

    $scope.checkNoCategories = function() {
        if ($scope.mod.categories.length > 0) return;
        $scope.categoryMessages.push({
            text: "You must select at least one category.",
            klass: "cat-error-message"
        });
    };

    $scope.checkMultipleSubInSuper = function() {
        if ($scope.mod.categories.length < 2) return;
        var categories = $scope.mod.categories.map($scope.getCategory);
        var parentGroups = categories.groupBy('parent_id');
        parentGroups = objectUtils.removeProperties(parentGroups, function(property, value) {
            return value.length < 2;
        });
        for (var prop in parentGroups) {
            if (!parentGroups.hasOwnProperty(prop)) continue;
            var parentCategory = $scope.getCategory(parseInt(prop));
            $scope.categoryMessages.push({
                text: "You checked multiple categories in "+parentCategory.name+". Consider checking the parent category instead.",
                klass: "cat-warning-message"
            });
        }
    };

    $scope.checkSuperAndSub = function() {
        if ($scope.mod.categories.length < 2) return;
        var categories = $scope.mod.categories.map($scope.getCategory);
        categories.forEach(function(category) {
            if ($scope.mod.categories.indexOf(category.parent_id) == -1) return;
            var parentCategory = $scope.getCategory(category.parent_id);
            $scope.categoryMessages.push({
                text: "You checked "+category.name+" and its parent category "+parentCategory.name + ". Please uncheck the parent category.",
                klass: "cat-warning-message"
            });
        });
    };

    $scope.categoriesLookGood = function() {
        if ($scope.categoryMessages.length == 0) {
            $scope.categoryMessages.push({
                text: "Categories look good!",
                klass: "cat-success-message"
            });
            $scope.categoryMessages.push({
                text: "Primary Category: " + $scope.getPrimaryCategory().name,
                klass: "cat-success-message"
            });
            if ($scope.mod.categories.length > 1) {
                $scope.categoryMessages.push({
                    text: "Secondary Category: " + $scope.getSecondaryCategory().name,
                    klass: "cat-success-message"
                });
            }
        }
    };

    $scope.checkCategories = function() {
        $scope.categoryMessages = [];
        $scope.checkCategoryPriorities();
        $scope.checkTooManyCategories();
        $scope.checkNoCategories();
        $scope.checkMultipleSubInSuper();
        $scope.checkSuperAndSub();
        $scope.categoriesLookGood();
    };

    $scope.swapCategories = function() {
        $scope.mod.categories.reverse();
    };
});