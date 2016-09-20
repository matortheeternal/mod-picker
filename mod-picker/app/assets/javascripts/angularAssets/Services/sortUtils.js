app.service('sortUtils', function ($q, categoryService, colorsFactory, modListService) {

    this.prepareToSort = function(mod_list, key) {
        var customKey = 'custom_' + key;
        var prepareItem = function(item) {
            item.group_id = null;
            if (item.merged) item.merged = false;
        };
        mod_list[key].forEach(prepareItem);
        mod_list[customKey].forEach(prepareItem);
        mod_list.groups.forEach(function(group) {
            if (group.tab === key) {
                group._destroy = true;
            }
        });
    };

    this.buildGroups = function(mod_list, key) {
        // initial groups for official content and ESMs
        var groups = [{
            mod_list_id: mod_list.id,
            index: 0,
            tab: key,
            color: 'white',
            name: 'Official Content',
            priority: 0,
            children: []
        }];

        var handlingPlugins = key === 'plugins';
        if (handlingPlugins) {
            groups.push({
                mod_list_id: mod_list.id,
                index: 1,
                tab: key,
                color: colorsFactory.randomColor(),
                name: 'ESMs',
                priority: 1,
                children: []
            });
        }

        // sort items into groups
        mod_list[key].forEach(function(item) {
            var mod = item.mod;
            var plugin = item.plugin;
            var foundGroup;

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
                // add item to existing category group if it exists
                var primaryCategory = angular.copy(mod.primary_category);
                foundGroup = groups.find(function(group) {
                    return group.category && group.category.id == primaryCategory.id;
                });
                if (foundGroup) {
                    foundGroup.children.push(item);
                }
                // else create new group for the category
                else {
                    groups.push({
                        mod_list_id: mod_list.id,
                        tab: key,
                        color: colorsFactory.randomColor(),
                        name: primaryCategory.name,
                        priority: primaryCategory.priority,
                        category: primaryCategory,
                        children: [item]
                    });
                }
            }
        });

        // put custom items in a group at the end
        var customKey = 'custom_'+key;
        groups.push({
            mod_list_id: mod_list.id,
            index: 9999,
            tab: key,
            color: colorsFactory.randomColor(),
            name: 'Custom '+key.capitalize(),
            priority: 255,
            children: mod_list[customKey]
        });

        // return the groups we built
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
            group.children.sort(function(a, b) {
                return a[key][innerKey] - b[key][innerKey];
            });
        });
    };

    this.combineGroups = function(mod_list, key, groups, categoryStore) {
        for (var i = groups.length - 1; i >= 0; i--) {
            var group = groups[i];
            var category = group.category;
            // skip groups that don't correspond to a category
            if (!category) continue;

            var superId = category.parent_id;
            // skip groups that are for supercategories or that have more than 5 members
            if (!superId || group.children.length >= 5) continue;

            var superGroup = groups.find(function(group) {
                return group.category && group.category.id == superId;
            });
            if (superGroup) {
                // skip if super category is not within 10 priority of category
                if (Math.abs(superGroup.priority - category.priority) > 10) continue;
                superGroup.children.unite(group.children);
            } else {
                var superCategory = categoryService.getCategoryById(categoryStore, superId);
                // skip if super category is not within 10 priority of category
                if (Math.abs(superCategory.priority - category.priority) > 10) continue;
                groups.push({
                    mod_list_id: mod_list.id,
                    tab: key,
                    color: colorsFactory.randomColor(),
                    name: superCategory.name,
                    priority: superCategory.priority,
                    category: superCategory,
                    children: group.children
                });
            }

            // splice the subcategory group out
            groups.splice(i, 1);
        }
    };

    this.saveGroups = function(groups, model, key, mod_list, originalModList) {
        model[key] = [];
        var groupPromises = [];
        groups.forEach(function(group) {
            // skip empty groups
            if (!group.children.length) return;

            // prepare promise for tracking purposes
            var action = $q.defer();
            var groupItem = {
                mod_list_id: group.mod_list_id,
                index: group.index,
                tab: group.tab,
                color: group.color,
                name: group.name,
                description: group.description
            };

            // tell the server to create the new mod list group
            modListService.newModListGroup(groupItem).then(function(data) {
                var newGroup = data;
                newGroup.children = [];

                // associate children with the new group object
                group.children.forEach(function(child) {
                    child.group_id = data.id;
                    newGroup.children.push(child);
                });

                // push the new group object onto the view model
                mod_list.groups.push(newGroup);
                originalModList.groups.push(angular.copy(newGroup));
                model[key].push(newGroup);
                action.resolve(newGroup);
            }, function(response) {
                action.reject(response);
            });

            // push the promise onto the groupPromises array
            groupPromises.push(action.promise);
        });

        return groupPromises;
    }
});