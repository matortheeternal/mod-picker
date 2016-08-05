app.service('configFilesService', function () {
    var service = this;

    this.addConfigFile = function(model, configFile) {
        var foundMod = model.find(function(group) {
            return group.id == configFile.config_file.mod.id;
        });
        if (foundMod) {
            foundMod.configs.push(configFile);
        } else {
            var group = {
                id: configFile.config_file.mod.id,
                name: configFile.config_file.mod.name,
                configs: [configFile]
            };
            model.push(group);
        }
    };

    this.groupConfigFiles = function(configFiles) {
        var groupedConfigFiles = [];
        configFiles.forEach(function(configFile) {
            service.addConfigFile(groupedConfigFiles, configFile);
        });
        groupedConfigFiles.forEach(function(group) {
            group.activeConfig = group.configs[0];
            group.activeConfig.active = true;
        });
        return groupedConfigFiles;
    };
});
