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
    this.modListToolActions = function() {
        return [{
            caption: "Remove",
            title: "Remove this tool from the mod list",
            disabled: factory.disabledWhenNotEditing,
            execute: function($scope, item) {
                if (!$scope.editing) return;
                $scope.removeItem(item);
            }
        }, {
            icon: "fa-gear",
            title: "View Details",
            hidden: function($scope, item) { return !!item.mod },
            execute: function($scope, item) {
                $scope.$emit('toggleDetailsModal', {visible: true, item: item});
            }
        }];
    };

    this.modListModActions = function() {
        return [{
            caption: "Remove",
            title: "Remove this mod from the mod list",
            disabled: factory.disabledWhenNotEditing,
            execute: function($scope, item) {
                if (!$scope.editing) return;
                $scope.removeItem(item);
            }
        }, {
            icon: "fa-gear",
            title: "View Details",
            hidden: function($scope, item) { return !!item.mod },
            execute: function($scope, item) {
                $scope.$emit('toggleDetailsModal', {visible: true, item: item});
            }
        }];
    };

    this.modListPluginActions = function() {
        return [{
            caption: "Remove",
            title: "Remove this plugin from the mod list",
            disabled: factory.disabledWhenNotEditing,
            execute: function($scope, item) {
                if (!$scope.editing) return;
                $scope.removeItem(item);
            }
        }, {
            key: "showOptions",
            icon: "fa-gear",
            title: "More Options",
            disabled: function($scope, item) { return !$scope.editing && !!item.plugin },
            items: [{
                text: "View details",
                disabled: function($scope, item) { return !!item.plugin },
                execute: function($scope, item) {
                    $scope.$emit('toggleDetailsModal', {visible: true, item: item});
                }
            }, {
                text: factory.toggleTextFunction('merged'),
                disabled: factory.disabledWhenNotEditing,
                execute: function($scope, item) {
                    if (!$scope.editing) return;
                    item.merged = !item.merged;
                    $scope.$emit('updateItems');
                }
            }, {
                text: factory.toggleTextFunction('cleaned'),
                disabled: factory.disabledWhenNotEditing,
                execute: factory.toggleFunction('cleaned')
            }]
        }];
    };
});