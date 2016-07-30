app.service('actionsFactory', function() {
    var factory = this;

    /* function factories */
    this.toggleTextFunction = function(key) {
        return function($scope, item) {
            return item[key] ? 'Mark not '+key : 'Mark '+key;
        };
    };

    this.toggleFunction = function(key) {
        return function($scope, item) {
            if (!$scope.editing) return;
            item[key] = !item[key];
        };
    };

    /* shared function prototypes */
    this.disabledWhenNotEditing = function($scope, item) {
        return !$scope.editing;
    };

    /* mod list actions */
    this.modListPluginActions = function() {
        return [{
            caption: "Remove",
            title: "Remove this plugin from the mod list",
            execute: function($scope, item) {
                if (!$scope.editing) return;
                $scope.removeItem(item);
            }
        }, {
            key: "showOptions",
            icon: "fa-gear",
            title: "More Options",
            items: [{
                text: "View details",
                execute: function($scope, item) {
                    $scope.detailsItem = item;
                    $scope.showDetailsModal = true;
                }
            }, {
                text: factory.toggleTextFunction('merged'),
                disabled: factory.disabledWhenNotEditing,
                execute: factory.toggleFunction('merged')
            }, {
                text: factory.toggleTextFunction('cleaned'),
                disabled: factory.disabledWhenNotEditing,
                execute: factory.toggleFunction('cleaned')
            }]
        }];
    };
});