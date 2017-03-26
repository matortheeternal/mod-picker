app.directive('pluginLoadOrderIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/pluginLoadOrderIssues.html',
        controller: 'pluginLoadOrderIssuesController',
        scope: false
    }
});

app.controller('pluginLoadOrderIssuesController', function($scope, $timeout, listUtils, requirementUtils) {
    $scope.showUnresolvedLoadOrder = true;
    $scope.getRequirerList = requirementUtils.getPluginRequirerList;

    /* BUILD VIEW MODEL */
    $scope.buildUnresolvedLoadOrder = function() {
        $scope.notes.unresolved_load_order = [];
        $scope.notes.ignored_load_order = [];
        $scope.notes.load_order.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_load_order.push(note);
                return;
            }
            var first_plugin = $scope.findPlugin(note.first_plugin.id, true);
            var second_plugin = $scope.findPlugin(note.second_plugin.id, true);
            // unresolved if the both mods are present and the first mod comes after the second mod
            if (first_plugin && second_plugin && first_plugin.index > second_plugin.index) {
                note.resolved = false;
                $scope.notes.unresolved_load_order.push(note);
            } else {
                note.resolved = true;
            }
        });
    };

    $scope.buildOutOfOrderPlugins = function() {
        $scope.required.out_of_order_plugins = [];
        $scope.required.plugins.forEach(function(requirement) {
            var masterPlugin = $scope.findPlugin(requirement.master_plugin.id, true);
            if (masterPlugin) {
                var item = {}, earliestIndex = 999, earliestPlugin = {};
                var masterIndex = masterPlugin.index;
                item.plugins = requirement.plugins.filter(function(plugin) {
                    var foundPlugin = $scope.findPlugin(plugin.id, true);
                    if (foundPlugin.index < earliestIndex) {
                        earliestIndex = foundPlugin.index;
                        earliestPlugin = foundPlugin.plugin;
                    }
                    return foundPlugin && foundPlugin.index < masterIndex;
                });
                if (item.plugins.length) {
                    item.master_plugin = requirement.master_plugin;
                    item.earliest_plugin = earliestPlugin;
                    $scope.required.out_of_order_plugins.push(item);
                }
            }
        });
    };

    $scope.buildLoadOrderIssues = function() {
        $scope.buildUnresolvedLoadOrder();
        $timeout($scope.buildOutOfOrderPlugins, 10);
    };

    /* RESOLUTIONS ACTIONS */
    $scope.$on('resolveLoadOrderNote', function(event, options) {
        switch(options.action) {
            case "move":
                var moveOptions = {
                    moveId: options.note.plugins[options.index].id,
                    destId: options.note.plugins[+!options.index].id,
                    after: !!options.index
                };
                $scope.$broadcast('moveItem', moveOptions);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                $scope.ignoreNote('LoadOrderNote', options.note);
                $scope.buildUnresolvedLoadOrder();
                break;
        }
    });

    $scope.reorder = function(requirement, reorderDependencies) {
        var moveOptions;
        if (reorderDependencies) {
            moveOptions = {
                destId: requirement.master_plugin.id,
                after: true
            };
            for (var i = requirement.plugins.length - 1; i >= 0; i--) {
                var plugin = requirement.plugins[i];
                moveOptions.moveId = plugin.id;
                $scope.$broadcast('moveItem', moveOptions);
            }
        } else {
            moveOptions = {
                moveId: requirement.master_plugin.id,
                destId: requirement.earliest_plugin.id,
                after: false
            };
            $scope.$broadcast('moveItem', moveOptions);
        }
    };

    $scope.resolveAllLoadOrder = function(moveDown) {
        $scope.notes.unresolved_load_order.forEach(function(note) {
            var moveOptions = {
                moveId: moveDown ? note.second_plugin.id : note.first_plugin.id,
                destId: moveDown ? note.first_plugin.id : note.second_plugin.id,
                after: moveDown
            };
            $scope.$broadcast('moveItem', moveOptions);
        });
        $scope.required.out_of_order_plugins.forEach(function(requirement) {
            $scope.reorder(requirement, moveDown);
        });
    };

    // event triggers
    $scope.$on('initializeModules', $scope.buildLoadOrderIssues);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.notes.load_order);
        $scope.buildLoadOrderIssues();
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.notes.load_order);
        $scope.buildLoadOrderIssues();
    });
    $scope.$on('resolveAllLoadOrder', function() {
        $scope.buildUnresolvedLoadOrder();
        $scope.buildOutOfOrderPlugins();
        $scope.resolveAllLoadOrder(true);
    });
    $scope.$on('pluginRemoved', function(event, plugin) {
        if (plugin) {
            listUtils.removePluginNotes($scope.notes.load_order, plugin.filename, function(note) {
                $scope.destroyIgnoreNote('LoadOrderNote', note);
            });
        }
        $scope.buildLoadOrderIssues();
    });
    $scope.$on('pluginRecovered', function(event, pluginId) {
        if (pluginId) listUtils.recoverPluginNotes($scope.notes.load_order, pluginId);
        // this $timeout is necessary because we need to indexes to be rebuilt
        // prior to determining unresolved load order issues
        $timeout(function() {
            $scope.buildLoadOrderIssues();
        });
    });
    $scope.$on('pluginAdded', $scope.buildLoadOrderIssues);
    $scope.$on('pluginMoved', $scope.buildLoadOrderIssues);
    $scope.$on('modAdded', function(event, modData) {
        $scope.notes.load_order.unite(modData.load_order_notes);
        $scope.buildLoadOrderIssues();
    });
});