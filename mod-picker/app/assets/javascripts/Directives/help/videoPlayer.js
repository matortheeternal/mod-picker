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

app.controller('videoPlayerController', function($scope, $sce) {
    $scope.player = new YT.Player('player', {});

    $scope.setUrl = function() {
        var url = "https://www.youtube.com/embed/" + encodeURIComponent($scope.youtubeId) + "?enablejsapi=1";
        $scope.videoUrl = $sce.trustAsResourceUrl(url);
    };

    $scope.$watch('youtubeId', $scope.setUrl);

    $scope.$on('videoSections', function(event, sections) {
        $scope.sections = sections;
    });

    $scope.$on('navigateTo', function(event, seconds) {
        $scope.player.seekTo(seconds, true);
        $scope.player.playVideo();
    });
});