/**
 * Created by ThreeTen on 4/29/2016.
 */

app.directive('compatibilityNote', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/notePartials/compatibilityNote.html',
        controller: 'compatibilityNoteController',
        scope: {
        	cnote: '=',
            showAuthorColumn: '='
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('compatibilityNoteController', function ($scope, modService) {
	//If possible it would be better to only retrieve the names of the mods here instead of the whole mod object
	modService.retrieveMod($scope.cnote.first_mod_id).then(function(firstMod) {
		$scope.firstMod = firstMod;
	});
	modService.retrieveMod($scope.cnote.second_mod_id).then(function(secondMod) {
		$scope.secondMod = secondMod;
	});
});
