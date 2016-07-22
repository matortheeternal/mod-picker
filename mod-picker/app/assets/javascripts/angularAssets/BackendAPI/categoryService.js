//TODO: maybe we should think about splitting the logic to retrieve all the data and filtering it.
app.service('categoryService', function ($q, backend) {
    var service = this;
    var allCategories;

    this.retrieveCategories = function() {
        return allCategories;
    };

    //storing all categories in a variable
    allCategories = backend.retrieve('/categories', {cache: true});

    function retrieveFilteredCategories(key) {
        var categories = $q.defer();

        allCategories.then(function (data) {
            var returnData = [];
            data.forEach(function (category) {
                if (key === 'primary' ? !category.parent_id : category.parent_id == key) {
                    returnData.push(category);
                }
            });
            returnData.sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
            categories.resolve(returnData);
        });

        return categories.promise;
    }

    this.retrieveCategoryPriorities = function() {
        return backend.retrieve('/category_priorities');
    };

    this.getCategoryById = function (categories, id) {
        return categories.find(function (category) {
          return category.id === id;
        });
    };

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
                nestedCategoriesPromise.resolve(angular.copy(nestedCategories));
            });
        });
        return nestedCategoriesPromise.promise;
    };

    this.resolveModCategories = function(mod) {
        allCategories.then(function(categories) {
            if (mod.primary_category_id) {
                mod.primary_category =  service.getCategoryById(categories, mod.primary_category_id);
            }

            if (mod.secondary_category_id) {
                mod.secondary_category = service.getCategoryById(categories, mod.secondary_category_id);
            }
        });
    };
});
