/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/modlist', {
            templateUrl: '/resources/partials/modlist_template.html',
            controller: 'modlistController'
        }
    );
}]);

app.controller('modlistController', function($scope) {
    $scope.currentTab='details';
    useTwoColumns(false);

    $scope.isSelected = function(tabName) {
    	return $scope.currentTab === tabName;
    };

    $scope.cssClass = function(tabName) {
        if($scope.isSelected(tabName))
            return "selected-tab";
        else
            return "unselected-tab";
    };
    
});