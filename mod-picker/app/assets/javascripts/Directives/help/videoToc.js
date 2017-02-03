app.directive('videoToc', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/help/videoToc.html',
        controller: 'videoTocController',
        scope: {
            videoId: '='
        }
    };
});

app.controller('videoTocController', function($scope, $rootScope, helpVideoSectionService) {
    var activeSection;

    $scope.retrieveToc = function() {
        helpVideoSectionService.retrieveSections($scope.videoId).then(function(data) {
            $scope.sections = data.sections;
            $rootScope.$broadcast('videoSections', data.sections);
        }, function(response) {
            $scope.$emit('errorMessage', {
                text: 'Error retrieving help video sections.',
                response: response
            });
        })
    };

    $scope.toggleActiveSection = function(section) {
        if (activeSection) activeSection.active = false;
        activeSection = section;
        section.active = true;
    };

    $scope.navigateTo = function(section) {
        $scope.toggleActiveSection(section);
        $rootScope.$broadcast('navigateTo', section.seconds);
    };

    $scope.retrieveToc();
});