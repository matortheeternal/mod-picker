app.directive('categoryTree', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/categoryTree.html',
        controller: 'categoryTreeController',
        scope: {
            selection: '=',
            toggleAll: '='
        }
    }
});

app.controller('categoryTreeController', function ($scope, categoryService) {
    categoryService.retrieveNestedCategories().then(function (data) {
        $scope.categories = data;
        // add checkbox values to data and fix subcategory names
        $scope.categories.forEach(function(superCategory) {
            superCategory.value = false;
            superCategory.childs.forEach(function(subCategory) {
                subCategory.name = subCategory.name.split('- ')[1];
                subCategory.value = false;
            });
        });
    });

    $scope.handleSelection = function (target, before) {
        if (target.value || before) {
            // handle addition to selection
            $scope.selection.push(target.name);
        } else {
            // handle removal from selection
            var index = $scope.selection.indexOf(target.name);
            if (index > -1) {
                $scope.selection.splice(index, 1);
            }
        }
    };

    $scope.updateSelection = function (primaryCategory, secondaryCategory) {
        var parent = $scope.categories[primaryCategory];
        // only allow checking of all childs if the parent is unchecked
        var allChecked = !parent.value;
        // only allow unchecking of all childs if the parent is checked
        var allUnchecked = parent.value;
        // evaluate whether or not all are unchecked in after user input
        var allUncheckedAfter = true;
        // evaluate if all childs are checked or unchecked
        parent.childs.forEach(function (child) {
            allUnchecked = allUnchecked && !child.value;
            allUncheckedAfter = allUncheckedAfter && (!child.value || child.name === secondaryCategory);
            allChecked = allChecked && child.value;
        });
        // all will be unchecked after the action if the user clicked the
        // primary category and all children are checked
        allUncheckedAfter = allUncheckedAfter || (!secondaryCategory && allChecked);

        // handle selection of parent or child
        if (!secondaryCategory) {
            $scope.handleSelection(parent, true);
            // toggle all childs if allowed
            // if all childs are unchecked, check all of them
            // if all childs are checked, uncheck all of them
            if ($scope.toggleAll && (allChecked || allUnchecked)) {
                parent.childs.forEach(function (child) {
                    child.value = !child.value;
                    $scope.handleSelection(child);
                });
            }
        } else {
            var child = $scope.categories[secondaryCategory];
            $scope.handleSelection(child, true);
        }

        // parent is indeterminate if some childs are checked
        // and the parent is not checked
        parent.indeterminate = !(allUncheckedAfter || parent.value);
    };

    $scope.clearSelection = function () {
        $scope.categories.forEach(function (superCategory) {
            superCategory.value = false;
            superCategory.indeterminate = false;
            superCategory.childs.forEach(function (child) {
                child.value = false;
            });
        });
        $scope.selection = [];
    };

    $scope.invertSelection = function () {
        $scope.categories.forEach(function (superCategory) {
            superCategory.value = !superCategory.value;
            superCategory.childs.forEach(function(child) {
                child.value = !child.value;
                $scope.handleSelection(child);
            });
        });
    };
});