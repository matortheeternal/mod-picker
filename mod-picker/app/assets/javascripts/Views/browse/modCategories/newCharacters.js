app.run(function($futureState, $rootScope, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('New Characters', filterPrototypes);
    state.params.c = '7,40,41,42'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('newCharactersController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'New Characters';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
