app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mod', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController',
            url: '/mod/:modId'
        }
    );
}]);

app.filter('percentage', function() {
  return function(input) {
    if (isNaN(input)) {
      return input;
    }
    return Math.floor(input * 100) + '%';
  };
});

app.controller('modController', function ($scope, $q, $stateParams, modService, categoryService, assetUtils, userService) {

    //initialization /of the mod object
    modService.retrieveMod($stateParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.currentVersion = mod.mod_versions[0];

        //getting the actual names of the categories
        categoryService.getCategoryById(mod.primary_category_id).then(function (data) {
            $scope.firstCategory = data.name;
            //set initial data specific to the version
            $scope.updateVersion($scope.currentVersion);
        });
        categoryService.getCategoryById(mod.secondary_category_id).then(function (data) {
            $scope.secondCategory = data.name;
            //set initial data specific to the version
            $scope.updateVersion($scope.currentVersion);
        });

        //setting the name of the current game for the nexus links
        if ($scope.mod.game_id === 1) {
            $scope.game = "skyrim";
        }
        else if ($scope.mod.game_id === 2) {
            $scope.game = "fallout4";
        }

        //initializing the newCompatibilityNote object
        $scope.newCompatibilityNote = {};
        $scope.newCompatibilityNote.firstMod = $scope.mod;
    });

    //get current user
    userService.retrieveThisUser().then(function (user) {
        $scope.user = user;

        //actions the user can perform
        var rep = $scope.user.reputation.overall;
        $scope.userCanAddMod = (rep >= 160) || ($scope.user.role === 'admin');
        $scope.userCanAddTags = (rep >= 20) || ($scope.user.role === 'admin');
    });

    //of the tab data
    $scope.tabs = [
        { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
        { name: 'Compatibility', url: '/resources/partials/showMod/compatibility.html' },
        { name: 'Order', url: '/resources/partials/showMod/installation.html' },
        { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

    //this prevents the sort by dropdowns from displaying an undefined option
    $scope.compatibilityNotesFilter = '-sortBySeverity';

    //variables for the stat block expandables
    $scope.nexusExpanded = false;
    $scope.steamExpanded = false;
    $scope.loversExpanded = false;

    //getting the names and ids of the required mods
    $scope.updateVersion = function (modVersion) {
        //update notes
        modService.retrieveCompatibilityNotes(modVersion.id).then(function(notes) {
            $scope.compatibilityNotes = notes;
        });
        modService.retrieveInstallOrderNotes(modVersion.id).then(function(notes) {
            $scope.installOrderNotes = notes;
        });
        modService.retrieveLoadOrderNotes(modVersion.id).then(function(notes) {
            $scope.loadOrderNotes = notes;
        });

        //update requirements
        $scope.requirements = [];
        modVersion.required_mods.forEach(function(requirement) {
            modService.retrieveMod(requirement.required_id).then(function(mod) {
                $scope.requirements.push({
                    name: mod.name,
                    id: mod.id,
                    aliases: mod.aliases
                });
            });
        });
    };

    //finding the average rating of a review without counting null values
    $scope.findAverageRating = function(ratings) {
        ratings.filter(function(rating) {
            return rating !== null;
        });

        var sum = 0;
        ratings.forEach(function(rating) {
            sum += rating;
        });
        return sum/ratings.length;
    };

    //function to order by severity strings
    $scope.sortBySeverity = function(severity) {
        switch (severity) {
            case "Incompatible":
                return 5;
                break;

            case "Partially Incompatible":
                return 4;
                break;

            case "Make Custom Patch":
                return 3;
                break;

            case "Compatibility Mod":
                return 2;
                break;

            case "Compatibility Option":
                return 1;
                break;

            default:
                return 0;
                break;
        }
    };

    //formatting the data for the assetTree, as the recursive directive assetTree cannot do it in its controller
    var rawAssetData = [
        "Footprints.txt","Footprints.bsa","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptwerecreature.psc","Footprints.bsa\\scripts\\source\\footprintsdefaults.psc","Footprints.bsa\\scripts\\source\\footprintsplayerscript.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptvampirelord.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptmammoth.psc","Footprints.bsa\\scripts\\source\\footprintsrefcountscript.psc","Footprints.bsa\\scripts\\source\\qf_footprintsquest_02001dfb.psc","Footprints.bsa\\scripts\\source\\qf__04080094.psc","Footprints.bsa\\scripts\\source\\footprintsvcscript.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptbiped.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscripthorse.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscripthuman.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptquadruped.psc","Footprints.bsa\\scripts\\source\\qf_footprintsvcquest_02007490.psc","Footprints.bsa\\scripts\\source\\footprintsaddfootstepsscript.psc","Footprints.bsa\\scripts\\source\\footprintsconfigmenu.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptquadrupedfx.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptbipedfx.psc","Footprints.bsa\\scripts\\source\\footprintsdlc2defaults.psc","Footprints.bsa\\scripts\\source\\footprintsfootstepsscriptplayer.psc","Footprints.bsa\\scripts\\source\\footprintsdlc1defaults.psc","Footprints.bsa\\meshes\\footprints\\watersplashphys.nif","Footprints.bsa\\meshes\\footprints\\footprintshorsesnowrun.nif","Footprints.bsa\\meshes\\footprints\\footprintshumansnowwalk.nif","Footprints.bsa\\meshes\\footprints\\footprintsarvakpurple.nif","Footprints.bsa\\meshes\\footprints\\footprintshorsesnowsprint.nif","Footprints.bsa\\meshes\\footprints\\footprintshumansnowstraferunl.nif","Footprints.bsa\\meshes\\footprints\\footprintshumansnowstraferunr.nif","Footprints.bsa\\meshes\\footprints\\footprintshumansnowrun.nif","Footprints.bsa\\meshes\\footprints\\footprintshumansnowsprint.nif","Footprints.bsa\\meshes\\footprints\\footprintsgiantsnowrun.nif","Footprints.bsa\\scripts\\footprintsfootstepsscriptwerecreature.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptwerebear.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptwerewolf.pex","Footprints.bsa\\scripts\\footprintsdefaults.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptcow.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptlurker.pex","Footprints.bsa\\scripts\\footprintsplayerscript.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptgoblin.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptvampirelord.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptmammoth.pex","Footprints.bsa\\scripts\\footprintsrefcountscript.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptatronachflame.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptatronachfrost.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptatronachstorm.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptbear.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptboar.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptdeer.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptgoat.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptwolf.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptdeathhound.pex","Footprints.bsa\\scripts\\qf_footprintsquest_02001dfb.pex","Footprints.bsa\\scripts\\qf__04080094.pex","Footprints.bsa\\scripts\\footprintsvcscript.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptarvak.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptbiped.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptgiant.pex","Footprints.bsa\\scripts\\footprintsfootstepsscripthorse.pex","Footprints.bsa\\scripts\\footprintsfootstepsscripthuman.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptquadruped.pex","Footprints.bsa\\scripts\\footprintsfootstepsscripttroll.pex","Footprints.bsa\\scripts\\qf_footprintsvcquest_02007490.pex","Footprints.bsa\\scripts\\footprintsaddfootstepsscript.pex","Footprints.bsa\\scripts\\footprintsconfigmenu.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptgargoyle.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptskeever.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptspriggan.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptdraugr.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptquadrupedfx.pex","Footprints.bsa\\scripts\\footprintsfootstepsscripthagraven.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptbipedfx.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptsabrecat.pex","Footprints.bsa\\scripts\\footprintsdlc2defaults.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptplayer.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptskeleton.pex","Footprints.bsa\\scripts\\footprintsdlc1defaults.pex","Footprints.bsa\\scripts\\footprintsfootstepsscriptfalmer.pex","Footprints.bsa\\meshes\\footprints\\ash\\footprintshorseashrun.nif","Footprints.bsa\\meshes\\footprints\\ash\\footprintshumanashsprint.nif","Footprints.bsa\\meshes\\footprints\\ash\\footprintshumanashstraferunl.nif","Footprints.bsa\\meshes\\footprints\\ash\\footprintshumanashstraferunr.nif","Footprints.bsa\\meshes\\footprints\\ash\\footprintshorseashsprint.nif","Footprints.bsa\\meshes\\footprints\\ash\\footprintshumanashrun.nif","Footprints.bsa\\meshes\\footprints\\ash\\footprintshumanashwalk.nif","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashgiantl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashgiantr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashsprigganl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashsprigganr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbearbl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbearbr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbearfl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbearfr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashatronachfrostl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashatronachfrostr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbarefootrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbarefootrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashcowl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashcowr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashelkl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashelkr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashdraugrl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashdraugrr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhorsel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhorser.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashmammothl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashmammothr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashvampirelordrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashvampirelordrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhagravenl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhagravenr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolflstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolflstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashvampirelordl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashvampirelordr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashsabrecatbl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashsabrecatbr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashsabrecatfl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashsabrecatfr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashtrolll.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashtrollr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashgargoylel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashgargoyler.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashdeathhoundl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashdeathhoundr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashskeeverbl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashskeeverbr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashskeeverfl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashskeeverfr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolfbl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolfbr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolffl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolffr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbarefootlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbarefootlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashfalmerl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashfalmerr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearbl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearbr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearfl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerebearfr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanlsneak.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashvampirelordlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashvampirelordlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashskeletonl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashskeletonr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanrsneak.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbarefootl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashbarefootr.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashcaninel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashcaniner.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolfrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashwerewolfrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashhumanrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashlurkerl.dds","Footprints.bsa\\textures\\actors\\footprints\\ash\\footprintsashlurkerr.dds","Footprints.bsa\\textures\\actors\\footprints\\dummyprint.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearbl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearbl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearbr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearbr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearfl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearfl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearfr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearfr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshagravenl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshagravenr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolflstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolflstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolflstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolflstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearrstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearrstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearrstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearrstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsmammothl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsmammothr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsmammothl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsmammothl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsmammothr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsmammothr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscaninel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscaninel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscaniner_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscaniner_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdraugrl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdraugrl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdraugrr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdraugrr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgargoylel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgargoyler.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordrstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordrstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordrstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordrstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsfalmerl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsfalmerr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearlstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearlstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearlstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearlstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverbl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverbr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverfl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverfr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdeathhoundl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdeathhoundl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdeathhoundr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdeathhoundr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshorsel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshorsel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshorser_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshorser_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsatronachfrostl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsatronachfrostl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsatronachfrostr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsatronachfrostr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintselk_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintselk_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearbl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearbl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearbr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearbr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearfl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearfl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearfr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearfr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgiantl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgiantr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrsneak_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrsneak_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordlstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordlstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordlstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordlstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatbl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatbr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatfl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatfr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgargoylel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgargoylel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgargoyler_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgargoyler_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscaninel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscaniner.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdeathhoundl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdeathhoundr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearbl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearbr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearfl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbearfr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintslurkerl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintslurkerr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeletonl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeletonr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgiantl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgiantl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgiantr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsgiantr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintselk.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintstrolll_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintstrolll_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintstrollr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintstrollr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfbl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfbr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolffl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolffr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordrstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsvampirelordrstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshorsel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshorser.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssprigganl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssprigganl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssprigganr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssprigganr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolflstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolflstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscowl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscowl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscowr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscowr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlsneak.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatbl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatbl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatbr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatbr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatfl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatfl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatfr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatfr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeletonl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeletonl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeletonr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeletonr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearbl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearbr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearfl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearfr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshagravenl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshagravenl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshagravenr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshagravenr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootrstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootrstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootrstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootrstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintslurkerl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintslurkerl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintslurkerr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintslurkerr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\dummyprint_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintstrolll.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintstrollr.dds","Footprints.bsa\\textures\\actors\\footprints\\fluidsubsplatfilm.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsatronachfrostl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsatronachfrostr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanrsneak.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdraugrl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsdraugrr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsfalmerl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsfalmerl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsfalmerr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsfalmerr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfbl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfbl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfbr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfbr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolffl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolffl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolffr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolffr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssprigganl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssprigganr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfrstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfrstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfrstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerewolfrstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlsneak_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlsneak_n.dds","Footprints.bsa\\textures\\actors\\footprints\\gradsteamthick_brown.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscowl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintscowr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverbl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverbl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverbr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverbr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverfl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverfl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverfr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsskeeverfr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintswerebearlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatl.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintssabrecatr.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootlstrafel_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootlstrafel_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootlstrafer_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootlstrafer_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootlstrafer.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootl_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootl_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootr_h.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintsbarefootr_n.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlstrafel.dds","Footprints.bsa\\textures\\actors\\footprints\\footprintshumanlstrafer.dds","Footprints.bsl","Footprints.esp"];
    $scope.treeData = assetUtils.convertDataStringToNestedObject('Footprints', rawAssetData);

});
