app.controller('modListPluginsController', function($scope, modListService, columnsFactory) {
    // initialize variables
    $scope.columns = columnsFactory.modListPluginColumns();
    $scope.actions = [{
        caption: "Remove",
        title: "Remove this plugin from the mod list",
        execute: function($scope, item) {
            if (!$scope.editing) return;
            $scope.removeCallback(item);
        }
    }];

    // functions
    $scope.buildPluginsModel = function() {
        $scope.model.plugins = [];
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'plugins') {
                return;
            }
            $scope.model.plugins.push(group);
            group.children = $scope.mod_list.plugins.filter(function(plugin) {
                return plugin.group_id == group.id;
            });
        });
        $scope.mod_list.plugins.forEach(function(plugin) {
            if (!plugin.group_id) {
                var insertIndex = $scope.model.plugins.findIndex(function(item) {
                    return item.index > plugin.index;
                });
                if (insertIndex == -1) {
                    insertIndex = $scope.model.plugins.length;
                }
                $scope.model.plugins.splice(insertIndex, 0, plugin);
            }
        });
    };

    $scope.retrievePlugins = function() {
        $scope.retrieving.plugins = true;
        modListService.retrieveModListPlugins($scope.mod_list.id).then(function(data) {
            $scope.required.plugins = data.required_plugins;
            $scope.notes.plugin_compatibility = data.compatibility_notes;
            $scope.notes.load_order = data.load_order_notes;
            $scope.mod_list.plugins = data.plugins;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.plugins = angular.copy($scope.mod_list.mods);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.buildPluginsModel();
            /*$scope.buildMissingPlugins();
            $scope.buildUnresolvedPluginCompatibility();
            $scope.buildUnresolvedLoadOrder();*/
            $scope.retrieving.plugins = false;
        }, function(response) {
            $scope.errors.plugins = response;
        });
    };

    // retrieve plugins if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.plugins && !$scope.retrieving.plugins) {
        $scope.retrievePlugins();
    }
});