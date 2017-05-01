app.service('categoryService', function($q, backend) {
    var service = this;

    this.retrieveCategories = function() {
        return backend.retrieve('/categories', {cache: true});
    };

    this.retrieveCategoryChart = function() {
        return backend.retrieve('/categories/chart', {cache: true});
    };

    this.filterCategories = function(categories, key) {
        var filteredCategories = categories.filter(function(category) {
            return category.parent_id == key;
        });
        filteredCategories.sort(function(a, b) {
            return a.name.localeCompare(b.name);
        });
        return filteredCategories;
    };

    this.retrieveCategoryPriorities = function() {
        return backend.retrieve('/category_priorities');
    };

    this.getCategoryById = function(categories, id) {
        return categories.find(function(category) {
          return category.id === id;
        });
    };

    this.includeSuperCategories = function(categories, ids) {
        var a = angular.copy(ids);
        ids.forEach(function(id) {
            var category = service.getCategoryById(categories, id);
            if (category.parent_id) {
                a.push(category.parent_id);
            }
        });
        return a;
    };

    this.getCategoryByName = function(categories, categoryName) {
        return categories.find(function(category) {
            return category.name === categoryName;
        });
    };

    this.getCategoryTree = function(categories) {
        var primaryCategories = angular.copy(service.filterCategories(categories));
        primaryCategories.forEach(function(primaryCategory) {
            primaryCategory.childs = angular.copy(service.filterCategories(categories, primaryCategory.id));
        });
        return primaryCategories;
    };

    this.removeSuperCategoryNames = function(categories) {
        categories.forEach(function(category) {
            if (category.name.indexOf('- ') > -1) {
                category.name = category.name.split('- ')[1];
            }
        });
    };

    this.resolveModCategories = function(categories, mod) {
        if (mod.primary_category_id) {
            mod.primary_category =  service.getCategoryById(categories, mod.primary_category_id);
        }

        if (mod.secondary_category_id) {
            mod.secondary_category = service.getCategoryById(categories, mod.secondary_category_id);
        }
    };

    this.associateCategories = function(categories, data) {
        data.forEach(function(item) {
            item.mod && service.resolveModCategories(categories, item.mod);
        });
    };

    this.associateTagGroupCategories = function(categories, tagGroups) {
        tagGroups.forEach(function(tagGroup) {
            tagGroup.category = service.getCategoryById(categories, tagGroup.category_id);
        });
    }
});
