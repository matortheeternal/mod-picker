app.service("filtersFactory", function() {
    var service = this;

    this.modStatisticFilters = function() {
        return [{
                label: "Endorsements",
                common: true,
                sites: { nexus: true },
                data: "endorsements",
                max: 500000,
                param: "end"
            },
            {
                label: "Subscribers",
                common: true,
                sites: { workshop: true },
                data: "subscribers",
                max: 1250000,
                param: "su"
            },
            {
                label: "Unique Downloads",
                common: true,
                sites: { nexus: true },
                data: "unique_downloads",
                max: 10000000,
                param: "ud"
            },
            {
                label: "Favorites",
                common: true,
                sites: { workshop: true, lab: true },
                data: "favorites",
                max: 20000,
                param: "fa"
            },
            {
                label: "Downloads",
                common: true,
                sites: { nexus: true, lab: true },
                data: "downloads",
                max: 50000000,
                param: "dl"
            },
            {
                label: "Views",
                common: true,
                sites: { nexus: true, workshop: true, lab: true },
                data: "views",
                max: 50000000,
                param: "vw"
            },
            {
                label: "Posts Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "posts",
                max: 500000,
                param: "pc"
            },
            {
                label: "Images Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "images",
                max: 200,
                param: "ic"
            },
            {
                label: "Videos Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "videos",
                max: 50,
                param: "vc"
            },
            {
                label: "Files Count",
                common: false,
                sites: { nexus: true },
                data: "files",
                max: 200,
                param: "fc"
            },
            /*{ TODO: Unimplemented on backend
                label: "Bugs Count",
                common: false,
                sites: {nexus: true},
                data: "bugs",
                max: 200
            },*/
            {
                label: "Discussions Count",
                common: false,
                sites: { /*nexus: true, TODO: Unimplemented on backend */ workshop: true },
                data: "discussions",
                max: 50,
                param: "dc"
            },
            {
                label: "Articles Count",
                common: false,
                sites: { nexus: true },
                data: "articles",
                max: 50,
                param: "ac"
            }
        ];
    };

    this.modPickerFilters = function() {
        return [{
                label: "Reputation",
                common: true,
                data: "reputation",
                max: 450,
                param: "rep"
            },
            {
                label: "Average Rating",
                common: true,
                data: "rating",
                max: 100,
                param: "avg"
            },
            {
                label: "Reviews Count",
                common: true,
                data: "reviews",
                max: 200,
                param: "rev"
            },
            {
                label: "Number of Stars",
                common: false,
                data: "stars",
                max: 1000,
                param: "str"
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                max: 100,
                param: "cnc"
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                max: 100,
                param: "ioc"
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                max: 100,
                param: "loc"
            }
        ];
    };

    this.modDateFilters = function() {
        return [{
                label: "Date Updated",
                data: "updated",
                param: "du"
            },
            {
                label: "Date Released",
                data: "released",
                param: "dr"
            }
        ];
    };

    this.modFilters = function() {
        return Array.prototype.concat(
            service.modStatisticFilters(),
            service.modPickerFilters(),
            service.modDateFilters()
        );
    };
});
