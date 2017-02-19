app.controller('helpVideoSectionsController', function($scope) {
    $scope.sections = [];

    $scope.removeSection = function(section) {
        if (section.id) {
            section._destroy = true;
        } else {
            var index = $scope.sections.indexOf(section);
            $scope.sections.splice(index, 1);
        }
    };

    $scope.addSection = function() {
        $scope.sections.push({
            label: "",
            description: "",
            seconds: 0
        });
    }
});