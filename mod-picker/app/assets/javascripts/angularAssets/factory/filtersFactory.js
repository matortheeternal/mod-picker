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
    };

    this.modPickerFilters = function() {
        return [
            {
                label: "Reputation",
                common: true,
                data: "reputation",
                max: 450
            },
            {
                label: "Average Rating",
                common: true,
                data: "rating",
                max: 100
            },
            {
                label: "Reviews Count",
                common: true,
                data: "reviews",
                max: 200
            },
            {
                label: "Number of Stars",
                common: false,
                data: "stars",
                max: 1000
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                max: 100
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                max: 100
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                max: 100
            }
        ]
    };

    this.modDateFilters = function() {
        return [
            {
                label: "Date Updated",
                data: "updated"
            },
            {
                label: "Date Released",
                data: "released"
            }
        ]
    }
});