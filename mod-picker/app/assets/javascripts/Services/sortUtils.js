app.service('sortUtils', function($q, categoryService, colorsFactory, modListService, objectUtils) {
    var service = this;
    var mod_list, key, handlingPlugins, model, originalModList;

    /* === HELPER FUNCTIONS === */
    this.officialContentGroup = function() {
        return {
            mod_list_id: mod_list.id,
            index: 0,
            tab: key,
            color: 'white',
            name: 'Official Content',
            priority: 0,
            children: []
        }
    };

    this.esmGroup = function() {
        return {
            mod_list_id: mod_list.id,
            index: 1,
            tab: key,
            color: colorsFactory.randomColor(),
            name: 'ESMs',
            priority: 1,
            children: []
        }
    };

    this.newCategoryGroup = function(category) {
        return {
            mod_list_id: mod_list.id,
            tab: key,
            color: colorsFactory.randomColor(),
            name: category.name,
            priority: category.priority,
            category: category,
            children: []
        };
    };

    this.getCategoryGroup = function(groups, category) {
        var group = groups.find(function(group) {
            return group.category && group.category.id == category.id;
        });
        if (!group) {
            group = service.newCategoryGroup(category);
            groups.push(group);
        }
        return group;
    };

    this.newCustomGroup = function() {
        var customKey = 'custom_' + key;
        return {
            mod_list_id: mod_list.id,
            index: 9999,
            tab: key,
            color: colorsFactory.randomColor(),
            name: 'Custom '+key.capitalize(),
            priority: 255,
            children: mod_list[customKey].filter(function(customItem) {
                return !customItem.group_id;
            })
        }
    };

    this.setSortTarget = function(target_mod_list, target_key) {
        mod_list = target_mod_list;
        key = target_key;
        handlingPlugins = key === "plugins";
    };

    this.prepareItem = function(item) {
        if (item.group_id) {
            var group = mod_list.groups.find(function(group) {
                return group.id == item.group_id;
            });
            if (!group.keep_when_sorting) {
                item.group_id = null;
                if (item.merged) item.merged = false;
            }
        } else if (item.merged) {
            item.merged = false;
        }
    };

    this.prepareGroup = function(group) {
        if (group.tab === key && !group.keep_when_sorting) {
            group._destroy = true;
        }
    };

    this.sortItem = function(item, groups) {
        var mod = item.mod;
        var plugin = item.plugin;

        // items from official mods go into the Official Content group
        if (mod.is_official) {
            groups[0].children.push(item);
        }
        // non-official ESMs go into the ESMs group
        else if (handlingPlugins && plugin.filename.endsWith('.esm')) {
            // TODO: Check ESM flag instead once we have it
            groups[1].children.push(item);
        }
        // for everything else we create groups based on the primary category of the mod
        else {
            var primaryCategory = angular.copy(mod.primary_category);
            var group = service.getCategoryGroup(groups, primaryCategory);
            group.children.push(item);
        }
    };

    this.sortGroup = function(group, groups) {
        group.index = 9998;
        group.priority = 254;
        group.children = mod_list[key].filter(function(item) {
            return item.group_id == group.id;
        });
        groups.push(group);
    };


    this.getSuperGroup = function(groups, category, categoryStore) {
        var superId = category.parent_id;
        var superGroup = groups.find(function(group) {
            return group.category && group.category.id == superId;
        });
        if (!superGroup) {
            var superCategory = categoryService.getCategoryById(categoryStore, superId);
            superGroup = service.newCategoryGroup(superCategory);
            groups.push(superGroup);
        }
        return superGroup;
    };

    this.sanitizeGroup = function(group) {
        return {
            mod_list_id: group.mod_list_id,
            index: group.index,
            tab: group.tab,
            color: group.color,
            name: group.name,
            description: group.description
        }
    };

    this.associateChildren = function(group, newGroup) {
        newGroup.children = [];
        group.children.forEach(function(child) {
            child.group_id = newGroup.id;
            newGroup.children.push(child);
        });
    };

    this.addGroupToView = function(newGroup) {
        mod_list.groups.push(newGroup);
        originalModList.groups.push(angular.copy(newGroup));
        model[key].push(newGroup);
    };

    this.saveGroup = function(group) {
        var action = $q.defer();
        var groupItem = service.sanitizeGroup(group);

        // tell the server to create the new mod list group
        modListService.newModListGroup(groupItem).then(function(newGroup) {
            service.associateChildren(group, newGroup);
            service.addGroupToView(newGroup);
            action.resolve(newGroup);
        }, function(response) {
            action.reject(response);
        });

        return action;
    };

    /* === PUBLIC API === */

    // prepares mod list items for sorting by flattening them and
    // removing merged marks
    this.prepareToSort = function() {
        var customKey = 'custom_' + key;
        mod_list[key].forEach(service.prepareItem);
        mod_list[customKey].forEach(service.prepareItem);
        mod_list.groups.forEach(service.prepareGroup);
    };

    this.buildGroups = function() {
        // initial groups for official content and ESMs
        var groups = [service.officialContentGroup()];
        if (key === 'plugins') groups.push(service.esmGroup());

        // sort items into groups
        mod_list[key].forEach(function(item) {
            if (item.group_id) return;
            service.sortItem(item, groups);
        });

        // push preserved groups onto groups
        mod_list.groups.forEach(function(group) {
            service.sortGroup(group, groups);
        });

        // put custom items in a group at the end
        groups.push(service.newCustomGroup());
        return groups;
    };

    this.sortGroupsByPriority = function(groups) {
        groups.sort(function(a, b) {
            return a.priority - b.priority;
        });
    };

    this.sortItems = function(groups, key, innerKey) {
        // we slice the first off because we don't want to sort official content
        // we slice the last off because we don't want to sort custom content
        groups.slice(1, groups.length - 1).forEach(function(group) {
            if (group.keep_when_sorting) return;
            group.children && group.children.sort(function(a, b) {
                return b[key][innerKey] - a[key][innerKey];
            });
        });
    };

    this.combineGroups = function(groups, categoryStore) {
        for (var i = groups.length - 1; i >= 0; i--) {
            var group = groups[i];
            var category = group.category;

            // skip groups that don't correspond to a category, are for
            // supercategories, or have fewer than 5 children
            if (!category || !category.parent_id || group.children.length >= 5) continue;

            // skip if super category is not within 10 priority of category
            var superGroup = service.getSuperGroup(groups, category, categoryStore);
            if (Math.abs(superGroup.priority - category.priority) > 10) continue;
            superGroup.children.unite(group.children);

            // splice the subcategory group out
            groups.splice(i, 1);
        }
    };

    this.setSaveTarget = function(target_model, target_original) {
        model = target_model;
        originalModList = target_original;
    };

    this.saveGroups = function(groups) {
        model[key] = [];
        var groupPromises = [];
        groups.forEach(function(group) {
            if (group.keep_when_sorting) {
                model[key].push(group);
                return;
            }
            if (!group.children.length) return; // skip empty groups
            var action = service.saveGroup(group);
            groupPromises.push(action.promise);
        });

        return groupPromises;
    };

    this.sortModel = function() {
        model[key].sort(function(a, b) {
            return a.index - b.index;
        });
    }

    // load sort into view
    this.loadSort = function(columns, sortedColumn, sort) {
        columns.forEach(function(column) {
            if (service.getSortData(column) === sort.column) {
                var sortKey = sort.direction === "ASC" ? "up" : "down";
                column[sortKey] = true;
                sortedColumn = column;
            }
        });
    };

    // get the sort data key for a column
    this.getSortData = function(column) {
        return column.sortData || (typeof column.data === "string" ? column.data : objectUtils.csv(column.data));
    };
});