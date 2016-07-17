app.service('contributionFactory', function() {
    var models = [{
        name: "Review",
        label: "Review",
        route: "reviews"
    }, {
        name: "Correction",
        label: "Correction",
        route: "corrections"
    }, {
        name: "CompatibilityNote",
        label: "Compatibility Note",
        route: "compatibility_notes",
        template: "## Description\r\n*What is the compatibility status you're recommending for the mods?  How do the mods conflict?  If there are steps the user should take resolve the compatibility issue, what are they?*\r\n\r\n## Source\r\n*What is your source for this compatiblity information?  Have you done original research, or are you repeating what other people have said?*\r\n\r\n## Reasoning\r\n*What evidence do you have to show that this is the compatibility status between the mods?  How can someone else come to the same conclusion as you?  Have you eliminated other variables in your process?  Is additional research needed?*"
    }, {
        name: "InstallOrderNote",
        label: "Install Order Note",
        route: "install_order_notes",
        template: "## Description\r\n*What is the install order you're recommending for the mods?  How do the mods conflict?  How critical is the install order you recommend?*\r\n\r\n## Reasoning\r\n*What evidence do you have to show that this install order is necessary?  How can someone else come to the same conclusion as you?*"
    }, {
        name: "LoadOrderNote",
        label: "Load Order Note",
        route: "load_order_notes",
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
