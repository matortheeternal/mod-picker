app.controller('bodyController', function($scope, $rootScope) {
    //this controls the no-scroll class on the page body
    $rootScope.$on('toggleModal', function(event, visible) {
        $scope.modalVisible = visible;
    });

    //when the state is changed away from a modal toggle modals off
    $rootScope.$on('$stateChangeSuccess', function(event) {
        if($scope.modalVisible) {
          $scope.modalVisible = false;
        }
    });
});
