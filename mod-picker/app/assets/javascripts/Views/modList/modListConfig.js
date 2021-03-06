app.controller('modListConfigController', function($scope, $q, $timeout, modListService, configFilesService, listUtils) {
    $scope.toggleManageConfigsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showManageConfigsModal = visible;
    };

    $scope.searchConfigStore = function(str) {
        var action = $q.defer();
        var matchingConfigs = $scope.configs_store.filter(function(config) {
            return config.filename.toLowerCase().includes(str);
        });
        action.resolve(matchingConfigs);
        return action.promise;
    };

    $scope.buildConfigModel = function() {
        // build models
        $scope.model.config_files = [];
        configFilesService.groupConfigFiles($scope.model.config_files, $scope.mod_list.config_files, $scope.mod_list.custom_config_files);
    };

    $scope.retrieveConfig = function() {
        modListService.retrieveModListConfigFiles($scope.mod_list.id).then(function(data) {
            $scope.mod_list.config_files = data.config_files;
            $scope.mod_list.custom_config_files = data.custom_config_files;
            $scope.configs_store = data.config_files_store;
            $scope.originalModList.config_files = angular.copy($scope.mod_list.config_files);
            $scope.originalModList.custom_config_files = angular.copy($scope.mod_list.custom_config_files);
            $scope.buildConfigModel();
            $scope.configReady = true;
            $scope.resetSticky();
        }, function(response) {
            $scope.errors.config = response;
        });
    };

    // retrieve config when the state is first loaded
    $scope.retrieveConfig();

    // returns true if there are no config files to display
    $scope.noConfigFiles = function() {
        if (!$scope.model.config_files || !$scope.mod_list.custom_config_files) return true;
        return !$scope.model.config_files.find(function(group) {
            return !group._destroy;
        }) && !$scope.mod_list.custom_config_files.find(function(config) {
            return !config._destroy;
        });
    };

    $scope.selectConfig = function(group, config) {
        if (config._destroy) return;
        if (group.activeConfig) group.activeConfig.active = false;
        group.activeConfig = config;
        group.activeConfig.active = true;
    };

    $scope.recoverConfig = function(modListConfig) {
        // if plugin is already present on the user's mod list but has been
        // removed, add it back
        if (modListConfig._destroy) {
            delete modListConfig._destroy;
            $scope.mod_list.config_files_count += 1;
            configFilesService.recoverConfigFileGroups($scope.model.config_files);
            $scope.updateTabs();

            // success message
            $scope.$emit('successMessage', 'Added config file ' + modListConfig.config_file.filename+ ' successfully.');
        }
        // else inform the user that the plugin is already on their mod list
        else {
            var params = {type: 'error', text: 'Failed to add config file ' + modListConfig.config_file.filename + ', the config file has already been added to this mod list.'};
            $scope.$emit('customMessage', params);
        }
    };

    $scope.removeConfig = function(group, index) {
        var configToRemove = group.children[index];
        if (configToRemove._destroy) return;
        var wasActiveConfig = configToRemove.active;
        configToRemove._destroy = true;
        configToRemove.active = false;

        // update counts
        if (configToRemove.config_file) {
            $scope.mod_list.config_files_count -= 1;
        } else {
            $scope.mod_list.custom_config_files_count -= 1;
        }
        $scope.updateTabs();

        // verify there is another config in this group
        // switch to the first available config if the user destroyed the active config
        for (var i = 0; i < group.children.length; i++) {
            if (!group.children[i]._destroy) {
                if (wasActiveConfig) {
                    $timeout(function() {
                        $scope.selectConfig(group, group.children[i]);
                    });
                }
                return;
            }
        }

        // no configs in the group to switch to, destroy the group!
        delete group.activeConfig;
        group._destroy = true;
    };

    $scope.addNewConfig = function(configId) {
        var config_file = {
            mod_list_id: $scope.mod_list.id,
            config_file_id: configId
        };

        modListService.newModListConfigFile(config_file).then(function(data) {
            // push config onto view
            var modListConfigFile = data.mod_list_config_file;
            $scope.mod_list.config_files.push(angular.copy(modListConfigFile));
            $scope.originalModList.config_files.push(angular.copy(modListConfigFile));
            $scope.mod_list.config_files_count += 1;
            $scope.updateTabs();

            // update models
            configFilesService.addConfigFile($scope.model.config_files, modListConfigFile);

            // success message
            var filename = modListConfigFile.config_file.filename;
            $scope.$emit('successMessage', 'Added config file ' + filename + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding config file', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addConfig = function(configId) {
        // return if we don't have a config to add
        if (!configId) {
            return;
        }

        // see if the plugin is already present on the user's plugin list
        var existingConfig = $scope.findConfig(configId);
        if (existingConfig) {
            $scope.recoverConfig(existingConfig);
        } else {
            $scope.addNewConfig(configId);
        }

        if ($scope.add.config.id) {
            $scope.add.config.id = null;
            $scope.add.config.name = "";
        }
    };

    $scope.toggleConfig = function(configItem) {
        if (configItem.active) {
            $scope.addConfig(configItem.id);
        } else {
            for (var i = 0; i < $scope.model.config_files.length; i++) {
                var group = $scope.model.config_files[i];
                var index = group.children.findIndex(function(config) {
                    return config.config_file.id == configItem.id;
                });
                if (index > -1) {
                    $scope.removeConfig(group, index);
                    break;
                }
            }
        }
    };

    $scope.addCustomConfig = function() {
        var custom_config = {
            mod_list_id: $scope.mod_list.id,
            filename: 'Custom Config',
            install_path: '{{GamePath}}'
        };

        modListService.newModListCustomConfigFile(custom_config).then(function(data) {
            // push config onto view
            var modListCustomConfig = data.mod_list_custom_config_file;
            $scope.mod_list.custom_config_files.push(angular.copy(modListCustomConfig));
            $scope.originalModList.custom_config_files.push(angular.copy(modListCustomConfig));
            $scope.mod_list.config_files_count += 1;
            $scope.updateTabs();

            // update models
            configFilesService.addCustomConfigFile($scope.model.config_files, modListCustomConfig);
        }, function(response) {
            var params = {label: 'Error adding custom config file', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    // event triggers
    $scope.$on('rebuildModels', $scope.buildConfigModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.model.config_files);
        $scope.model.config_files.forEach(function(group) {
            listUtils.recoverDestroyed(group.children);
            if (!group.activeConfig) group.activeConfig = group.configs[0];
        });
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.model.config_files);
        $scope.model.config_files.forEach(function(group) {
            listUtils.removeDestroyed(group.children);
        });
    });
});