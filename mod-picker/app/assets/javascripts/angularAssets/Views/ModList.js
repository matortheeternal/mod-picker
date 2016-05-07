/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('modlist', {
            templateUrl: '/resources/partials/modlist_template.html',
            controller: 'modlistController',
            url: '/modlist'
        }
    );
}]);

app.controller('modlistController', function($scope, $log) {
	/*config*/
	useTwoColumns(false);
	$scope.bIsEditing = false;
	/*vars - Later down the road these will turn into GET functions*/
	$scope.modlistTitle = "My Super Cool Mod List With All The Good Mods - With ENB";
    $scope.currentTab = 'details';

	$scope.planningOpt = 'Planning';
	$scope.underContructionOpt = 'Under Construction';
	$scope.testingOpt ='Testing';
	$scope.completeOpt = 'Complete';

	$scope.publicOpt = 'Public';
	$scope.unlistedOpt = 'Unlisted';
	$scope.privateOpt	= 'Private';

	$scope.bHideCatNotes = false;
	$scope.bHideModGrpNotes = true;
	$scope.bIsCollection = true;

	$scope.shortDescTextArea = 'Provide a short description of your mod list';

	$scope.curToolsSecTab = 'list';
	$scope.curModsSecTab = 'list';
	$scope.curPluginSecTab = 'list';
	$scope.curSkyConfigTab = 'skyrim.ini';
	$scope.curENBConfigTab = 'enblocal.ini';

   /*functions*/
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
    }


    $scope.cssChange = function(sectionName, secTab) {
    	var scopeVar = $scope.sectionSelected(sectionName);
        if(scopeVar === secTab)
            return "section-selected-tab";
        else
            return "section-unselected-tab";
    };

    $scope.debugFunc = function() {
    	$log.debug($scope.curSkyConfigTab);
    	$scope.bIsEditing = true;
    };





    $scope.longDescTextArea = "Lorem ipsum dolor sit amet, adipiscing diam sed dictumst convallis sit, lectus rutrum neque, in nulla tellus, accumsan est cursus iaculis amet. Auctor sed lorem curabitur, inceptos libero eget, justo voluptatem nunc rhoncus fusce scelerisque. Quam curabitur nec pulvinar congue a, dui vestibulum, blanditiis orci nec rutrum quis, quam ac, egestas sem amet ultricies etiam pede. Lacinia et nec eleifend, pede cursus sed malesuada metus morbi, metus egestas tellus maecenas, tortor aliquam justo ipsum sed dui nulla, varius eu libero. Elementum et aliquam a, suspendisse urna, sem non ornare accumsan elit tincidunt amet, wisi mauris nulla, arcu eget ullamcorper id imperdiet libero. Arcu aenean amet porta nec erat amet, vestibulum mattis porttitor wisi, dolor wisi non lacus quam, lectus donec adipisicing enim. In et, posuere mi aenean aenean luctus sagittis nec, at vitae nulla lorem dolor. Lectus auctor dolor quam ullamcorper gravida elit, ut penatibus.  Integer pellentesque mattis aenean sed, ac lectus, phasellus quis maecenas urna lacinia. Odio a eget ultrices dis. Ut consequat at felis eu, parturient urna sit nunc quis class urna, urna erat volutpat integer in vestibulum suspendisse, porta magna lectus neque massa, pharetra aenean. Magnis tellus phasellus tellus, sit cras parturient vel adipiscing, sapien quam erat semper. Massa sem proin. Libero nullam, tempus est, convallis elit a lobortis.  Sem gravida lorem per velit id a, nullam vivamus nibh eget sodales ante, interdum arcu wisi sapien, a amet posuere hendrerit mollis metus mauris, ut pede aliquam volutpat. Donec ipsum accumsan metus sit, blandit dolor sed dolor duis, lorem neque at orci proin ac architecto, condimentum at porttitor diam, sed semper ultrices taciti dolor aliquam. Accumsan eu suscipit diam quam id aenean, tincidunt luctus eu aliquam. Ante in donec pellentesque est, pellentesque id volutpat dapibus. \n Vehicula ante aut fames duis mauris, lacus in sit ad et, integer luctus. Taciti tincidunt nibh viverra, est sagittis accumsan, vitae feugiat, pede pulvinar congue orci consectetuer suspendisse, torquent in cras enim in inceptos. Magna vehicula sed ipsum eleifend.  Lorem mauris leo nullam nulla. In sem parturient eget tempor. Lacus metus orci tincidunt elementum ipsum. Neque luctus, aenean facilisi neque felis erat etiam tortor, sit purus tellus quis, ad purus lectus phasellus eu elit, purus nisl in in nibh. Nulla quis ligula felis vel malesuada in. Nisl turpis augue ac sit, tincidunt parturient dictumst porttitor vitae eu, id in suspendisse magna, eu et nam quam tellus sit a, et arcu ornare mollis in sem. Pellentesque praesent at augue, wisi vel. Sed in massa praesent eget at nascetur, facere sollicitudin sed eros fringilla, consectetuer non sed vehicula maecenas. Vestibulum tempore turpis augue eros mauris in, vitae sit cras dicta a, congue lectus duis donec morbi enim consequat, nulla faucibus. Reiciendis massa rhoncus eget, nec at mattis id mi eu.";

});
