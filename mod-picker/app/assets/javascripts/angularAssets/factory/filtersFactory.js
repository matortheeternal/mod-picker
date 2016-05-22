app.service('filtersFactory', function () {
    this.modStatisticFilters = function() {
        return [
            {
                label: "Endorsements",
                common: true,
                sites: {nexus: true},
                data: "endorsements",
                max: 500000
            },
            {
                label: "Subscribers",
                common: true,
                sites: {workshop: true},
                data: "subscribers",
                max: 1250000
            },
            {
                label: "Unique Downloads",
                common: true,
                sites: {nexus: true},
                data: "unique_downloads",
                max: 10000000
            },
            {
                label: "Favorites",
                common: true,
                sites: {workshop: true, lab: true},
                data: "favorites",
                max: 20000
            },
            {
                label: "Views",
                common: true,
                sites: {nexus: true, workshop: true, lab: true},
                data: "views",
                max: 50000000
            },
            {
                label: "Posts Count",
                common: false,
                sites: {nexus: true, workshop: true},
                data: "posts",
                max: 500000
            },
            {
                label: "Images Count",
                common: false,
                sites: {nexus: true, workshop: true},
                data: "endorsements",
                max: 500000
            },
            {
                label: "Videos Count",
                common: false,
                sites: {nexus: true, workshop: true},
                data: "videos",
                max: 50
            },
            {
                label: "Files Count",
                common: false,
                sites: {nexus: true},
                data: "files",
                max: 200
            },
            {
                label: "Bugs Count",
                common: false,
                sites: {nexus: true},
                data: "endorsements",
                max: 200
            },
            {
                label: "Discussions Count",
                common: false,
                sites: {nexus: true, workshop: true},
                data: "endorsements",
                max: 50
            },
            {
                label: "Articles Count",
                common: false,
                sites: {nexus: true},
                data: "endorsements",
                max: 50
            }
        ];
    }
});