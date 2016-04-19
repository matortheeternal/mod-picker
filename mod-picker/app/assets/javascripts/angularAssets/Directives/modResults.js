/**
 * Created by r79 on 2/11/2016.
 */

app.directive('modResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modResults.html',
        controller: 'modResultsController',
        scope: false
    }
});

app.controller('modResultsController', function($scope) {
    $scope.columns = [
        {
            visibility: true,
            required: true,
            label: "Mod Name",
            data: "name"
        },
        {
            visibility: true,
            label: "Authors",
            data: "nexus_infos.authors"
        },
        {
            visibility: true,
            label: "Endorsements",
            data: "nexus_infos.endorsements",
            filter: "number"
        },
        {
            visibility: true,
            label: "Unique DLs",
            data: "nexus_infos.unique_downloads",
            filter: "number"
        },
        {
            visibility: false,
            label: "Total DLs",
            data: "nexus_infos.total_downloads",
            filter: "number"
        },
        {
            visibility: false,
            label: "Views",
            data: "nexus_infos.views",
            filter: "number"
        },
        {
            visibility: false,
            label: "Posts",
            data: "nexus_infos.posts_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Videos",
            data: "nexus_infos.videos_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Images",
            data: "nexus_infos.images_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Files",
            data: "nexus_infos.files_count",
            filter: "number"
        },
        {
            visibility: false,
            label: "Released",
            data: "nexus_infos.date_added",
            filter: "date"
        },
        {
            visibility: true,
            label: "Updated",
            data: "nexus_infos.date_updated",
            filter: "date"
        }
    ];

    // TODO: Less ugly pleease
    $scope.deepValue = deepValue;

    var sortedColumn;
    $scope.sortColumn = function(index) {
        //TODO: rewrite this
        var column = $scope.columns[index];

        if(sortedColumn && sortedColumn !== column) {
            sortedColumn.up = false;
            sortedColumn.down = false;
        }
        sortedColumn = column;

        if (column.up) {
            column.up = false;
            column.down = true;
        } else if (column.down) {
            column.down = false;
        } else {
            column.up = true;
        }

        // send data to backend
        if (column.up || column.down) {
            $scope.sort.column = column.data;
            $scope.sort.direction = column.up ? "asc" : "desc";
        } else {
            delete $scope.sort.column;
            delete $scope.sort.direction;
        }
    }
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