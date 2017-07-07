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
    $scope.premiumOptions = [{
        title: "Free",
        description: "Can be earned by making contributions to the site.  Click for more information."
    }, {
        title: "1 Month",
        price: "$5.00",
        description: "One month of premium access."
    }, {
        title: "3 Months",
        price: "$14.00",
        description: "Three months of premium access.",
        discount: "6%"
    }, {
        title: "6 Months",
        price: "$25.00",
        description: "Six months of premium access.",
        discount: "16%"
    }, {
        title: "1 Year",
        price: "$45.00",
        description: "One year of premium access.",
        discount: "25%"
    }];

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
