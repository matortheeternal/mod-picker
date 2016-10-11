app.controller('modListPluginsController', function($scope, $q, $timeout, categoryService, modListService, pluginService, columnsFactory, actionsFactory, colorsFactory, listMetaFactory, listUtils) {
    // INITIALIZE VARIABLES
    $scope.columns = columnsFactory.modListPluginColumns();
    columnsFactory.buildColumnClasses($scope.columns);
    $scope.columnGroups = columnsFactory.modListPluginColumnGroups();
    $scope.actions = actionsFactory.modListPluginActions();

    // SHARED FUNCTIONS
    $scope.searchPluginStore = pluginService.searchModListPluginStore($scope);
    listMetaFactory.buildModelFunctions($scope, 'plugin', 'plugin', 'filename', 'CustomPlugin.esp');
    listMetaFactory.buildSortFunctions($scope, 'load', 'plugin', 'overrides_count');

    // MODAL HANDLING
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.detailsItem = item;
        $scope.showDetailsModal = visible;
    };

    $scope.toggleManagePluginsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showManagePluginsModal = visible;
    };

    // DATA LOADING
    $scope.buildPluginsModel = function() {
        listUtils.buildModel($scope.model, $scope.mod_list, 'plugins');
    };

    $scope.destroyModRemovedPlugins = function() {
        if (!$scope.removedModIds.length) return;
        listUtils.forEachItem($scope.model.plugins, function(item) {
            if (item.mod && $scope.removedModIds.indexOf(item.mod.id) > -1) {
                $scope.removePlugin(item);
            }
        });
        $scope.plugins_store.forEach(function(plugin) {
            if ($scope.removedModIds.indexOf(plugin.mod_id) > -1) {
                plugin._destroy = true;
            }
        });
    };

    $scope.loadPluginData = function(data) {
        categoryService.associateCategories($scope.categories, data.plugins);
        $scope.required.plugins = data.required_plugins;
        $scope.plugins_store = data.plugins_store;
        $scope.loadNotes(data, 'compatibility_notes', 'plugin_compatibility', 'CompatibilityNote');
        $scope.loadNotes(data, 'load_order_notes', 'load_order', 'LoadOrderNote');
        $scope.loadAndTrack(data, 'plugins');
        $scope.loadAndTrack(data, 'custom_plugins');
        $scope.loadGroups(data.groups);
        $scope.buildPluginsModel();
        $timeout(function() {
            $scope.$broadcast('initializeModules');
            $timeout($scope.destroyModRemovedPlugins);
        }, 100);
    };

    $scope.retrievePlugins = function() {
        modListService.retrieveModListPlugins($scope.mod_list.id).then(function(data) {
            $scope.loadPluginData(data);
            $scope.pluginsReady = true;
        }, function(response) {
            $scope.errors.plugins = response;
        });
    };

    // retrieve plugins when the state is first loaded
    $scope.retrievePlugins();

    // HELPER FUNCTIONS
    $scope.prepareCustomPatch = function(customPlugin, compatibilityNoteId) {
        var foundCustomPlugin = $scope.findCustomPlugin(compatibilityNoteId);
        if (foundCustomPlugin) {
            foundCustomPlugin._destroy = false;
            $scope.$broadcast('customPluginAdded');
            return;
        }
        customPlugin.filename = 'CustomPatch'+compatibilityNoteId+'.esp';
        customPlugin.compatibility_note_id = compatibilityNoteId;
    };

    // CUSTOM CALLBACKS
    $scope.addCustomPluginCallback = function(options) {
        if (options.noteId) {
            $scope.prepareCustomPatch(options.item, options.noteId);
        }
    };

    // VIEW MODEL HELPER FUNCTIONS
    $scope.toggleLoadOrder = function() {
        $scope.showLoadOrder = !$scope.showLoadOrder;
        $scope.columns[0].visibility = !$scope.showLoadOrder;
        $scope.columns[1].visibility = $scope.showLoadOrder;
    };

    // PLUGINS STORE HELPER FUNCTIONS
    $scope.togglePlugin = function(pluginItem) {
        if (pluginItem.active) {
            $scope.addPlugin(pluginItem.id);
        } else {
            var foundPlugin = $scope.findPlugin(pluginItem.id, true);
            if (foundPlugin) $scope.removePlugin(foundPlugin);
        }
    };

    $scope.addModOptionPluginsToStore = function(modOption) {
        modOption && modOption.plugins.forEach(function(plugin) {
            var pluginExists = $scope.plugins_store.find(function(storedPlugin) {
                return storedPlugin.id == plugin.id;
            });
            if (!pluginExists) {
                $scope.plugins_store.push(plugin);
            }
        });
    };

    // event triggers
    $scope.$on('removeItem', function(event, modListPlugin) {
        $scope.removePlugin(modListPlugin);
    });
    $scope.$on('modOptionRemoved', function(event, modOptionId) {
        var model = $scope.model.plugins;
        listUtils.forMatchingItems(model, 'mod_option_id', modOptionId, $scope.removePlugin);
        listUtils.forMatching($scope.plugins_store, 'mod_option_id', modOptionId, listUtils.destroyItem);
    });
    $scope.$on('modOptionAdded', function(event, modOption) {
        var modOptionId = modOption.id;
        var model = $scope.model.plugins;
        listUtils.forMatchingItems(model, 'mod_option_id', modOptionId, $scope.recoverPlugin);
        listUtils.forMatching($scope.plugins_store, 'mod_option_id', modOptionId, listUtils.recoverItem);
        $scope.addModOptionPluginsToStore(modOption);
    });
    $scope.$on('rebuildModels', $scope.buildPluginsModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.mod_list.plugins);
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.mod_list.plugins);
        listUtils.removeDestroyed($scope.plugins_store);
    });
    $scope.$on('itemMoved', function() {
        $scope.$broadcast('pluginMoved');
    });
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});