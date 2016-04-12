app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController'
        }
    );
}]);

app.controller('modController', function ($scope, $filter, $q, $routeParams, modService) {
    useTwoColumns(true);
    $scope.expandedState = {
        compabilityNotes: true,
        reviews: false
    };

    $scope.tabs = [
    { name: 'Compatibility', url: '/resources/partials/showMod/compatibility.html' },
    { name: 'Installation', url: '/resources/partials/showMod/installation.html' },
    { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
    { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

    modService.retrieveMod($routeParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.changeVersion(mod.mod_versions[0].id);
        $scope.version = mod.mod_versions[0].id;
    });

    $scope.showReviews = function () {
        $scope.expandedState = {
            reviews: true
        };
    };

    $scope.changeVersion = function(version) {
        if(version && version !== $scope.version && $scope.mod.id) {
            delete $scope.compabilityNotes;
            //$scope.loading = true;
            modService.retrieveCompabilityNotes($scope.mod.id, version).then(function (compatibilityNotes) {
                $scope.compatibilityNotes = compatibilityNotes;
            });
        }
    };

    //setting the table data for the Nexus Stats table
/*    $scope.nexusRows = [
        { title: 'Unique Downloads', data: $scope.mod.nexus_info.unique_downloads},
        { title: 'Endorsements', data: $scope.mod.nexus_info.endorsements},
        { title: 'Endorse Rate', data: $scope.$filter('number')($scope.mod.nexus_info.endorsements/$scope.mod.nexus_info.unique_downloads * 100, 0) + '%'},
        { title: 'Release Date', data: $scope.mod.nexus_info.date_added},
        { title: 'Last Updated', data: $scope.mod.nexus_info.date_updated},
        { title: 'Total Downloads', data: $scope.mod.nexus_info.total_downloads},
        { title: 'Views', data: $scope.mod.nexus_info.views},
        { title: 'Uploaded By', data: $scope.mod.nexus_info.uploaded_by},
        { title: 'Posts', data: $scope.mod.nexus_info.posts_count},
        { title: 'Videos', data: $scope.mod.nexus_info.videos_count},
        { title: 'Images', data: $scope.mod.nexus_info.images_count},
        { title: 'Files', data: $scope.mod.nexus_info.files_count},
        { title: 'Articles', data: $scope.mod.nexus_info.articles_count},
        { title: 'Nexus Category', data: $scope.mod.nexus_info.nexus_category},
    ];
*/
    $scope.nexusRows = [
        { title: 'Unique Downloads', data: 1000},
        { title: 'Endorsements', data: 100},
        { title: 'Endorse Rate', data: $filter('number')(100/1001 * 100, 0) + '%'}
    ];
});
