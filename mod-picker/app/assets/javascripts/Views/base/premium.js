app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.premium', {
        templateUrl: '/resources/partials/base/premium.html',
        controller: 'premiumController',
        url: '/premium'
    });
}]);

app.controller('premiumController', function($scope, $rootScope, userService, helpFactory) {
    $scope.$emit('setPageTitle', 'Get Premium');
    helpFactory.setHelpContexts($scope, []);

    // initialize variables
    $scope.showOptions = true;
    $scope.showFree = false;
    $scope.showPurchase = false;

    // premium options
    $scope.premiumOptions = $rootScope.premiumOptions;

    // helper functions
    var startPurchase = function(option) {
        paymentService.createPayment(option).then(function(data) {
            $scope.showPurchase = true;
            $scope.paymentUrl = data.url;
            $scope.selectedOption = option;
        });
    };

    // reputation retrieval
    $scope.retrieveReputation = function() {
        userService.retrieveReputation().then(function(data) {
            var rep = data;
            $scope.availableRep = rep.contribution_rep - rep.spent_rep;
            $scope.availableMonths = Math.floor($scope.availableRep / 30);
            $scope.usedMonths = Math.floor(rep.spent_rep / 30);
        }, function(response) {
            $scope.error = response;
        })
    };

    $scope.retrieveReputation();

    // helper methods
    $scope.selectOption = function(option) {
        $scope.showOptions = false;
        if (option.title === 'Free') {
            $scope.showFree = true;
        } else {
            $scope.showPurchase = true;
            $scope.selectedOption = option;
        }
    };

    $scope.back = function() {
        $scope.showOptions = true;
        $scope.showFree = false;
        $scope.showPurchase = false;
    };
});
