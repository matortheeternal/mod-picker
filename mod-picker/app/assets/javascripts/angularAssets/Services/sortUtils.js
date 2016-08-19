app.service('sortUtils', function (categoryService, colorsFactory, baseFactory, objectUtils) {
    var service = this;

    this.prepareToSortPlugins = function(mod_list) {
        var preparePlugin = function(item) {
            item.group_id = null;
            if (item.merged) item.merged = false;
        };
        mod_list.plugins.forEach(preparePlugin);
        mod_list.custom_plugins.forEach(preparePlugin);
        mod_list.groups.forEach(function(group) {
            if (group.tab === 'plugins') {
                group._destroy = true;
            }
        });
    };

    this.updateIndexes = function(groups) {
        var index = 0;
        groups.forEach(function(group) {
            group.index = index;
            group.children.forEach(function(plugin) {
                plugin.index = index++;
            })
        });
    };

    this.findPlugin = function(groups, pluginId, splice) {
        for (var i = 0; i < groups.length; i++) {
            var group = groups[i];
            for (var j = 0; j < group.children.length; j++) {
                var item = group.children[j];
                if (item.plugin.id == pluginId) {
                    return splice ? group.children.splice(j, 1) : item;
                }
            }
        }
    };

    this.movePlugin = function(groups, srcPlugin, dstPlugin, after) {
        var movingPlugin = service.findPlugin(groups, srcPlugin.plugin.id, true);
        for (var i = 0; i < groups.length; i++) {
            var group = groups[i];
            for (var j = 0; j < group.children.length; j++) {
                var item = group.children[j];
                // when we find the destination plugin splice the movingPlugin
                // before or after it and return
                if (item.plugin.id == dstPlugin.plugin.id) {
                    group.children.splice(j + after, 0, movingPlugin);
                    service.updateIndexes(groups);
                    return;
                }
            }
        }
    };

    this.buildPluginGroups = function(mod_list) {
        // initial groups for official content and ESMs
        var groups = [{
            mod_list_id: mod_list.id,
            index: 0,
            tab: 'plugins',
            color: 'white',
            name: 'Official Content',
            priority: 0,
            children: []
        }, {
            mod_list_id: mod_list.id,
            index: 1,
            tab: 'plugins',
            color: colorsFactory.randomColor(),
            name: 'ESMs',
            priority: 1,
            children: []
        }];

        // sort plugins into groups
        mod_list.plugins.forEach(function(item) {
            var mod = item.mod;
            var plugin = item.plugin;
            var foundGroup;

            // plugins from official mods go into the Official Content group
            if (mod.is_official) {
                groups[0].children.push(item);
            }
            // non-official ESMs go into the ESMs group
            else if (plugin.filename.endsWith('.esm')) {
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
                        tab: 'plugins',
                        color: colorsFactory.randomColor(),
                        name: primaryCategory.name,
                        priority: primaryCategory.priority,
                        category: primaryCategory,
                        children: [item]
                    });
                }
            }
        });

        // put custom plugins in a group at the end of the load order
        groups.push({
            mod_list_id: mod_list.id,
            index: 9999,
            tab: 'plugins',
            color: colorsFactory.randomColor(),
            name: 'Custom Plugins',
            priority: 255,
            children: mod_list.custom_plugins
        });

        // return the groups we built
        return groups;
    };

    this.sortGroupsByPriority = function(groups) {
        groups.sort(function(a, b) {
            return a.priority - b.priority;
        });
    };

    this.sortPluginsByOverrides = function(groups) {
        // we slice the first off because we don't want to sort official content
        groups.slice(1, groups.length - 1).forEach(function(group) {
            group.children.sort(function(a, b) {
                return a.override_count - b.override_count;
            });
        });
    };

    this.handleLoadOrderNotes = function(groups, notes) {
        notes.forEach(function(note) {
            var firstPlugin = service.findPlugin(note.plugins[0].id);
            var secondPlugin = service.findPlugin(note.plugins[0].id);
            if (firstPlugin && secondPlugin && firstPlugin.index > secondPlugin.index) {
                service.movePlugin(groups, firstPlugin, secondPlugin);
            }
        });
    };

    this.handleMasterDependencies = function(groups, requirements) {
        requirements.forEach(function(req) {
            var masterPlugin = service.findPlugin(req.master_plugin.id);
            var earliestIndex = 99999, earliestPlugin;
            req.plugins.forEach(function(plugin) {
                var foundPlugin = service.findPlugin(groups, plugin.id);
                if (foundPlugin && foundPlugin.index < earliestIndex) {
                    earliestIndex = foundPlugin.index;
                    earliestPlugin = foundPlugin.plugin;
                }
            });
            if (masterPlugin && earliestPlugin && masterPlugin.index > earliestPlugin.index) {
                service.movePlugin(groups, masterPlugin, earliestPlugin);
            }
        });
    };

    this.combinePluginGroups = function(mod_list, groups, categoryStore) {
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
                    tab: 'plugins',
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
});