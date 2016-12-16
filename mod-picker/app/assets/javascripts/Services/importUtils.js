app.service('importUtils', function() {
    var service = this;

    this.importTypes = [{
        selected: true,
        name: "Mod Organizer",
        image: "/images/mod_organizer_logo.png",
        modListXml: false,
        modListTxt: true,
        loadOrderTxt: true
    }, {
        selected: false,
        name: "Nexus Mod Manager",
        image: "/images/nexus_logo.png",
        modListXml: true,
        modListTxt: false,
        loadOrderTxt: true
    }, {
        selected: false,
        name: "Other",
        icon: "fa-file-text-o",
        modListXml: false,
        modListTxt: false,
        loadOrderTxt: true
    }];

    // MODLIST.XML
    this.modInfoNodeData = function (modInfoNode) {
        return {
            nexus_info_id: modInfoNode.attributes["modId"].value,
            mod_name: modInfoNode.attributes["modName"].value
        }
    };

    this.getXmlModData = function (xmlDoc) {
        var modInfoNodes = xmlDoc.getElementsByTagName("modInfo"), modData = [];
        for (var i = 0; i < modInfoNodes.length; i++) {
            modData.push(service.modInfoNodeData(modInfoNodes[i]));
        }
        return modData;
    };

    this.getXmlDoc = function (text) {
        var xmlDoc;
        if (window.DOMParser) {
            var parser = new DOMParser();
            xmlDoc = parser.parseFromString(text, "text/xml");
        } else {
            // internet explorer
            xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
            xmlDoc.async = false;
            xmlDoc.loadXml(text);
        }
        return xmlDoc;
    };

    // MODLIST.TXT
    this.txtModData = function (modData, line) {
        switch (line.charAt(0)) {
            case '#':
            case '-':
            case '*':
                return;
            case '+':
                modData.push({mod_name: line.slice(1)});
                return;
        }
    };

    this.getTxtModData = function (text) {
        var modData = [];
        text.split('\n').forEach(function (line) {
            service.txtModData(modData, line.trim());
        });
        return modData;
    };

    // LOADORDER.TXT
    this.skipLoadOrderLine = function (line) {
        return line.startsWith("GameMode=") || line.charAt(0) == '#' || line.endsWith("=0") || !line;
    };

    this.getLoadOrderPluginFilename = function (line) {
        return line.endsWith("=1") ? line.slice(0, -2) : line;
    };

    this.loadOrderPluginData = function (pluginData, line) {
        if (service.skipLoadOrderLine(line)) return;
        var plugin_filename = service.getLoadOrderPluginFilename(line);
        pluginData.push({plugin_filename: plugin_filename});
    };

    this.getLoadOrderPluginData = function (text) {
        var pluginData = [];
        text.split('\n').forEach(function (line) {
            service.loadOrderPluginData(pluginData, line.trim());
        });
        return pluginData;
    };
});