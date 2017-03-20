app.run(function($futureState, $rootScope, modsIndexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modCategoryFilters();
    var state = modsIndexFactory.buildModsIndexState('Items', filterPrototypes);
    state.params.c = '5,31,32,33,34'; // TODO: avoid hardcoding ids here
    $futureState.futureState(state);
});

app.controller('itemsController', function($scope, $rootScope, $stateParams, $state, modsIndexFactory) {
    $scope.categoryName = 'Items';
    modsIndexFactory.buildModsIndex($scope, $rootScope, $stateParams, $state);
});
