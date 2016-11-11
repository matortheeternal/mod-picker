app.controller('userSettingsProfileController', function($scope, titleQuote) {
    $scope.titleQuote = titleQuote;
    $scope.avatarSizes = [
        { label: "big",     size: 250 },
        { label: 'medium',  size: 96 },
        { label: 'small',   size: 48 }
    ];
});