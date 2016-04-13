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
            label: "Authors",
            data: "authors"
        },
        {
            visibility: true,
            label: "Endorsements",
            data: "endorsements",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: true,
            label: "Unique DL/s",
            data: "unique_downloads",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: false,
            label: "Total DL/s",
            data: "total_downloads",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: false,
            label: "Views",
            data: "views",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: false,
            label: "Posts",
            data: "posts_count",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: false,
            label: "Videos",
            data: "videos_count",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: false,
            label: "Images",
            data: "images_count",
            filter: "number",
            filter_arg: 0
        },
        {
            visibility: false,
            label: "Files",
            data: "files_count",
            filter: "number",
            filter_arg: 0
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