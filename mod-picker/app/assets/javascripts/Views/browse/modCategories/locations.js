app.run(function($futureState, $rootScope, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('Locations', filterPrototypes);
    state.params.c = '6,35,36,37,38,39'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('locationsController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Locations';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
