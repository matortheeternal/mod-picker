app.controller('userSettingsApiController', function($scope, $rootScope, columnsFactory, actionsFactory, apiTokenService) {
    // initialize variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.actions = actionsFactory.apiTokenActions();
    $scope.columns = columnsFactory.apiTokenColumns();
    $scope.columnGroups = columnsFactory.apiTokenColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveApiTokens = function() {
        var userId = $scope.currentUser.id;
        apiTokenService.retrieveUserTokens(userId).then(function(data) {
            $scope.api_tokens = data.api_tokens;
        }, function(response) {
            $scope.errors.api_tokens = response;
        });
    };

    //retrieve the mod lists when the state is first loaded
    $scope.retrieveApiTokens();

    // toggles the token modal
    $scope.toggleTokenModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showTokenModal = visible;
    };

    // create a new api token
    $scope.newApiToken = function() {
        apiTokenService.createToken("API Token").then(function(data) {
            $scope.api_tokens.push(data.api_token);
        }, function(response) {
            var params = {
                label: 'Error creating API Token',
                response: response
            };
            $scope.$emit('errorMessage', params);
        })
    };

    // action handlers
    $scope.$on('editToken', function(event, token) {
        $scope.activeToken = angular.copy(token);
        $scope.originalToken = token;
        $scope.toggleTokenModal(true);
    });

    $scope.$on('expireToken', function(event, token) {
        apiTokenService.expireToken(token.id).then(function() {
            token.expired = true;
            token.date_expired = new Date();
            $scope.$emit('successMessage', 'API Token expired successfully.');
        }, function(response) {
            var params = {
                label: 'Error expiring API Token',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });
});