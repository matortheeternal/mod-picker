app.directive('videoPlayer', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/help/videoPlayer.html',
        controller: 'videoPlayerController',
        scope: {
            youtubeId: '@'
        },
        link: function(scope) {
            scope.width = window.screen.width - 450;
            scope.height = Math.ceil((9 * scope.width) / 16);
        },
        priority: 200
    };
});

app.controller('videoPlayerController', function($scope, $rootScope, $sce, $timeout) {
    $scope.setupPlayer = function() {
        $scope.player = new YT.Player('player', {
            events: {
                'onReady': function() {
                    $scope.tracker = setInterval($scope.trackTime, 200);
                }
            }
        });
    };

    $scope.setUrl = function() {
        var url = "https://www.youtube.com/embed/" + encodeURIComponent($scope.youtubeId) + "?enablejsapi=1";
        $scope.videoUrl = $sce.trustAsResourceUrl(url);
    };

    $scope.setActiveSection = function(newActiveSection) {
        $scope.activeSection = newActiveSection;
        $rootScope.$broadcast('setActiveSection', newActiveSection.id);
    };

    $scope.getCurrentSection = function() {
        var nextSectionIndex = $scope.sections.findIndex(function(section) {
            return section.seconds > $scope.videoTime;
        });
        return nextSectionIndex > 0 && $scope.sections[nextSectionIndex - 1];
    };

    $scope.playerProgress = function() {
        if (!$scope.sections) return;
        var currentSection = $scope.getCurrentSection();
        if (!$scope.activeSection || !currentSection || $scope.activeSection.id !== currentSection.id) {
            $scope.setActiveSection(currentSection);
        }
    };

    $scope.trackTime = function() {
        if (!$scope.player || !$scope.videoUrl) return;
        $scope.oldTime = $scope.videoTime;
        $scope.videoTime = $scope.player.getCurrentTime();
        if ($scope.videoTime !== $scope.oldTime) {
            $scope.playerProgress();
        }
    };

    try {
        $scope.setupPlayer();
    } catch (e) {
        $timeout($scope.setupPlayer);
    }

    $scope.$watch('youtubeId', $scope.setUrl);

    $scope.$on('videoSections', function(event, sections) {
        $scope.sections = sections;
    });

    $scope.$on('navigateTo', function(event, seconds) {
        $scope.player.seekTo(seconds, true);
        $scope.player.playVideo();
    });
});