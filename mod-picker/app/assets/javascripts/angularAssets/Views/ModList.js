/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.modlist', {
        templateUrl: '/resources/partials/modList/modlist_template.html',
        controller: 'modlistController',
        url: '/modlist/:modListId',
        redirectTo: 'base.modlist.Details'
    }).state('base.modlist.Details', {
        templateUrl: '/resources/partials/modList/details.html',
        controller: 'modlistDetailsController',
        url: '/details'
    }).state('base.modlist.Tools', {
        templateUrl: '/resources/partials/modList/tools.html',
        controller: 'modlistToolsController',
        url: '/tools'
    }).state('base.modlist.Mods', {
        templateUrl: '/resources/partials/modList/mods.html',
        controller: 'modlistModsController',
        url: '/mods'
    }).state('base.modlist.Plugins', {
        templateUrl: '/resources/partials/modList/plugins.html',
        controller: 'modlistPluginsController',
        url: '/plugins'
    }).state('base.modlist.Config', {
        templateUrl: '/resources/partials/modList/config.html',
        controller: 'modlistConfigController',
        url: '/config'
    }).state('base.modlist.Comments', {
        templateUrl: '/resources/partials/modList/comments.html',
        controller: 'modlistCommentsController',
        url: '/comments'
    })
}]);

app.controller('modlistController', function($scope, $log, $stateParams, $timeout, currentUser, modListService, userService) {
    $scope.user = currentUser;
    $scope.permissions = currentUser.permissions;

	/*config*/
	$scope.bIsEditing = false;
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
    $scope.tabs = [
        {name: 'Details'},
        {name: 'Tools'},
        {name: 'Mods'},
        {name: 'Plugins'},
        {name: 'Config'},
        {name: 'Comments'}
    ];
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
        }
    };

    $scope.startEditing = function() {
        $scope.bIsEditing = true;
    };

    //get user permissions
    $scope.getPermissions = function() {
        // if we don't have mod yet, try again in 100ms
        if (!$scope.modlist) {
            $timeout(function() {
                $scope.getPermissions();
            }, 100);
            return;
        }

        // set up helper variables
        var rep = $scope.user.reputation.overall;
        var isAdmin = $scope.user.role === 'admin';
        var isModerator = $scope.user.role === 'moderator';
        var isAuthor = $scope.modlist.created_by === $scope.user.id;

        // set up permissions
        $scope.permissions = {
            canCreateTags: (rep >= 20) || isAuthor || isAdmin || isModerator,
            canManage: isAuthor || isModerator || isAdmin,
            canModerate: isModerator || isAdmin
        };
    };

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
});

app.controller('modlistDetailsController', function($scope) {

});

app.controller('modlistToolsController', function($scope) {

});

app.controller('modlistModsController', function($scope) {

});

app.controller('modlistPluginsController', function($scope) {

});

app.controller('modlistConfigController', function($scope) {

});

app.controller('modlistCommentsController', function($scope) {

});
