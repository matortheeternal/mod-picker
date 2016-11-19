app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.tagFilters();
    var state = indexFactory.buildState('text', 'ASC', 'tags', filterPrototypes);
    state.controller = 'tagsIndexController';
    $futureState.futureState(state);
});

app.controller('tagsIndexController', function($scope, $rootScope, $stateParams, $state, tagService, helpFactory, columnsFactory, filtersFactory, actionsFactory, indexService, indexFactory, eventHandlerFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = $rootScope.permissions;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Tags');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    /* helper functions */
    // toggles the tag modal
    $scope.toggleTagModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showTagModal = visible;
    };

    // opens the edit tag modal for a given tag
    $scope.$on('editTag', function(event, tag) {
        $scope.activeTag = angular.copy(tag);
        $scope.originalTag = tag;
        $scope.toggleTagModal(true);
    });

    // hides a tag
    $scope.$on('hideTag', function(event, tag) {
        tagService.hideTag(tag.id, true).then(function() {
            tag.hidden = true;
            $scope.$emit('successMessage', tag.text + ' has been hidden.');
        }, function(response) {
            var params = {
                label: 'Error hiding tag: '+tag.text+'.',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    // recovers a tag
    $scope.$on('recoverTag', function(event, tag) {
        tagService.hideTag(tag.id, false).then(function() {
            tag.hidden = false;
            $scope.$emit('successMessage', tag.text + ' has been recovered.');
        }, function(response) {
            var params = {
                label: 'Error recovering tag: '+tag.text+'.',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    // columns for view
    $scope.columns = columnsFactory.tagColumns(true);
    $scope.columnGroups = columnsFactory.tagColumnGroups();

    // filters for view
    $scope.filterPrototypes = filtersFactory.tagFilters();
    $scope.statFilters = filtersFactory.tagStatisticFilters();

    // build generic controller stuff
    $scope.route = 'tags';
    $scope.retrieve = tagService.retrieveTags;
    indexFactory.buildIndex($scope, $stateParams, $state);
    eventHandlerFactory.buildMessageHandlers($scope);

    // override some data from the generic controller
    $scope.actions = actionsFactory.tagIndexActions();
});
