app.factory("tabsFactory", function() {
    var factory = this;

    this.buildUserSettingsTabs = function() {
        return [
            { name: 'Profile' },
            { name: 'Account' },
            { name: 'Mod Lists' },
            { name: 'Authored Mods' }
        ];
    };

    this.buildModTabs = function(mod) {
        var tabs = [];

        // mods without a primary category (games) don't have reviews,
        // compatibility notes, install order notes, or load order notes
        if (mod.primary_category_id) {
            tabs.push({
                name: 'Reviews',
                count: mod.reviews_count
            });
            tabs.push({
                name: 'Compatibility',
                count: mod.compatibility_notes_count
            });
            // utilities don't have install order notes
            if (!mod.is_utility) {
                tabs.push({
                    name: 'Install Order',
                    count: mod.install_order_notes_count
                });
            }
            // mods with no plugins don't have load order notes
            if (mod.plugins_count) {
                tabs.push({
                    name: 'Load Order',
                    count: mod.load_order_notes_count
                });
            }
        }

        // all mod pages have the analysis tab
        tabs.push({
            name: 'Analysis'
        });

        return tabs;
    };

    this.buildModListTabs = function(modList) {
        var tabs = [
            {
                name: 'Details'
            },
            {
                name: 'Tools',
                count: modList.tools_count + modList.custom_tools_count
            },
            {
                name: 'Mods',
                count: modList.mods_count + modList.custom_mods_count
            },
            {
                name: 'Plugins',
                count: modList.plugins_count + modList.custom_plugins_count
            },
            {
                name: 'Config',
                count: modList.config_files_count + modList.custom_config_files_count
            },
            {
                name: 'Analysis'
            }
        ];

        if (!modList.disable_comments) {
            tabs.push({
                name: 'Comments',
                count: modList.comments_count
            });
        }

        return tabs;
    };

    this.updateModListTabs = function(modList, tabs) {
        tabs.forEach(function(tab) {
            switch(tab.name) {
                case 'Tools':
                    tab.count = modList.tools_count + modList.custom_tools_count;
                    break;
                case 'Mods':
                    tab.count = modList.mods_count + modList.custom_mods_count;
                    break;
                case 'Plugins':
                    tab.count = modList.plugins_count + modList.custom_plugins_count;
                    break;
                case 'Config':
                    tab.count = modList.config_files_count + modList.custom_config_files_count;
                    break;
                case 'Comments':
                    tab.count = modList.comments_count;
                    break;
            }
        });
    };

    return factory;
});
