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
                modUrlFormat: /(http[s]:\/\/?)?www\.nexusmods\.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i,
                userUrlFormat: /(http[s]:\/\/?)?forums\.nexusmods\.com\/index\.php\?showuser=([0-9]+)(\/)?/i,
                modUrlBase: "https://www.nexusmods.com/skyrim/mods/{id}",
                userIndex: 2,
                loginUrl: "https://forums.nexusmods.com/",
                logoPath: "/images/nexus_logo.png"
            },
            {
                label: "Steam Workshop",
                shortLabel: "Steam",
                modUrlFormat: /(http[s]:\/\/?)?steamcommunity\.com\/sharedfiles\/filedetails\/\?id=([0-9]+)(\&)?.*/i,
                userUrlFormat: /(http[s]:\/\/?)?steamcommunity\.com\/(id|profiles)\/([A-Za-z0-9\_]+)(\/)?/i,
                modUrlBase: "https://steamcommunity.com/sharedfiles/filedetails/?id={id}",
                userIndex: 3,
                loginUrl: "https://steamcommunity.com/login/",
                logoPath: "/images/workshop_logo.png"
            },
            {
                label: "Lover's Lab",
                shortLabel: "Lab",
                modUrlFormat: /(http[s]:\/\/?)?www\.loverslab\.com\/files\/file\/([0-9]+)\-([0-9a-z\-]+)(\/)?/i,
                userUrlFormat: /(http[s]:\/\/?)?www\.loverslab\.com\/index\.php\?\/user\/([A-Za-z0-9\-]+)(\/)?/i,
                modUrlBase: "https://www.loverslab.com/files/file/{id}",
                userIndex: 2,
                loginUrl: "https://www.loverslab.com/",
                logoPath: "/images/lab_logo.png"
            },
            {
                hidden: true,
                label: "Steam Store",
                shortLabel: "Steam",
                logoPath: "/images/workshop_logo.png"
            },
            {
                hidden: true,
                label: "GitHub",
                shortLabel: "GitHub",
                logoPath: "/images/github_logo.png"
            }
        ];
    };

    this.customSite = function() {
        return {
            label: "",
            shortLabel: "Custom",
            logoPath: "/images/custom_logo.png"
        };
    };

    this.getSite = function(label) {
        var sites = this.sites();
        return sites.find(function(site) {
            return site.label === label;
        }) || this.customSite();
    };

    this.getModUrl = function(label, id) {
        var site = this.getSite(label);
        return site.modUrlBase.replace("{id}", id);
    };

    this.getLinkSteps = function(label) {
        switch(label) {
            case 'Steam Workshop':
                return [
                    'Navigate to your steam profile page.',
                    'Post a comment on your profile with the verification key provided below.',
                    'Temporarily set your profile to public if it is private.',
                    'Copy the web address of your profile page into the Profile URL input below.',
                    'Click the Verify button.'
                ];
            default:
                return [
                    'Navigate to your public forum profile page.',
                    'Post a status update with the verification key provided below.',
                    'Copy the web address of your profile page into the Profile URL input below.',
                    'Click the Verify button.'
                ];
        }
    }
});