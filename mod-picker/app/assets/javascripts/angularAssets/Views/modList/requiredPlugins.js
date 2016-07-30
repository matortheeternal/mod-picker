app.directive('requiredPlugins', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredPlugins.html',
        controller: 'requiredPluginsController',
        scope: false
    }
});

app.controller('requiredPluginsController', function($scope) {
    /* BUILD VIEW MODEL */
    $scope.compactRequiredPlugins = function() {
        var requirements = $scope.required.plugins;
        var req, prev;
        for (var i = requirements.length - 1; i >= 0; i--) {
            req = requirements[i];
            if (prev && req.master_plugin.id == prev.master_plugin.id) {
                prev.plugins.unshift(req.plugin);
                requirements.splice(i, 1);
            } else {
                req.plugins = [req.plugin];
                req.destroyed_plugins = [];
                delete req.plugin;
                prev = req;
            }
        }
    };

    $scope.buildMissingPlugins = function() {
        $scope.required.missing_plugins = [];
        $scope.required.plugins.forEach(function(requirement) {
            // skip destroyed requirements
            if (requirement._destroy) {
                return;
            }
            var pluginPresent = $scope.findPlugin(requirement.master_plugin.id, true);
            // TODO: Check if one of the plugins in the plugins array is present
            if (!pluginPresent) {
                $scope.required.missing_plugins.push(requirement);
            }
        });
    };

    /* UPDATE VIEW MODEL */
    $scope.addRequirements = function(requirements) {
        requirements.forEach(function(newRequirement) {
            var foundRequirement = $scope.required.plugins.find(function(requirement) {
                return requirement.master_plugin.id == newRequirement.master_plugin.id;
            });
            if (foundRequirement) {
                foundRequirement.plugins.push(newRequirement.plugin);
            } else {
                newRequirement.plugins = [newRequirement.plugin];
                newRequirement.destroyed_plugins = [];
                delete newRequirement.plugin;
                $scope.required.plugins.push(newRequirement);
            }
        });
    };

    $scope.removeRequirements = function(pluginId) {
        $scope.required.plugins.forEach(function(requirement) {
            var index = requirement.plugins.findIndex(function(plugin) {
                return plugin.id == pluginId;
            });
            if (index > -1) {
                var plugin = requirement.plugins.splice(index, 1)[0];
                requirement.destroyed_plugins.push(plugin);
            }
        });
    };
    $scope.recoverRequirements = function(pluginId) {
        $scope.required.plugins.forEach(function(requirement) {
            var index = requirement.destroyed_plugins.findIndex(function(plugin) {
                return plugin.id == pluginId;
            });
            if (index > -1) {
                var plugin = requirement.destroyed_plugins.splice(index, 1)[0];
                requirement.plugins.push(plugin);
            }
        });
    };

    /* HELPER FUNCTIONS */
    $scope.getRequirerList = function(requirement, startIndex) {
        return requirement.plugins.slice(startIndex).map(function(plugin) {
            return plugin.filename;
        }).join(', ');
    };

    /* RESOLUTION ACTIONS */
    $scope.removeRequirers = function(requirement) {
        requirement.plugins.forEach(function(plugin) {
            $scope.removePlugin($scope.findPlugin(plugin.id, true));
        });
    };

    /* EVENT TRIGGERS */
    $scope.$on('initializeModules', function() {
        $scope.compactRequiredPlugins();
        $scope.buildMissingPlugins();
    });
    $scope.$on('reloadModules', function() {
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginRemoved', function(event, pluginId) {
        $scope.removeRequirements(pluginId);
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginRecovered', function(event, pluginId) {
        $scope.recoverRequirements(pluginId);
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginAdded', function(event, pluginData) {
        $scope.addRequirements(pluginData.required_plugins);
        $scope.buildMissingPlugins();
    });
});