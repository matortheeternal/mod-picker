app.directive('modSources', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modSources.html',
        scope: false,
        controller: 'modSourcesController'
    }
});

app.controller('modSourcesController', function($scope, $rootScope, sitesFactory, scrapeService) {
    $scope.addSource = function() {
        if ($scope.mod.sources.length == $scope.sites.length) return;
        $scope.mod.sources.push({
            label: "Nexus Mods",
            url: ""
        });
    };

    $scope.removeSource = function(source) {
        var index = $scope.mod.sources.indexOf(source);
        $scope.mod.sources.splice(index, 1);
    };

    $scope.validateSource = function(source) {
        var site = sitesFactory.getSite(source.label);
        var sourceIndex = $scope.mod.sources.indexOf(source);
        var sourceUsed = $scope.mod.sources.find(function(item, index) {
            return index != sourceIndex && item.label === source.label
        });
        var currentGameName = $rootScope.currentGame.nexus_name;
        var urlFormat = sitesFactory.getModUrlFormat(site, currentGameName);
        var match = source.url.match(urlFormat);
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
        var urlFormat = sitesFactory.getModUrlFormat(site, $rootScope.currentGame);
        var match = source.url.match(urlFormat);
        if (!match) {
            return;
        }

        var gameId = window._current_game_id;
        var modId = match[1];

        var key = site.dataLabel;
        var baseUrl = location.href.replace(location.href, "");
        $scope.mod[key] = {};
        $scope.mod[key].scraping = true;

        var successCallback = function(data) {
            $scope.mod[key] = data;
            source.scraped = true;
            $scope.loadGeneralStats(data, true);
        };
        var failCallback = function(response) {
            delete $scope[key];
            if (response.data.mod_id) {
                $scope.$emit('customMessage', {
                    type: 'error',
                    text: "Error scraping "+source.label+" mod page, "+response.data.error,
                    url: baseUrl + "mods/" + response.data.mod_id
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
        $scope.mod.custom_sources.push({
            label: "Custom",
            url: ""
        });
    };

    $scope.removeCustomSource = function(source) {
        var index = $scope.mod.custom_sources.indexOf(source);
        if (source.id) {
            source._destroy = true;
        } else {
            $scope.mod.custom_sources.splice(index, 1);
        }
    };

    $scope.setCustomSourceLabel = function(source) {
        var currentGameName = $rootScope.currentGame.nexus_name;
        var matchingSite = sitesFactory.getSiteFromUrl(source.url, currentGameName);
        if (matchingSite) {
            source.label = matchingSite.label;
        }
    };

    $scope.validateCustomSource = function(source) {
        source.valid = (source.label.length > 3) && (source.url.length > 12);
    };
});