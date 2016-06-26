//TODO: maybe we should think about splitting the logic to retrieve all the data and filtering it.
app.service('categoryService', function ($q, backend) {
    var service = this;

    this.retrieveCategories = function() {
        return backend.retrieve('/categories', {cache: true});
    };

    function retrieveFilteredCategories(key) {
        var categories = $q.defer();

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
            categories.resolve(returnData);
        });

        return categories.promise;
    }

    this.retrieveCategoryPriorities = function() {
        return backend.retrieve('/category_priorities');
    };

    //storing all categories in a variable
    var allCategories = this.retrieveCategories();

    this.getCategoryById = function (id) {
      var category = $q.defer();

      allCategories.then(function (categories) {
        category.resolve(categories.find(function (data) {
          return data.id === id;
        }));
      });
      return category.promise;
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
                nestedCategoriesPromise.resolve(nestedCategories);
            });
        });
        return nestedCategoriesPromise.promise;
    };

    this.resolveModCategories = function(mod) {
        if (mod.primary_category_id) {
            service.getCategoryById(mod.primary_category_id).then(function (primaryCategory) {
                mod.primary_category = primaryCategory;
            });
        }

        if (mod.secondary_category_id) {
            service.getCategoryById(mod.secondary_category_id).then(function(secondaryCategory) {
                mod.secondary_category = secondaryCategory;
            });
        }
    };
});
