app.run(function($futureState, $rootScope, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('utilities', filterPrototypes);
    state.params.c = '9,46,47,48'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('utilitiesController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Utilities';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
