app.directive('modSources', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modSources.html',
        scope: false,
        controller: 'modSourcesController'
    }
});

app.controller('modSourcesController', function ($scope, sitesFactory, scrapeService) {
    $scope.addSource = function() {
        if ($scope.sources.length == $scope.sites.length)
            return;
        $scope.sources.push({
            label: "Nexus Mods",
            url: ""
        });
    };

    $scope.removeSource = function(source) {
        var index = $scope.sources.indexOf(source);
        $scope.sources.splice(index, 1);
    };

    $scope.validateSource = function (source) {
        var site = sitesFactory.getSite(source.label);
        var sourceIndex = $scope.sources.indexOf(source);
        var sourceUsed = $scope.sources.find(function (item, index) {
            return index != sourceIndex && item.label === source.label
        });
        var match = source.url.match(site.modUrlFormat);
        source.valid = !sourceUsed && match != null;
    };

    $scope.loadGeneralStats = function(stats, override) {
        if ($scope.mod.name && !override) {
            return;
        }

        // load the stats
        $scope.mod.name = stats.mod_name;
        $scope.mod.authors = stats.authors || stats.uploaded_by;
        $scope.mod.released = new Date(Date.parse(stats.released));
        $scope.mod.updated = new Date(Date.parse(stats.updated));
    };

    $scope.scrapeSource = function(source) {
        // exit if the source is invalid
        var site = sitesFactory.getSite(source.label);
        var match = source.url.match(site.modUrlFormat);
        if (!match) {
            return;
        }

        var gameId = window._current_game_id;
        var modId = match[2];
        source.scraped = true;
        switch (source.label) {
            case "Nexus Mods":
                $scope.nexus = {};
                $scope.nexus.scraping = true;
                scrapeService.scrapeNexus(gameId, modId).then(function (data) {
                    $scope.nexus = data;
                    $scope.loadGeneralStats(data, true);
                });
                break;
            case "Lover's Lab":
                $scope.lab = {};
                $scope.lab.scraping = true;
                scrapeService.scrapeLab(modId).then(function (data) {
                    $scope.lab = data;
                    $scope.loadGeneralStats(data);
                });
                break;
            case "Steam Workshop":
                $scope.workshop = {};
                $scope.workshop.scraping = true;
                scrapeService.scrapeWorkshop(modId).then(function (data) {
                    $scope.workshop = data;
                    $scope.loadGeneralStats(data);
                });
                break;
        }
    };

    /* custom sources */
    $scope.addCustomSource = function() {
        $scope.customSources.push({
            label: "Custom",
            url: ""
        });
    };

    $scope.removeCustomSource = function(source) {
        var index = $scope.customSources.indexOf(source);
        $scope.customSources.splice(index, 1);
    };

    $scope.validateCustomSource = function(source) {
        source.valid = (source.label.length > 4) && (source.url.length > 12);
    };
});