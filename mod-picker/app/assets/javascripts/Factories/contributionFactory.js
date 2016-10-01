app.service('contributionFactory', function() {
    var models = [{
        name: "Appeal",
        label: "Appeals",
        route: "corrections",
        template: "## Description\r\n*Why should the mod have this new status?  What has changed from the past, if anything?  If suggesting the mod be marked as unstable, explain what aspects of the mod are unstable and the severity of the issues.  If suggesting the mod be marked as outdated note the issues with this mod and the available alternatives.*\r\n\r\n"
    }, {
        name: "Review",
        label: "Review",
        route: "reviews",
        tab: "reviews"
    }, {
        name: "Correction",
        label: "Correction",
        route: "corrections",
        template: "## Description\r\n*What is is incorrect, inaccurate, or in need of improvement?*\r\n\r\n"
    }, {
        name: "CompatibilityNote",
        label: "Compatibility Note",
        route: "compatibility_notes",
        tab: "compatibility",
        template: "## Description\r\n*What is the compatibility status you're recommending for the mods?  How do the mods conflict?  If there are steps the user should take resolve the compatibility issue, what are they?*\r\n\r\n## Source\r\n*What is your source for this compatiblity information?  Have you done original research, or are you repeating what other people have said?*\r\n\r\n## Reasoning\r\n*What evidence do you have to show that this is the compatibility status between the mods?  How can someone else come to the same conclusion as you?  Have you eliminated other variables in your process?  Is additional research needed?*"
    }, {
        name: "InstallOrderNote",
        label: "Install Order Note",
        route: "install_order_notes",
        tab: "install-order",
        template: "## Description\r\n*What is the install order you're recommending for the mods?  How do the mods conflict?  How critical is the install order you recommend?*\r\n\r\n## Reasoning\r\n*What evidence do you have to show that this install order is necessary?  How can someone else come to the same conclusion as you?*"
    }, {
        name: "LoadOrderNote",
        label: "Load Order Note",
        route: "load_order_notes",
        tab: "load-order",
        template: "## Description\r\n*What is the load order you're recommending for the mods?  How do the plugins conflict?  How critical is the load order you recommend?*\r\n\r\n## Reasoning\r\n*What evidence do you have to show that this load order is necessary?  How can someone else come to the same conclusion as you?*"
    }];

    this.getDefaultTextBody = function(name) {
        return models.find(function(model) {
            return model.name === name;
        }).template;
    };

    this.getModel = function(name) {
        return models.find(function(model) {
            return model.name === name;
        });
    };
});
