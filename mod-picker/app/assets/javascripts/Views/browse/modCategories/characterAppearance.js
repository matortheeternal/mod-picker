app.run(function($futureState, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('Character Appearance', filterPrototypes);
    state.params.c = '2,49,15,16,17'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('characterAppearanceController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Character Appearance';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
