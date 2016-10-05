app.directive('modAuthors', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modAuthors.html',
        scope: false,
        controller: 'modAuthorsController'
    }
});

app.controller('modAuthorsController', function($scope) {
    $scope.addAuthor = function() {
        $scope.mod.mod_authors.push({
            role: "author",
            user: {}
        });
    };

    $scope.removeAuthor = function(author) {
        if (author.id) {
            author._destroy = true;
        } else {
            var index = $scope.mod.mod_authors.indexOf(author);
            $scope.mod.mod_authors.splice(index, 1);
        }
    };
});