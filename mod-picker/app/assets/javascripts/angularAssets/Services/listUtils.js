app.service('listUtils', function () {
    var service = this;

    this.findItem = function(model, key, itemId, splice) {
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            if (item.children) {
                for (var j = 0; j < item.children.length; j++) {
                    var child = item.children[j];
                    if (child[key].id == itemId) {
                        return (splice && item.children.splice(j, 1)[0]) || child;
                    }
                }
            } else {
                if (item[key].id == itemId) {
                    return (splice && model.splice(i, 1)[0]) || item;
                }
            }
        }
    };

    this.findMod = function(model, modId, splice) {
        return service.findItem(model, 'mod', modId, splice);
    };

    this.findPlugin = function(model, pluginId, splice) {
        return service.findItem(model, 'plugin', pluginId, splice);
    };

    this.findGroup = function(model, groupId) {
        return model.find(function(item) {
            return item.children && item.id == groupId;
        });
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

    this.updateItems = function(model) {
        var i = 1;
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
        var destItem = service.findItem(model, key, options.destId);

        // check if the destination item is on the view model
        if (!destItem) {
            return 'Failed to move '+key+', could not find destination '+key+'.';
        }

        // this splices the item if found
        var moveItem = service.findItem(model, key, options.moveId, true);

        // check if the item be moved is on the view model
        if (!moveItem) {
            return 'Failed to move '+key+', could not find '+key+' to move.';
        }

        var moveModel = model;
        // if both items are in the same group, move within the group
        if (moveItem.group_id == destItem.group_id) {
            moveModel = service.findGroup(model, moveItem.group_id).children;
        }
        // send a cursor down the model until the index of the item we're on exceeds the destItem's index
        var newIndex = moveModel.findIndex(function(item) {
            return item.index >= destItem.index;
        });

        // reinsert the mod at the new index
        moveModel.splice(options.after ? newIndex + 1 : newIndex, 0, moveItem);
    };

    this.moveMod = function(model, options) {
        return service.moveItem(model, 'mod', options);
    };

    this.movePlugin = function(model, options) {
        return service.moveItem(model, 'plugin', options);
    };
});