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
        var archiveOptions = [], installerOptions = [];
        modOptions.forEach(function(modOption) {
            if (modOption.is_installer_option) {
                modOption.iconClass = 'fa-gear';
                installerOptions.push(modOption)
            } else {
                modOption.iconClass = 'fa-file-archive-o';
                archiveOptions.push(modOption)
            }
        });
        installerOptions.forEach(function(modOption) {
            var parentOption = service.findParentOption(archiveOptions, modOption);
            if (parentOption) {
                service.addChildModOption(parentOption, modOption)
            } else {
                archiveOptions.push(modOption);
            }
        });

        return archiveOptions;
    };

    this.activateDefaultModOptions = function(modOptions) {
        modOptions.forEach(function(option) {
            option.active = option.default;
        });
    }
});
