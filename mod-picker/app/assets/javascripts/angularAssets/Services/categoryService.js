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
            categoryPromise.resolve(returnData);
        });

        return categoryPromise.promise;
    }

    this.retrievePrimaryCategory = function () {
        return retrieveFilteredCategories('primary');
    };

    this.retrieveSecondaryCategory = function (primaryCategoryId) {
        return retrieveFilteredCategories(primaryCategoryId);
    };
});