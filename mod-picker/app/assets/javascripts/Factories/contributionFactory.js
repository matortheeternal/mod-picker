app.service('contributionFactory', function() {
    var factory = this;

    var models = [{
        name: "Appeal",
        label: "Appeals",
        route: "corrections",
        template: "## Description\n*Why should the mod have this new status?  What has changed from the past, if anything?  If suggesting the mod be marked as unstable, explain what aspects of the mod are unstable and the severity of the issues.  If suggesting the mod be marked as outdated note the issues with this mod and the available alternatives.*\n"
    },
    {
        name: "CuratorRequest",
        label: "Curator Request",
        route: "curator_requests",
        template: "## Description\n*Why do you want to become a curator for this mod?  How much do you use this mod?  How much do you know about how this mod works?  How important is this mod to you?  Do you have the time and energy to curate this mod?  Is there anything specific you'd like to improve on this mod page immediately upon becoming a curator for it?*"
    },
    {
        name: "Review",
        label: "Review",
        route: "reviews",
        tab: "reviews"
    }, {
        name: "Correction",
        label: "Correction",
        route: "corrections",
        template: "## Description\n*What is is incorrect, inaccurate, or in need of improvement?*\n"
    }, {
        name: "CompatibilityNote",
        label: "Compatibility Note",
        route: "compatibility_notes",
        tab: "compatibility",
        template: "## Description\n*What is the compatibility status you're recommending for the mods?  How do the mods conflict?  If there are steps the user should take resolve the compatibility issue, what are they?*\n## Source\n*What is your source for this compatibility information?  Have you done original research, or are you repeating what other people have said?*\n## Reasoning\n*What evidence do you have to show that this is the compatibility status between the mods?  How can someone else come to the same conclusion as you?  Have you eliminated other variables in your process?  Is additional research needed?*"
    }, {
        name: "InstallOrderNote",
        label: "Install Order Note",
        route: "install_order_notes",
        tab: "install-order",
        template: "## Description\n*What is the install order you're recommending for the mods?  How do the mods conflict?  How critical is the install order you recommend?*\n## Reasoning\n*What evidence do you have to show that this install order is necessary?  How can someone else come to the same conclusion as you?*"
    }, {
        name: "LoadOrderNote",
        label: "Load Order Note",
        route: "load_order_notes",
        tab: "load-order",
        template: "## Description\n*What is the load order you're recommending for the mods?  How do the plugins conflict?  How critical is the load order you recommend?*\n## Reasoning\n*What evidence do you have to show that this load order is necessary?  How can someone else come to the same conclusion as you?*"
    }, {
            name: "RelatedModNote",
            label: "Related Mod Note",
            route: "related_mod_notes",
            tab: "related-mods",
            template: "## Description\n*For alternatives: What makes these mods similar, and what are their differences?\nFor recommendations: Why do these mods work well together?*"
    }];

    this.getDefaultTextBody = function(name) {
        var text_body = models.find(function(model) {
            return model.name === name;
        }).template;
        return text_body.replace(/\*([^\*]+)\*/g, function(prompt) {
            return factory.preparePrompt(prompt, true);
        });
    };

    this.preparePrompt = function(prompt, skipStars) {
        var s = skipStars ? '' : '*';
        return s + prompt.replace(/\ /g, '\uFEFF ') + s + '\n\n';
    };

    this.getModel = function(name) {
        return models.find(function(model) {
            return model.name === name;
        });
    };
});
