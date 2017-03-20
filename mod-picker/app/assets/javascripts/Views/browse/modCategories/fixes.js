app.run(function($futureState, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('Fixes', filterPrototypes);
    state.params.c = '3,18,19'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('fixesController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Fixes';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
