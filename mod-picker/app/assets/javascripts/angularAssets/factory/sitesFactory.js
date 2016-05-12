app.service('sitesFactory', function () {
    this.sites = function() {
        return [
            {
                label: "Nexus Mods",
                modUrlFormat: /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i,
                userUrlFormat: /(http[s]:\/\/?)?forums.nexusmods.com\/index.php\?\/user\/([0-9]+)\-([A-Za-z0-9\-]+)(\/)?/i
            },
            {
                label: "Steam Workshop",
                modUrlFormat: /(http[s]:\/\/?)?steamcommunity.com\/sharedfiles\/filedetails\/\?id=([0-9]+)(\&)?.*/i,
                userUrlFormat: /(http[s]:\/\/?)?steamcommunity.com\/id\/([A-Za-z0-9\_]+)(\/)?/i
            },
            {
                label: "Lover's Lab",
                modUrlFormat: /(http[s]:\/\/?)?www.loverslab.com\/files\/file\/([0-9]+)\-([0-9a-z\-]+)(\/)?/i,
                userUrlFormat: /(http[s]:\/\/?)?www.loverslab.com\/index.php\?\/user\/([0-9]+)\-([A-Za-z0-9\-]+)(\/)?/i
            }
        ];
    };

    this.getSite = function(sites, label) {
        return sites.find(function(site) {
            return site.label === label;
        });
    };
});