app.run(function($futureState, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('Gameplay', filterPrototypes);
    state.params.c = '4,21,20,22,23,25,26,27,28,30'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('gameplayController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Gameplay';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
