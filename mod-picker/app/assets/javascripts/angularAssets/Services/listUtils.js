app.service('listUtils', function () {
    var service = this;

    this.findMod = function(model, modId, splice) {
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            if (item.children) {
                for (var j = 0; j < item.children.length; j++) {
                    var child = item.children[j];
                    if (child.mod.id == modId) {
                        return (splice && item.children.splice(j, 1)[0]) || child;
                    }
                }
            } else {
                if (item.mod.id == modId) {
                    return (splice && model.splice(i, 1)[0]) || item;
                }
            }
        }
    };

    this.findGroup = function(model, groupId) {
        return model.find(function(item) {
            return item.children && item.id == groupId;
        });
    };
});