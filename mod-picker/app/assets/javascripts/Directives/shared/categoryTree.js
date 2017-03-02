app.directive('categoryTree', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/categoryTree.html',
        controller: 'categoryTreeController',
        transclude: true,
        scope: {
            categories: '=',
            selection: '=',
            toggleAll: '=',
            changeCallback: '&onChange'
        }
    }
});

app.controller('categoryTreeController', function($scope, categoryService) {
    // default scope attributes
    angular.default($scope, 'selection', []);

    //
    $scope.$watch('selection', function() {
        $scope.changeCallback();
    }, true);

    $scope.findCategoryIndexes = function(category_id) {
        for (var i = 0; i < $scope.nestedCategories.length; i++) {
            var category = $scope.nestedCategories[i];
            if (category.id == category_id) {
                return { primary: category, secondary: null };
            }
            for (var j = 0; j < category.childs.length; j++) {
                var childCategory = category.childs[j];
                if (childCategory.id == category_id) {
                    return { primary: category, secondary: childCategory };
                }
            }
        }
    };

    // prepare nested categories
    $scope.nestedCategories = categoryService.nestCategories($scope.categories);

    // add checkbox values to data and fix subcategory names
    $scope.nestedCategories.forEach(function(superCategory) {
        superCategory.value = false;
        superCategory.childs.forEach(function(subCategory) {
            if (subCategory.name.indexOf('- ') > -1) {
                subCategory.name = subCategory.name.split('- ')[1];
            }
            subCategory.value = false;
        });
    });

    // load selection into view
    $scope.selection.forEach(function(category_id) {
        var category = $scope.findCategoryIndexes(category_id);
        if (category) {
            if (category.secondary) {
                category.secondary.value = true;
                if (!category.primary.value) {
                    category.primary.indeterminate = true;
                }
            } else {
                category.primary.value = true;
                category.primary.indeterminate = false;
            }
        }
    });

    $scope.handleSelection = function(target) {
        if (target.value) {
            // handle addition to selection
            $scope.selection.push(target.id);
        } else {
            // handle removal from selection
            var index = $scope.selection.indexOf(target.id);
            if (index > -1) {
                $scope.selection.splice(index, 1);
            }
        }
    };

    $scope.updateSelection = function(primaryCategory, secondaryCategory) {
        var parent = $scope.nestedCategories[primaryCategory];
        // only allow checking of all childs if the parent is unchecked
        var allChecked = !parent.value;
        // only allow unchecking of all childs if the parent is checked
        var allUnchecked = parent.value;
        // evaluate whether or not all are unchecked in after user input
        var allUncheckedAfter = true;
        // evaluate if all childs are checked or unchecked
        parent.childs.forEach(function(child) {
            allUnchecked = allUnchecked && !child.value;
            allUncheckedAfter = allUncheckedAfter && (!child.value || child.name === secondaryCategory);
            allChecked = allChecked && child.value;
        });
        // all will be unchecked after the action if the user clicked the
        // primary category and all children are checked
        allUncheckedAfter = allUncheckedAfter || (allChecked && secondaryCategory == null);

        // handle selection of parent or child
        if (secondaryCategory == null) {
            $scope.handleSelection(parent);
            // toggle all childs if allowed
            // if all childs are unchecked, check all of them
            // if all childs are checked, uncheck all of them
            if ($scope.toggleAll && (allChecked || allUnchecked)) {
                parent.childs.forEach(function(child) {
                    child.value = !child.value;
                    $scope.handleSelection(child);
                });
            }
        } else {
            var child = parent.childs[secondaryCategory];
            $scope.handleSelection(child);
        }

        // parent is indeterminate if some childs are checked
        // and the parent is not checked
        parent.indeterminate = !(allUncheckedAfter || parent.value);
    };

    $scope.clearSelection = function() {
        $scope.nestedCategories.forEach(function(superCategory) {
            superCategory.value = false;
            superCategory.indeterminate = false;
            superCategory.childs.forEach(function(child) {
                child.value = false;
            });
        });
        $scope.selection = [];
    };

    $scope.invertSelection = function() {
        $scope.nestedCategories.forEach(function(superCategory) {
            superCategory.value = !superCategory.value;
            $scope.handleSelection(superCategory);
            superCategory.childs.forEach(function(child) {
                child.value = !child.value;
                $scope.handleSelection(child);
            });
        });
    };
});
