app.service('modOptionUtils', function() {
    var service = this;

    this.findParentOption = function(modOptions, modOption) {
        if (modOption.md5_hash) {
            return modOptions.find(function(option) {
                return !option.is_installer_option && option.md5_hash == modOption.md5_hash;
            });
        } else if (modOptions.length == 1) {
            return modOptions[0];
        }
    };

    this.addChildModOption = function(parentOption, modOption) {
        if (!parentOption.hasOwnProperty('children')) {
            parentOption.children = [];
        }
        parentOption.children.push(modOption);
    };

    this.getNestedModOptions = function(modOptions) {
        var nestedModOptions = [], archiveOptions = [], installerOptions = [];
        modOptions.forEach(function(modOption) {
            if (modOption.is_installer_option) {
                modOption.iconClass = 'fa-gear';
                modOption.tooltip = 'Installer mod option';
                installerOptions.push(modOption);
            } else {
                modOption.iconClass = 'fa-file-archive-o';
                modOption.tooltip = 'Archive mod option';
                archiveOptions.push(modOption);
                nestedModOptions.push(modOption);
            }
        });
        installerOptions.forEach(function(modOption) {
            var parentOption = service.findParentOption(archiveOptions, modOption);
            if (parentOption) {
                service.addChildModOption(parentOption, modOption)
            } else {
                nestedModOptions.push(modOption);
            }
        });

        return nestedModOptions;
    };

    this.activateDefaultModOptions = function(modOptions) {
        modOptions.forEach(function(option) {
            option.active = option.default;
        });
    };

    this.buildHelperFunctions = function($scope, $rootScope) {
        $scope.findExistingModOption = function(modListMod, optionId) {
            var optionsArray = modListMod.mod_list_mod_options;
            return optionsArray.find(function(option) {
                return option.mod_option_id == optionId;
            });
        };

        $scope.addModOption = function(modListMod, optionId) {
            var option = modListMod.mod.mod_options.find(function(option) {
                return option.id == optionId;
            });
            var existingModOption = $scope.findExistingModOption(modListMod, optionId);
            if (existingModOption) {
                if (existingModOption._destroy) {
                    delete existingModOption._destroy;
                }
            } else {
                modListMod.mod_list_mod_options.push({
                    mod_option_id: optionId
                });
            }
            $rootScope.$broadcast('modOptionAdded', option);
        };

        $scope.removeModOption = function(modListMod, optionId) {
            var optionsArray = modListMod.mod_list_mod_options;
            var index = optionsArray.findIndex(function(option) {
                return option.mod_option_id == optionId;
            });
            if (index > -1) {
                optionsArray[index]._destroy = true;
            }
            $rootScope.$broadcast('modOptionRemoved', optionId);
        };

        $scope.recoverModOptions = function(modListMod) {
            modListMod.mod && modListMod.mod.mod_options.forEach(function(option) {
                var foundModOption = modListMod.mod_list_mod_options.find(function(ml_option) {
                    return option.id == ml_option.id;
                });
                if (foundModOption) $rootScope.$broadcast('modOptionAdded', option);
            });
        };

        $scope.addDefaultModOptions = function(modListMod) {
            modListMod.mod.mod_options.forEach(function(option) {
                if (option.default) {
                    option.active = true;
                    var options = modListMod.mod_list_mod_options;
                    var existingModOption = options.find(function(mlOption) {
                        return mlOption.mod_option_id == option.id;
                    });
                    if (!existingModOption) {
                        options.push({ mod_option_id: option.id });
                        $rootScope.$broadcast('modOptionAdded', option);
                    }
                }
            });
        };

        $scope.removeActiveModOptions = function(modListMod) {
            modListMod.mod_list_mod_options.forEach(function(option) {
                $rootScope.$broadcast('modOptionRemoved', option.mod_option_id);
            });
            modListMod.mod_list_mod_options = [];
            modListMod.mod && modListMod.mod.mod_options.forEach(function(option) {
                option.active = false;
            });
        };
    }
});
