// Used to validate the website urls for user profiles + mods
// ALSO, used to grab their username/id number from the url to validate their
// accounts

// userIndex is the regex group to capture to get the user's username/id
app.service('sitesFactory', function () {
    this.sites = function() {
        return [
            {
                label: "Nexus Mods",
                shortLabel: "Nexus",
                modUrlFormat: /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i,
                userUrlFormat: /(http[s]:\/\/?)?forums.nexusmods.com\/index.php\?\/user\/([A-Za-z0-9\-]+)(\/)?/i,
                userIndex: 2,
                loginUrl: "https://forums.nexusmods.com/",
                logoPath: "/assets/nexus_logo"
            },
            {
                label: "Steam Workshop",
                shortLabel: "Steam",
                modUrlFormat: /(http[s]:\/\/?)?steamcommunity.com\/sharedfiles\/filedetails\/\?id=([0-9]+)(\&)?.*/i,
                userUrlFormat: /(http[s]:\/\/?)?steamcommunity.com\/(id|profiles)\/([A-Za-z0-9\_]+)(\/)?/i,
                userIndex: 3,
                loginUrl: "https://steamcommunity.com/login/",
                logoPath: "/assets/workshop_logo"
            },
            {
                label: "Lover's Lab",
                shortLabel: "Lab",
                modUrlFormat: /(http[s]:\/\/?)?www.loverslab.com\/files\/file\/([0-9]+)\-([0-9a-z\-]+)(\/)?/i,
                userUrlFormat: /(http[s]:\/\/?)?www.loverslab.com\/index.php\?\/user\/([A-Za-z0-9\-]+)(\/)?/i,
                userIndex: 2,
                loginUrl: "https://www.loverslab.com/",
                logoPath: "/assets/lab_logo"
            },
            {
                hidden: true,
                label: "Steam Store",
                shortLabel: "Steam",
                logoPath: "/assets/workshop_logo"
            }
        ];
    };

    this.customSite = function() {
        return {
            label: "",
            shortLabel: "Custom",
            logoPath: "/assets/custom_logo"
        };
    };

    this.getSite = function(label) {
        var sites = this.sites();
        return sites.find(function(site) {
            return site.label === label;
        }) || this.customSite();
    };
});