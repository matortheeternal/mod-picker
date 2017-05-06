// Used to validate the website urls for user profiles + mods
// ALSO, used to grab their username/id number from the url to validate their
// accounts

// userIndex is the regex group to capture to get the user's username/id
app.service('sitesFactory', function() {
    var factory = this;

    this.sites = [
        {
            label: "Nexus Mods",
            shortLabel: "Nexus",
            dataLabel: "nexus",
            includeGame: true,
            modUrlFormat: "www\.nexusmods\.com\/\[game\]\/mods\/([0-9]+)(\/\?)?",
            baseUserUrlFormat: "https://forums.nexusmods.com/index.php?showuser=",
            userUrlFormat: /forums\.nexusmods\.com\/index\.php\?showuser=([0-9]+)(\/)?/i,
            badUserUrlFormat: /forums\.nexusmods\.com\/index\.php\?\/user\/([A-Za-z0-9\-]+)(\/)?/i,
            modUrlBase: "http://www.nexusmods.com/{game}/mods/{id}",
            userIndex: 1,
            loginUrl: "https://forums.nexusmods.com/",
            logoPath: "/images/nexus_logo.png"
        },
        {
            label: "Steam Workshop",
            shortLabel: "Steam",
            dataLabel: "workshop",
            modUrlFormat: /steamcommunity\.com\/sharedfiles\/filedetails\/\?id=([0-9]+)(\&)?.*/i,
            userUrlFormat: /steamcommunity\.com\/(id|profiles)\/([A-Za-z0-9\_]+)(\/)?/i,
            modUrlBase: "https://steamcommunity.com/sharedfiles/filedetails/?id={id}",
            userIndex: 2,
            loginUrl: "https://steamcommunity.com/login/",
            logoPath: "/images/workshop_logo.png"
        },
        {
            label: "Lover's Lab",
            shortLabel: "Lab",
            dataLabel: "lab",
            modUrlFormat: /www\.loverslab\.com\/files\/file\/([0-9]+)\-([0-9a-z\-]+)(\/)?/i,
            userUrlFormat: /www\.loverslab\.com\/user\/([a-zA-Z0-9\-]+)(\/)?/i,
            modUrlBase: "https://www.loverslab.com/files/file/{id}",
            userIndex: 1,
            loginUrl: "https://www.loverslab.com/",
            logoPath: "/images/lab_logo.png"
        },
        {
            hidden: true,
            label: "Steam Store",
            shortLabel: "Steam",
            modUrlFormat: /store\.steampowered\.com\/app\/([0-9]+)/i,
            logoPath: "/images/workshop_logo.png"
        },
        {
            hidden: true,
            label: "GitHub",
            shortLabel: "GitHub",
            modUrlFormat: /github.com\/([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)/i,
            logoPath: "/images/github_logo.png"
        },
        {
            hidden: true,
            label: "Tumblr",
            shortLabel: "Tumblr",
            modUrlFormat: /([a-zA-Z0-9\-\_]+)\.tumblr\.com\/post\/([0-9]+)/i,
            logoPath: "/images/tumblr_logo.png"
        },
        {
            hidden: true,
            label: "Blogspot",
            shortLabel: "Blogspot",
            modUrlFormat: /([a-zA-Z0-9\-\_]+)\.blogspot\.(com|ca)\/([0-9]+)\/([0-9]+)\/([a-zA-Z\-]+)/i,
            logoPath: "/images/blogger_logo.png"
        },
        {
            hidden: true,
            label: "Imgur",
            shortLabel: "Imgur",
            modUrlFormat: /imgur\.com\/([0-9a-zA-Z]+)/i,
            logoPath: "/images/imgur_logo.png"
        },
        {
            hidden: true,
            label: "Google Site",
            shortLabel: "Google Site",
            modUrlFormat: /sites\.google\.com\/site\/([0-9a-zA-Z\-]+)/i,
            logoPath: "/images/google_logo.png"
        },
        {
            hidden: true,
            label: "Skyrim Modtype",
            shortLabel: "Skyrim Modtype",
            modUrlFormat: /modtype\.doorblog\.jp\/archives\/([0-9]+)\.html/i,
            logoPath: "/images/skyrim_modtype_logo.png"
        },
        {
            hidden: true,
            label: "ModDB",
            shortLabel: "ModDB",
            modUrlFormat: /moddb\.com\/mods\/([a-zA-Z\-]+)/i,
            logoPath: "/images/moddb_logo.png"
        },
        {
            hidden: true,
            label: "Curse",
            shortLabel: "Curse",
            modUrlFormat: /mods\.curse\.com\/mods\/([a-zA-Z0-9\-]+)\/([a-zA-Z0-9\-]+)/i,
            logoPath: "/images/curse_logo.png"
        },
        {
            hidden: true,
            label: "TES Alliance",
            shortLabel: "TES Alliance",
            modUrlFormat: /tesalliance\.org\/forums\/index\.php\?\/files\/file\/([a-zA-Z0-9\-]+)/i,
            logoPath: "/images/tes_alliance_logo.png"
        }
    ];

    this.customSite = function() {
        return {
            label: "",
            shortLabel: "Custom",
            logoPath: "/images/custom_logo.png"
        };
    };

    this.getSite = function(label) {
        return factory.sites.find(function(site) {
            return site.label === label;
        }) || this.customSite();
    };

    this.getSiteFromUrl = function(url, gameName) {
        return factory.sites.find(function(site) {
            var urlFormat = factory.getModUrlFormat(site, gameName);
            return url.match(urlFormat);
        });
    };

    this.getModUrl = function(label, id, gameName) {
        var site = factory.getSite(label);
        return site.modUrlBase.replace("{id}", id).replace("{game}", gameName);
    };

    this.getModUrlFormat = function(site, gameName) {
        if (site.dataLabel === "nexus") {
            return new RegExp(site.modUrlFormat.replace("[game]", gameName), "i");
        } else {
            return site.modUrlFormat;
        }
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
                    'Go to the profile feed section.',
                    'Post a status update with the verification key provided below.',
                    'Copy the web address of your profile page into the Profile URL input.',
                    'Click the Verify button.'
                ];
        }
    }
});