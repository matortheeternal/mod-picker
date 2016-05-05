app.service('sitesFactory', function () {
    this.sites = function() {
        return [
            {
                label: "Nexus Mods",
                expr: /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i
            },
            {
                label: "Steam Workshop",
                expr: /(http[s]:\/\/?)?steamcommunity.com\/sharedfiles\/filedetails\/\?id=([0-9]+)(\&)?.*/i
            },
            {
                label: "Lover's Lab",
                expr: /(http[s]:\/\/?)?www.loverslab.com\/files\/file\/([0-9a-z\-]+)(\/)?/i
            }
        ];
    }
});