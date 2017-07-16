app.directive('modListAuthors', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modListAuthors.html',
        scope: false,
        controller: 'modListAuthorsController'
    }
});

app.controller('modListAuthorsController', function($scope) {
    var authors = $scope.mod_list.mod_list_authors;

    $scope.addAuthor = function() {
        authors.push({
            role: "author",
            user: {}
        });
    };

    $scope.removeAuthor = function(author) {
        if (author.id) {
            author._destroy = true;
        } else {
            var index = authors.indexOf(author);
            authors.splice(index, 1);
        }
    };
});