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
                if (item.hidden || !item.approved) return true;
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
                if (item.hidden || !item.approved) return true;
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
        }, {
            caption: "Hidden",
            title: "This mod is hidden",
            class: 'yellow-box no-action',
            hidden: function($scope, item) {
                return !item.hidden;
            }
        }, {
            caption: "Unapproved",
            title: "This mod has not yet been approved",
            class: 'red-box no-action',
            hidden: function($scope, item) {
                return item.hidden || item.approved;
            }
        }]
    };

    this.userModActions = function() {
        return [{
            caption: "Edit",
            title: "Edit this mod.",
            hidden: function($scope, item) {
                var isAuthor = item.author_users.find(function(author) {
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
                var isAuthor = item.author_users.find(function(author) {
                    return author.id == $scope.currentUser.id;
                });
                return item.hidden || !$scope.permissions.canModerate && !isAuthor;
            },
            execute: function($scope, item) {
                $scope.$emit('hideMod', item);
            }
        }, {
            caption: "Recover",
            title: "Click here to recover this mod.",
            class: 'green-box',
            hidden: function($scope, item) {
                var isAuthor = item.author_users.find(function(author) {
                    return author.id == $scope.currentUser.id;
                });
                return !item.hidden || !$scope.permissions.canModerate && !isAuthor;
            },
            execute: function($scope, item) {
                $scope.$emit('recoverMod', item);
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
            disabled: function($scope, item) {
                return !$scope.editing && !item.description && (!item.mod || item.mod.mod_options.length <= 1);
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
            disabled: function($scope, item) {
                return !$scope.editing && !item.description && (!item.mod || item.mod.mod_options.length <= 1);
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
            disabled: function($scope, item) {
                return !$scope.editing && !item.description && !!item.plugin;
            },
            items: [{
                text: "View details",
                disabled: function($scope, item) {
                    return !$scope.editing && !item.description && !!item.plugin;
                },
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

    this.modListImportActions = function() {
        return [{
            caption: "Remove",
            title: "Remove this item from the import list",
            execute: function($scope, item) {
                $scope.remove(item);
            }
        }]
    };

    /* tag actions */
    this.tagIndexActions = function() {
        return [{
            caption: "Edit",
            title: "Edit this tag's text",
            hidden: function($scope, item) {
                return item.hidden || !$scope.permissions.canModerate;
            },
            execute: function($scope, item) {
                $scope.$emit('editTag', item);
            }
        }, {
            caption: "Replace",
            title: "Replace usages of this tag with another tag.",
            hidden: function($scope, item) {
                return item.hidden || !$scope.permissions.canModerate;
            },
            execute: function($scope, item) {
                $scope.$emit('replaceTag', item);
            }
        }, {
            caption: "Recover",
            title: "This tag is hidden.  Click to recover it.",
            class: 'green-box',
            hidden: function($scope, item) {
                return !item.hidden || !$scope.permissions.canModerate;
            },
            execute: function($scope, item) {
                $scope.$emit('recoverTag', item);
            }
        }, {
            caption: "Hide",
            title: "This tag is publicly visible.  Click to hide it.",
            class: 'yellow-box',
            hidden: function($scope, item) {
                return item.hidden || !$scope.permissions.canModerate;
            },
            execute: function($scope, item) {
                $scope.$emit('hideTag', item);
            }
        }]
    };

    /* api token actions */
    this.apiTokenActions = function() {
        return [{
            caption: "Edit",
            title: "Edit this API Token's name",
            hidden: function($scope, item) {
                return item.expired;
            },
            execute: function($scope, item) {
                $scope.$emit('editToken', item);
            }
        }, {
            caption: "Expire",
            title: "Expire this API token so it is no longer valid",
            disabled: function($scope, item) {
                return item.expired;
            },
            execute: function($scope, item) {
                $scope.$emit('expireToken', item);
            }
        }]
    };
});