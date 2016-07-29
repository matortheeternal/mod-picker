app.service('actionsFactory', function() {
    var factory = this;

    /* function factories */
    this.toggleText = function(key) {
        return function($scope, item) {
            if (!$scope.editing) return;
            return item[key] ? 'Mark not '+key : 'Mark '+key;
        };
    };

    this.toggleOnClick = function(key) {
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
            key: "options",
            icon: "fa-gear",
            title: "More Options",
            items: [{
                text: "View details",
                onclick: function($scope, item) {
                    $scope.detailsItem = item;
                    $scope.showDetailsModal = true;
                }
            }, {
                text: factory.toggleText('merged'),
                disabled: factory.disabledWhenNotEditing,
                onclick: factory.toggleOnClick('merged')
            }, {
                text: factory.toggleText('cleaned'),
                disabled: factory.disabledWhenNotEditing,
                onclick: factory.toggleOnClick('cleaned')
            }]
        }];
    };
});