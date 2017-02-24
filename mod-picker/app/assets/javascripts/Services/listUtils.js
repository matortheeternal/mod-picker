app.service('listUtils', function() {
    var service = this;

    this.getNextIndex = function(model) {
        if (model.length) {
            var lastItem = model.slice(-1).pop();
            if (lastItem.children && lastItem.children.length) {
                lastItem = lastItem.children.slice(-1).pop();
            }
            return lastItem.index + 1;
        }
        return 1;
    };

    this.findItem = function(model, key, innerKey, itemId, splice) {
        var itemMatches = innerKey ? function(item) {
            return item.hasOwnProperty(key) && item[key][innerKey] == itemId;
        } : function(item) {
            return item[key] == itemId;
        };
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            if (item.children) {
                for (var j = 0; j < item.children.length; j++) {
                    var child = item.children[j];
                    if (itemMatches(child)) {
                        return (splice && item.children.splice(j, 1)[0]) || child;
                    }
                }
            } else {
                if (itemMatches(item)) {
                    return (splice && model.splice(i, 1)[0]) || item;
                }
            }
        }
    };

    this.findMod = function(model, modId, splice) {
        return service.findItem(model, 'mod', 'id', modId, splice);
    };

    this.findPlugin = function(model, pluginId, splice) {
        return service.findItem(model, 'plugin', 'id', pluginId, splice);
    };

    this.findCustomPlugin = function(model, noteId, splice) {
        return service.findItem(model, 'compatibility_note_id', '', noteId, splice);
    };

    this.findConfig = function(model, configId, splice) {
        for (var i = 0; i < model.length; i++) {
            var group = model[i];
            var foundConfig = service.findItem(group.children, 'config_file', 'id', configId, splice);
            if (foundConfig) {
                return foundConfig;
            }
        }
    };

    this.findGroup = function(model, groupId) {
        return model.find(function(item) {
            return item.children && item.id == groupId;
        });
    };

    this.genericFind = function(model, findFunction, itemId, ignoreDestroyed) {
        if (!model) {
            return true;
        }
        var foundItem = findFunction(model, itemId);
        if (foundItem && ignoreDestroyed && foundItem._destroy) {
            return;
        }
        return foundItem;
    };

    this.buildGroups = function(model, groups, tab, items) {
        groups.forEach(function(group) {
            if (group.tab !== tab) return;
            var modelGroup = angular.copy(group);
            modelGroup.dragType = 'group';
            modelGroup.hasChildren = true;
            modelGroup.class = 'group bg-' + modelGroup.color;
            modelGroup.children = items.filter(function(item) {
                return item.group_id == modelGroup.id;
            }).sort(function(a, b) {
                return a.index - b.index;
            });
            model.push(modelGroup);
        });
    };

    this.buildOrphans = function(model, items) {
        items.forEach(function(item) {
            if (item.group_id) return;
            var insertIndex = model.findIndex(function(searchItem) {
                return searchItem.index > item.index;
            });
            if (insertIndex == -1) {
                insertIndex = model.length;
            } else if (item.merged) {
                insertIndex--;
            }
            model.splice(insertIndex, 0, item);
        });
    };

    this.buildModel = function(models, modList, label) {
        models[label] = [];
        var model = models[label];
        var groups = modList.groups;
        var customLabel = 'custom_' + label;
        var items = modList[label].concat(modList[customLabel]);
        service.buildGroups(model, groups, label, items);
        service.buildOrphans(model, items);
    };

    this.forEachItem = function(model, callback) {
        model.forEach(function(item) {
            item.children ? item.children.forEach(callback) : callback(item);
        });
    };

    this.forMatchingItems = function(model, key, value, callback) {
        service.forEachItem(model, function(item) {
            if (item[key] && item[key] == value) callback(item);
        });
    };

    this.forMatching = function(items, key, value, callback) {
        items.forEach(function(item) {
            if (item[key] == value) callback(item);
        });
    };

    this.destroyItem = function(item) {
        item._destroy = true;
    };

    this.recoverItem = function(item) {
        if (item._destroy) delete item._destroy;
    };

    this.removeGroup = function(model, group, index) {
        // handle the group children
        group.children.forEach(function(child) {
            child.group_id = null;
            model.splice(index++, 0, child);
        });
        // destroy the group and clear its children
        group._destroy = true;
        group.children = [];
    };

    this.updateItems = function(model, startingIndex) {
        var i = angular.isUndefined(startingIndex) ? 1 : startingIndex;
        model.forEach(function(item) {
            if (item._destroy) return;
            if (item.children) {
                item.index = i; // group indexing
                item.children.forEach(function(child) {
                    if (child._destroy) return;
                    child.group_id = item.id;
                    child.index = i;
                    // don't increment index if item is marked as merged
                    !child.merged && i++;
                });
            } else {
                item.group_id = null;
                item.index = i;
                // don't increment index if item is marked as merged
                !item.merged && i++;
            }
        });
    };

    // if both items are in the same group, move within the group
    // or if options.insert is true and the destination item is in
    // a group, move the item somewhere inside of the destItem group
    this.getMoveModel = function(model, destItem, moveItem, allowInsert) {
        if (!!moveItem.group_id && moveItem.group_id == destItem.group_id) {
            return service.findGroup(model, moveItem.group_id).children;
        } else if (allowInsert && !!destItem.group_id) {
            return service.findGroup(model, destItem.group_id).children;
        }
        return model;
    };

    // send a cursor down the model until the index of the item we're
    // on exceeds the destItem's index
    // then reinserts the item before or after the found item
    this.insertItem = function(model, destItem, moveItem, after) {
        var newIndex = model.findIndex(function(item) {
            return item.index >= destItem.index;
        });
        model.splice(after ? newIndex + 1 : newIndex, 0, moveItem);
    };

    this.getCanInsert = function(key, moveItem) {
        return key === "plugin" && moveItem.mod.primary_category && moveItem.mod.primary_category.name === "Fixes - Patches";
    };

    this.moveItem = function(model, key, options) {
        // get the destination item
        var innerKey = options.outerId ? null : 'id';
        var destItem = service.findItem(model, key, innerKey, options.destId);
        if (!destItem) {
            return 'Failed to move '+key+', could not find destination '+key+'.';
        }

        // get the item to move and splice it out of the model if found
        var moveItem = service.findItem(model, key, innerKey, options.moveId, true);
        if (!moveItem) {
            return 'Failed to move '+key+', could not find '+key+' to move.';
        }

        // insert the item to move after/before the destination item
        var canInsert = options.forceInsert || service.getCanInsert(key, moveItem);
        var moveModel = service.getMoveModel(model, destItem, moveItem, canInsert);
        service.insertItem(moveModel, destItem, moveItem, options.after);
    };

    this.getDestinationItem = function(model, sourceItem) {
        var index = sourceItem.index;
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            if (item.children) {
                for (var j = 0; j < item.children.length; j++) {
                    var child = item.children[j];
                    if (child == sourceItem) continue;
                    if (child.index == index) return child;
                }
            } else {
                if (item == sourceItem) continue;
                if (item.index == index) return item;
            }
        }
    };

    this.actualIndex = function(model, searchItem) {
        var index = 0;
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            if (item.children) {
                for (var j = 0; j < item.children.length; j++) {
                    var child = item.children[j];
                    index++;
                    if (child == searchItem) return index;
                }
            } else {
                index++;
                if (item == searchItem) return index;
            }
        }
    };

    this.moveItemToNewIndex = function(model, key, sourceItem) {
        var destItem = service.getDestinationItem(model, sourceItem);
        if (!destItem) return false;
        var sourceIndex = service.actualIndex(model, sourceItem);
        var destIndex = service.actualIndex(model, destItem);
        service.moveItem(model, 'id', {
            moveId: sourceItem.id,
            destId: destItem.id,
            after: sourceIndex < destIndex,
            forceInsert: true,
            outerId: true
        });
        return true;
    };

    this.recoverDestroyed = function(model) {
        model.forEach(function(item) {
            if (item._destroy) {
                delete item._destroy;
            }
        });
    };

    this.removeDestroyed = function(model) {
        model.forEach(function(item, index, array) {
            if (item._destroy) {
                array.splice(index, 1);
            }
        });
    };

    this.removeModNotes = function(notes, modId, ignoredCallback) {
        notes.forEach(function(note) {
            if (note.first_mod.id == modId || note.second_mod.id == modId) {
                note._destroy = true;
                if (note.ignored) ignoredCallback(note);
            }
        });
    };

    this.recoverModNotes = function(notes, modId) {
        notes.forEach(function(note) {
            if (note._destroy && note.first_mod.id == modId || note.second_mod.id == modId) {
                delete note._destroy;
                if (note.ignored) note.ignored = false;
            }
        });
    };

    this.removePluginNotes = function(notes, pluginId, ignoredCallback) {
        notes.forEach(function(note) {
            if (note.first_plugin.id == pluginId || note.second_plugin.id == pluginId) {
                note._destroy = true;
                if (note.ignored) ignoredCallback(note);
            }
        });
    };

    this.recoverPluginNotes = function(notes, pluginId) {
        notes.forEach(function(note) {
            if (note._destroy && note.first_plugin.id == pluginId || note.second_plugin.id == pluginId) {
                delete note._destroy;
            }
        });
    };
});