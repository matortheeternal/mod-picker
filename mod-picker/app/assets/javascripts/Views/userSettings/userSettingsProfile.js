app.controller('userSettingsProfileController', function($scope, titleQuote) {
    $scope.titleQuote = titleQuote;
    $scope.defaultSrc = $scope.user.avatar || '/users/' + $scope.user.title + '.png';
    $scope.avatar = {
        src: $scope.defaultSrc
    };
});