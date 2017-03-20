app.run(function($futureState, $rootScope, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('Audiovisual', filterPrototypes);
    state.params.c = '1,10,11,12,13,14'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('audiovisualController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Audiovisual';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
