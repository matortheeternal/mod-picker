app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController'
        }
    );
}]);

app.filter('percentage', function() {
  return function(input) {
    if (isNaN(input)) {
      return input;
    }
    return Math.floor(input * 100) + '%';
  };
});

app.controller('modController', function ($scope, $q, $routeParams, modService, categoryService) {
    //initialization
    //of the mod object
    modService.retrieveMod($routeParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.currentVersion = mod.mod_versions[0];

        //getting the actual names of the categories
        categoryService.getCategoryById(mod.primary_category_id).then(function (data) {
            $scope.firstCategory = data.name;
        });
        categoryService.getCategoryById(mod.secondary_category_id).then(function (data) {
            $scope.secondCategory = data.name;
        });

        //setting the name of the current game for the nexus links
        if ($scope.mod.game_id === 1) {
            $scope.game = "skyrim";
        }
        else if ($scope.mod.game_id === 2) {
            $scope.game = "fallout4";
        }

        //set initial data specific to the version
        $scope.updateVersion($scope.currentVersion);

    });

    //of the tab data
    $scope.tabs = [
        { name: 'Compatibility notes', url: '/resources/partials/showMod/compatibility.html' },
        { name: 'Installation', url: '/resources/partials/showMod/installation.html' },
        { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
        { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

    //this prevents the sort by dropdowns from displaying an undefined option
    $scope.filter = 'compatibility_type';

    //variables for the stat block expandables
    $scope.nexusExpanded = false;
    $scope.steamExpanded = false;
    $scope.loversExpanded = false;

    //getting the names and ids of the required mods
    $scope.updateVersion = function (modVersion) {
        //update notes
        modService.retrieveCompatibilityNotes(modVersion.id).then(function(notes) {
            $scope.compatibilityNotes = notes;
        });
        modService.retrieveInstallOrderNotes(modVersion.id).then(function(notes) {
            $scope.installOrderNotes = notes;
        });
        modService.retrieveLoadOrderNotes(modVersion.id).then(function(notes) {
            $scope.loadOrderNotes = notes;
        });

        //update requirements
        $scope.requirements = [];
        modVersion.required_mods.forEach(function(requirement) {
            modService.retrieveMod(requirement.required_id).then(function(mod) {
                $scope.requirements.push({
                    name: mod.name,
                    id: mod.id,
                    aliases: mod.aliases
                });
            });
        });
    };
});
