app.controller('bodyController', function($scope, $rootScope) {
    //this controls the no-scroll class on the page body
    $rootScope.$on('toggleModal', function(event, visible) {
        $scope.modalVisible = visible;
    });
});