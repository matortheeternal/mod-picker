app.factory("tabsFactory", function() {
    var factory = this;

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
            // utilities don't have an install order
            if (!mod.is_utility) {
                tabs.push({
                    name: 'Install Order',
                    count: mod.install_order_notes_count
                });
            }
            // mods with no plugins don't have load order notes
            if (!mod.plugins_count) {
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

    return factory;
});
