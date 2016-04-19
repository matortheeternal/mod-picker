app.directive('categoryTree', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/categoryTree.html',
        controller: 'categoryTreeController',
        scope: {
            model: '=',
            required: '=',
            toggleAll: '='
        }
    }
});

app.controller('categoryTreeController', function ($scope, categoryService) {
    categoryService.retrieveNestedCategories().then(function (data) {
        var categoryFilter = $scope.categoryFilter = [];
        data.forEach(function (superCategory) {
            categoryFilter[superCategory.id] = {childs: []};
            categoryFilter[superCategory.id].value = false;
            superCategory.childs.forEach(function (subCategory) {
                subCategory.name = subCategory.name.split('- ')[1];
                categoryFilter[superCategory.id].childs[subCategory.id]= {
                    value: false,
                    name: subCategory.name
                }
            });
        });
        $scope.categories = data;
    });

    $scope.updateSelection = function (primaryCategory, secondaryCategory) {
        var parent = $scope.categoryFilter[primaryCategory];
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

        // toggle all childs if allowed
        if ($scope.toggleAll && !secondaryCategory) {
            // if all childs are unchecked, check all of them
            // if all childs are checked, uncheck all of them
            if (allChecked || allUnchecked) {
                parent.childs.forEach(function (child) {
                    child.value = !child.value;
                });
            }
        }

        // parent is indeterminate if some childs are checked
        // and the parent is not checked
        parent.indeterminate = !(allUncheckedAfter || parent.value);
    };

    $scope.clearSelection = function () {
        $scope.categoryFilter.forEach(function (superCategory) {
            superCategory.value = false;
            superCategory.indeterminate = false;
            superCategory.childs.forEach(function (child) {
                child.value = false;
            });
        });
    };

    $scope.invertSelection = function () {
        $scope.categoryFilter.forEach(function (superCategory) {
            superCategory.value = !superCategory.value;
            superCategory.childs.forEach(function(child) {
                child.value = !child.value;
            });
        });
    };
});