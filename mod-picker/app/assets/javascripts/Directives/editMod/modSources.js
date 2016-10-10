app.directive('modSources', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modSources.html',
        scope: false,
        controller: 'modSourcesController'
    }
});

app.controller('modSourcesController', function($scope, sitesFactory, scrapeService) {
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

    $scope.validateSource = function(source) {
        var site = sitesFactory.getSite(source.label);
        var sourceIndex = $scope.sources.indexOf(source);
        var sourceUsed = $scope.sources.find(function(item, index) {
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
        if (stats.released) {
            $scope.mod.released = new Date(Date.parse(stats.released));
        }
        if (stats.updated) {
            $scope.mod.updated = new Date(Date.parse(stats.updated));
        }
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

        var key = site.dataLabel;
        var baseUrl = location.href.replace(location.hash, "");
        $scope[key] = {};
        $scope[key].scraping = true;

        var successCallback = function(data) {
            $scope[key] = data;
            source.scraped = true;
            $scope.loadGeneralStats(data, true);
        };
        var failCallback = function(response) {
            delete $scope[key];
            if (response.data.mod_id) {
                $scope.$emit('customMessage', {
                    type: 'error',
                    text: "Error scraping "+source.label+" mod page, "+response.data.error,
                    url: baseUrl + "#/mod/" + response.data.mod_id
                });
            } else {
                $scope.$emit('errorMessage', {
                    label: "Error scraping "+source.label+" mod page",
                    response: response
                });
            }
        };

        var scrapeKey = "scrape" + key.capitalize();
        var scrapeFunction = scrapeService[scrapeKey];
        if (site.includeGame) {
            scrapeFunction(gameId, modId).then(successCallback, failCallback);
        } else {
            scrapeFunction(modId).then(successCallback, failCallback);
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
        if (source.id) {
            source._destroy = true;
        } else {
            $scope.customSources.splice(index, 1);
        }
    };

    $scope.validateCustomSource = function(source) {
        source.valid = (source.label.length > 4) && (source.url.length > 12);
    };
});