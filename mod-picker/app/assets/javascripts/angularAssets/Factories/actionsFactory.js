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

    /* mod actions */
    this.modIndexActions = function() {
        return [{
            caption: "Add",
            title: "Add this mod to your mod list",
            hidden: function($scope, item) {
                var activeModList = $scope.$parent.activeModList;
                if (!activeModList) return true;
                var foundMod = activeModList.mod_list_mod_ids.find(function(modId) {
                    return modId == item.id;
                });
                return !!foundMod;
            },
            execute: function($scope, item) {
                $scope.$emit('addMod', item);
            }
        }, {
            caption: "Remove",
            title: "Remove this mod from your mod list",
            class: 'red-box',
            hidden: function($scope, item) {
                var activeModList = $scope.$parent.activeModList;
                if (!activeModList) return true;
                var foundMod = activeModList.mod_list_mod_ids.find(function(modId) {
                    return modId == item.id;
                });
                return !foundMod;
            },
            execute: function($scope, item) {
                $scope.$emit('removeMod', item);
            }
        }]
    };

    this.userModActions = function() {
        return [{
            caption: "Edit",
            title: "Edit this mod.",
            hidden: function($scope, item) {
                var isAuthor = item.mod_authors.find(function(author) {
                    return author.id == $scope.currentUser.id;
                });
                return !$scope.permissions.canModerate && !isAuthor;
            },
            execute: function($scope, item) {
                $scope.$emit('editMod', item);
            }
        }, {
            caption: "Hide",
            title: "Hide this mod from public viewing.",
            class: 'red-box',
            hidden: function($scope, item) {
                var isAuthor = item.mod_authors.find(function(author) {
                    return author.id == $scope.currentUser.id;
                });
                return !$scope.permissions.canModerate && !isAuthor;
            },
            execute: function($scope, item) {
                $scope.$emit('hideMod', item);
            }
        }];
    };

    /* mod list actions */
    this.modListIndexActions = function() {
        return [{
            caption: "Add",
            title: "Add this collection to your mod list",
            hidden: function($scope, item) {
                return !item.is_collection;
            },
            execute: function($scope, item) {
                $scope.$emit('addCollection', item);
            }
        }]
    };

    this.userModListActions = function() {
        return [{
            caption: "Clone",
            title: "Make a copy of this mod list",
            hidden: function($scope, item) {
                return item.hidden || !$scope.permissions.canModerate && $scope.currentUser.id != item.submitter.id;
            },
            execute: function($scope, item) {
                $scope.$emit('cloneModList', item);
            }
        }, {
            caption: "Delete",
            title: "Delete this mod list",
            class: 'red-box',
            hidden: function($scope, item) {
                return item.hidden || !$scope.permissions.canModerate && $scope.currentUser.id != item.submitter.id;
            },
            execute: function($scope, item) {
                $scope.$emit('deleteModList', item);
            }
        }, {
            caption: "Recover",
            title: "Click here to recover this mod list.",
            class: 'green-box',
            hidden: function($scope, item) {
                return !item.hidden;
            },
            execute: function($scope, item) {
                $scope.$emit('recoverModList', item);
            }
        }]
    };

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
            hidden: function($scope, item) {
                return item.mod && item.mod.mod_options.length < 2
            },
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
            hidden: function($scope, item) {
                return item.mod && item.mod.mod_options.length < 2
            },
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