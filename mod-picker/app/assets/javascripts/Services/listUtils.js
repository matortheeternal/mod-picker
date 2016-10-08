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
            var foundConfig = service.findItem(group.configs, 'config_file', 'id', configId, splice);
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

    this.moveItem = function(model, key, options) {
        var destItem = service.findItem(model, key, 'id', options.destId);

        // check if the destination item is on the view model
        if (!destItem) {
            return 'Failed to move '+key+', could not find destination '+key+'.';
        }

        // this splices the item if found
        var moveItem = service.findItem(model, key, 'id', options.moveId, true);

        // check if the item be moved is on the view model
        if (!moveItem) {
            return 'Failed to move '+key+', could not find '+key+' to move.';
        }

        var moveModel = model;
        // if both items are in the same group, move within the group
        if (!!moveItem.group_id && moveItem.group_id == destItem.group_id) {
            moveModel = service.findGroup(model, moveItem.group_id).children;
        }
        // send a cursor down the model until the index of the item we're on exceeds the destItem's index
        var newIndex = moveModel.findIndex(function(item) {
            return item.index >= destItem.index;
        });

        // reinsert the mod at the new index
        moveModel.splice(options.after ? newIndex + 1 : newIndex, 0, moveItem);
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