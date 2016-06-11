//TODO: maybe we should think about splitting the logic to retrieve all the data and filtering it.
app.service('categoryService', function ($q, backend) {

    this.retrieveCategories = function() {
        return backend.retrieve('/categories', {cache: true});
    };

    function retrieveFilteredCategories(key) {
        var categories = $q.defer();

        try {
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
        } catch (errors) {
        	throw errors;
        }

        return categories.promise;
    }

    this.retrieveCategoryPriorities = function() {
        try {
        	return backend.retrieve('/category_priorities');
        } catch (errors) {
        	throw errors;
        }
    };

    //storing all categories in a variable
    var allCategories = this.retrieveCategories();

    this.getCategoryById = function (id) {
      var output = $q.defer();

      allCategories.then(function (categories) {
        output.resolve(categories.find(function (category) {
          return category.id === id;
        }));
      });
      return output.promise;
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
});
