app.service('configFilesService', function() {
    var service = this;

    this.groupHasChildren = function(group) {
        for (var i = 0; i < group.children.length; i++) {
            var child = group.children[i];
            if (!child._destroy) return true;
        }
        return false;
    };

    this.firstAvailableConfig = function(group) {
        return group.children.find(function(child) {
            return !child._destroy;
        });
    };

    this.recoverConfigFileGroups = function(model) {
        model.forEach(function(group) {
            if (group._destroy && service.groupHasChildren(group)) {
                delete group._destroy;
                if (!group.activeConfig) {
                    group.activeConfig = service.firstAvailableConfig(group);
                    group.activeConfig.active = true;
                }
            }
        });
    };

    this.addConfigFile = function(model, configFile) {
        var foundGroup = model.find(function(group) {
            return group.id == configFile.config_file.mod.id;
        });
        if (foundGroup) {
            foundGroup.children.push(configFile);
        } else {
            var group = {
                id: configFile.config_file.mod.id,
                name: configFile.config_file.mod.name,
                children: [configFile]
            };
            model.push(group);
        }
    };

    this.addCustomConfigFile = function(model, customConfigFile) {
        customConfigFile.active = true;
        var foundGroup = model.find(function(group) {
            return group.name === 'Custom';
        });
        if (foundGroup) {
            foundGroup.children.push(customConfigFile);
            foundGroup.activeConfig = customConfigFile;
        } else {
            var group = {
                name: 'Custom',
                activeConfig: customConfigFile,
                children: [customConfigFile]
            };
            model.push(group);
        }
    };

    this.groupConfigFiles = function(model, configFiles, customConfigFiles) {
        configFiles.forEach(function(configFile) {
            service.addConfigFile(model, configFile);
        });
        customConfigFiles.forEach(function(customConfigFile) {
            service.addCustomConfigFile(model, customConfigFile);
        });
        model.forEach(function(group) {
            group.activeConfig = group.children[0];
            group.activeConfig.active = true;
        });
    };
});
