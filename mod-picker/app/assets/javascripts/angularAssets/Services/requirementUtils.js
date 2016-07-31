app.service('requirementUtils', function () {
    this.compactRequirements = function(requirements, key, reqKey) {
        var pluralKey = key + "s";
        var destroyedKey = "destroyed_" + pluralKey;
        var req, prev;
        for (var i = requirements.length - 1; i >= 0; i--) {
            req = requirements[i];
            if (prev && req[reqKey].id == prev[reqKey].id) {
                prev[pluralKey].unshift(req[key]);
                requirements.splice(i, 1);
            } else {
                req[pluralKey] = [req[key]];
                req[destroyedKey] = [];
                delete req[key];
                prev = req;
            }
        }
    };

    this.addRequirements = function(newRequirements, requirements, key, reqKey) {
        var pluralKey = key + "s";
        var destroyedKey = "destroyed_" + pluralKey;
        newRequirements.forEach(function(newRequirement) {
            var foundRequirement = requirements.find(function(requirement) {
                return requirement[reqKey].id == newRequirement[reqKey].id;
            });
            if (foundRequirement) {
                foundRequirement[pluralKey].push(newRequirement.mod);
            } else {
                newRequirement[pluralKey] = [newRequirement[key]];
                newRequirement[destroyedKey] = [];
                delete newRequirement[key];
                requirements.push(newRequirement);
            }
        });
    };

    this.removeRequirements = function(itemId, requirements, key) {
        var pluralKey = key + "s";
        var destroyedKey = "destroyed_" + pluralKey;
        requirements.forEach(function(requirement) {
            var index = requirement[pluralKey].findIndex(function(item) {
                return item.id == itemId;
            });
            if (index > -1) {
                var item = requirement[pluralKey].splice(index, 1)[0];
                requirement[destroyedKey].push(item);
            }
        });
    };

    this.recoverRequirements = function(itemId, requirements, key) {
        var pluralKey = key + "s";
        var destroyedKey = "destroyed_" + pluralKey;
        requirements.forEach(function(requirement) {
            var index = requirement[destroyedKey].findIndex(function(item) {
                return item.id == itemId;
            });
            if (index > -1) {
                var item = requirement[destroyedKey].splice(index, 1)[0];
                requirement[pluralKey].push(item);
            }
        });
    };

    this.removeDestroyedRequirements = function(requirements, key) {
        var pluralKey = key + "s";
        var destroyedKey = "destroyed_" + pluralKey;
        requirements.forEach(function(requirement, index, array) {
            requirement[destroyedKey] = [];
            if (!requirement[pluralKey].length) {
                array.splice(index, 1);
            }
        });
    };

    this.recoverDestroyedRequirements = function(requirements, key) {
        var pluralKey = key + "s";
        var destroyedKey = "destroyed_" + pluralKey;
        requirements.forEach(function(requirement) {
            requirement[pluralKey].unite(requirement[destroyedKey]);
            requirement[destroyedKey] = [];
        });
    };
});