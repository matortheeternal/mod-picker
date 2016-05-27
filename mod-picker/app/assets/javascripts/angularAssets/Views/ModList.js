/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('modlist', {
            templateUrl: '/resources/partials/modlist_template.html',
            controller: 'modlistController',
            url: '/modlist/:modListId'
        }
    );
}]);

app.controller('modlistController', function($scope, $log, $stateParams, modListService) {

	/*config*/
	$scope.bIsEditing = true;
	/*vars - Later down the road these will turn into GET functions*/
	$scope.modlistTitle = "My Super Cool Mod List With All The Good Mods - With ENB";
    $scope.currentTab = 'plugins';

	$scope.bHideCatNotes = false;
	$scope.bHideModGrpNotes = true;
	$scope.bIsCollection = true;


	$scope.shortDescTextArea = 'Provide a short description of your mod list';

	$scope.curToolsSecTab = 'list';
	$scope.curModsSecTab = 'list';
	$scope.curPluginSecTab = 'list';
	$scope.curSkyConfigTab = 'skyrim.ini';
	$scope.curENBConfigTab = 'enblocal.ini';

    $scope.statusIcons = [
                            {name: 'fa-pencil-square-o'}, //planned
                            {name: 'fa-wrench'}, //under construction
                            {name: 'fa-cogs'},  //testing
                            {name: 'fa-check'} //complete
    ];
    $scope.curStatusIcon = $scope.statusIcons[2];

    modListService.retrieveModList($stateParams.modListId).then(function(modList) {
       $scope.modlist = modList;
    });
    //Function To Return Modlist Status as Index for statusIcons
    $scope.mlStatus = function() {
        var modList = $scope.modlist;
        if (modList.status == 'planned') {
            $scope.curStatusIcon = $scope.statusIcons[0];
        } else if (modList.status == 'under construction') {
            $scope.curStatusIcon = $scope.statusIcons[1];
        } else if (modListt.status == 'testing') {
            $scope.curStatusIcon = $scope.statusIcons[2];
        } else {
            $scope.curStatusIcon = $scope.statusIcons[3];
        };
    } 

    $scope.isSelected = function(tabName) {
    	return $scope.currentTab === tabName;
    };

    $scope.cssClass = function(tabName) {
        if($scope.isSelected(tabName))
            return "selected-tab";
        else
            return "unselected-tab";
    };


    $scope.sectionSelected = function(secName) {
    	if(secName === 'tools')
    		return $scope.curToolsSecTab;
    	else if(secName === 'mods')
    		return $scope.curModsSecTab;
    	else if(secName === 'plugins')
			return $scope.curPluginSecTab;
		else if(secName === 'skyrimConfig')
			return $scope.curSkyConfigTab;
		else if(secName === 'enbConfig')
			return $scope.curENBConfigTab;
    };


    $scope.cssChange = function(sectionName, secTab) {
    	var scopeVar = $scope.sectionSelected(sectionName);
        if(scopeVar === secTab)
            return "section-selected-tab";
        else
            return "section-unselected-tab";
    };

    $scope.debugFunc = function() {
    	$scope.bIsEditing = $scope.bIsEditing ? false: true;
    };

    $scope.hasPermissions = function() {
        //REPLACE WHEN I ACTUALLY KNOW HOW TO GET THE CURRENT USER
        return true;
    };

    $scope.isEditing = function(cond) {
        if ($scope.bIsEditing == true && cond == true && $scope.hasPermissions())
            return true;
        else if ($scope.bIsEditing == false && cond == false) {
            return true;
        } 
        else
            return false;
    };
});
