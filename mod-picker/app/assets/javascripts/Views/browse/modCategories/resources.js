app.run(function($futureState, $rootScope, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('resources', filterPrototypes);
    state.params.c = '8,43,44,45'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('resourcesController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Resources';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
