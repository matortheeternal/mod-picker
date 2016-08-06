app.service('configFilesService', function () {
    var service = this;

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
        var foundGroup = model.find(function(group) {
            return group.name === 'Custom';
        });
        if (foundGroup) {
            foundGroup.children.push(customConfigFile);
        } else {
            var group = {
                name: 'Custom',
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
