app.directive('modListAuthors', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modListAuthors.html',
        scope: false,
        controller: 'modListAuthorsController'
    }
});

app.controller('modListAuthorsController', function($scope) {
    $scope.addAuthor = function() {
        $scope.mod_list.mod_list_authors.push({
            role: "author",
            user: {}
        });
    };

    $scope.removeAuthor = function(author) {
        if (author.id) {
            author._destroy = true;
        } else {
            var index = $scope.mod_list.mod_list_authors.indexOf(author);
            $scope.mod_list.mod_list_authors.splice(index, 1);
        }
    };
});