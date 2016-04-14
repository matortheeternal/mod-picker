/**
 * Created by r79 on 2/11/2016.
 */

app.directive('modResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modResults.html',
        controller: 'modResultsController',
        scope: {
            data: '='
        }
    }
});

app.controller('modResultsController', function($scope) {
    $scope.columns = [
        {
            visibility: true,
            toggleable: false,
            label: "Mod Name",
            data: "mod_name"
        },
        {
            visibility: true,
            label: "Authors",
            data: "authors"
        },
        {
            visibility: true,
            label: "Endorsements",
            data: "endorsements",
            filter: "number"
        },
        {
            visibility: true,
            label: "Unique DL/s",
            data: "unique_downloads",
            filter: "number"
        },
        {
            visibility: false,
            label: "Total DL/s",
            data: "total_downloads",
            filter: "number"
        },
        {
            visibility: false,
            label: "Views",
            data: "views",
            filter: "number"
        },
        {
            visibility: false,
            label: "Posts",
            data: "posts_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Videos",
            data: "videos_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Images",
            data: "images_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Files",
            data: "files_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Released",
            data: "date_added",
            filter: "date"
        },
        {
            visibility: true,
            label: "Updated",
            data: "date_updated",
            filter: "date"
        }
    ];
});

app.filter('picker', function($filter) {
    return function() {
        var filterName = [].splice.call(arguments, 1, 1)[0];
        if (!filterName) {
            return arguments[0];
        }
        else {
            return $filter(filterName).apply(null, arguments);
        }
    };
});