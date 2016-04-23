//TODO: maybe we should think about splitting the logic to retrieve all the data and filtering it.
app.service('categoryService', function ($q, backend) {

    function retrieveFilteredCategories(key) {
        var categoryPromise = $q.defer();

        backend.retrieve('/categories', {cache: true}).then(function (data) {
            var returnData = [];
            data.forEach(function (category) {
                if (key === 'primary' ? !category.parent_id : category.parent_id == key) {
                    returnData.push(category);
                }
            });
            returnData.sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
            categoryPromise.resolve(returnData);
        });

        return categoryPromise.promise;
    }

    this.retrievePrimaryCategory = function () {
        //TODO: we shall have an empty key for the primary Category
        return retrieveFilteredCategories('primary');
    };

    this.retrieveSecondaryCategory = function (primaryCategoryId) {
        return retrieveFilteredCategories(primaryCategoryId);
    };

    this.retrieveNestedCategories = function () {
        var nestedCategories = [];
        var secondaryCategoryPromises = [];
        var nestedCategoriesPromise = $q.defer();
        retrieveFilteredCategories('primary').then(function (primaryCategories) {
            primaryCategories.forEach(function (primaryCategory) {
                secondaryCategoryPromises.push(retrieveFilteredCategories(primaryCategory.id).then(function (secondaryCategories) {
                    primaryCategory.childs = secondaryCategories;
                    nestedCategories.push(primaryCategory);
                }));
            });
            $q.all(secondaryCategoryPromises).then(function () {
                nestedCategoriesPromise.resolve(nestedCategories);
            });
        });
        return nestedCategoriesPromise.promise;
    };

    this.getCategoryById = function(inputId) {
        var categoryPromise = $q.defer();

        backend.retrieve('/categories', {cache: true}).then(function (data) {
            var returnData = [];
            data.forEach(function (category) {
                if (inputId === category.id) {
                    returnData = category;
                }
            });
            categoryPromise.resolve(returnData);
        });

        return categoryPromise.promise;
    };
});
