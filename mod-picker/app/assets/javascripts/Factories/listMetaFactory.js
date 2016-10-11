app.service('listMetaFactory', function($q, $timeout, modListService, listUtils, sortUtils) {
    this.buildModelFunctions = function ($scope, label, dataKey, nameKey, customName) {
        var capLabel = label.capitalize();
        var pluralLabel = label + 's';
        var countKey = pluralLabel + '_count';
        var idKey = label + '_id';
        var $rootScope = $scope.$root;

        // ITEM RECOVERY
        var recoverLabel = 'recover' + capLabel;
        var recoverMessage = dataKey + 'Recovered';

        var incrementCounter = function() {
            $scope.mod_list[countKey] += 1;
            $scope.updateTabs();
        };

        var decrementCounter = function() {
            $scope.mod_list[countKey] -= 1;
            $scope.updateTabs();
        };

        var customCallback = function(functionLabel, arg) {
            var callbackLabel = functionLabel + 'Callback';
            if ($scope[callbackLabel]) {
                $scope[callbackLabel](arg);
            }
        };

        var getItemName = function(item) {
            return item[dataKey][nameKey];
        };

        var recoverFailed = function(modListItem) {
            var name = getItemName(modListItem);
            var params = {
                type: 'error',
                text: 'Failed to add '+label+' '+name+', the '+label+' has already been added to this mod list.'
            };
            $scope.$emit('customMessage', params);
        };

        var associateCompatibilityNote = function(modListCustomItem) {
            if (label === 'plugin') {
                var notes = $scope.notes.plugin_compatibility;
                modListService.associateCompatibilityNote(modListCustomItem, notes);
            }
        };

        $scope[recoverLabel] = function(modListItem) {
            if (!modListItem._destroy) {
                recoverFailed(modListItem);
                return;
            }

            // destroy the item
            delete modListItem._destroy;
            incrementCounter();
            var itemId = modListItem[dataKey]&& modListItem[dataKey].id;
            $rootScope.$broadcast(recoverMessage, itemId);
            customCallback(recoverLabel, modListItem);
            $scope.$broadcast('updateItems');

            // success message
            var name = getItemName(modListItem);
            $scope.$emit('successMessage', 'Added '+label+' '+name+' successfully.');
        };

        // ADDING NEW ITEMS
        var addNewLabel = 'addNew' + capLabel;
        var newModListItemKey = 'newModList' + capLabel;
        var mod_list_item_key = 'mod_list_' + label;
        var itemAddedMessage = dataKey + 'Added';

        $scope[addNewLabel] = function(itemId) {
            var mod_list_item = {};
            mod_list_item.mod_list_id = $scope.mod_list.id;
            mod_list_item.index = listUtils.getNextIndex($scope.model[pluralLabel]);
            mod_list_item[idKey] = itemId;

            modListService[newModListItemKey](mod_list_item).then(function(data) {
                var modListItem = data[mod_list_item_key];
                $scope.mod_list[pluralLabel].push(modListItem);
                $scope.model[pluralLabel].push(modListItem);
                $scope.originalModList[pluralLabel].push(angular.copy(modListItem));
                incrementCounter();

                // update modules
                $rootScope.$broadcast(itemAddedMessage, data);
                $scope.$broadcast('updateItems');
                customCallback(addNewLabel, modListItem);

                // success message
                var name = getItemName(modListItem);
                $scope.$emit('successMessage', 'Added '+label+' '+name+' successfully.');
            }, function(response) {
                var params = {
                    label: 'Error adding '+label,
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        };

        // ADD CUSTOM ITEM
        var addCustomLabel = 'addCustom' + capLabel;
        var newModListCustomItemKey = 'newModListCustom' + capLabel;
        var mod_list_custom_item_key = 'mod_list_custom_' + label;
        var customKey = 'custom_' + pluralLabel;
        var customItemAddedMessage = 'custom' + dataKey.capitalize() + 'Added';

        $scope[addCustomLabel] = function(noteId) {
            var custom_item = {};
            custom_item.mod_list_id = $scope.mod_list.id;
            custom_item.index = listUtils.getNextIndex($scope.model[pluralLabel]);
            custom_item[nameKey] = customName;
            customCallback(addCustomLabel, { item: custom_item, noteId: noteId });

            modListService[newModListCustomItemKey](custom_item).then(function(data) {
                var modListCustomItem = data[mod_list_custom_item_key];
                associateCompatibilityNote(modListCustomItem);
                $scope.mod_list[customKey].push(modListCustomItem);
                $scope.model[pluralLabel].push(modListCustomItem);
                $scope.originalModList[customKey].push(angular.copy(modListCustomItem));
                incrementCounter();

                // update modules
                $scope.$broadcast(customItemAddedMessage);
                $scope.$broadcast('updateItems');

                // open details modal for custom item
                $scope.toggleDetailsModal(true, modListCustomItem);
            }, function(response) {
                var params = {
                    label: 'Error adding custom '+label,
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        };

        // ADD ITEM
        var addLabel = 'add' + capLabel;
        var findItemLabel = 'find' + capLabel;

        $scope[addLabel] = function(itemId) {
            // return if we don't have an item to add
            if (!itemId) return;

            // see if item is already present on the user's mod list
            var existingItem = $scope[findItemLabel](itemId);
            if (existingItem) {
                $scope[recoverLabel](existingItem);
            } else {
                $scope[addNewLabel](itemId);
            }

            if ($scope.add[label].id) {
                $scope.add[label].id = null;
                $scope.add[label].name = "";
            }
        };

        // REMOVE ITEM
        var removeLabel = 'remove' + capLabel;
        var itemRemovedMessage = dataKey + 'Removed';

        $scope[removeLabel] = function(modListItem) {
            modListItem._destroy = true;
            decrementCounter();

            // update modules
            var itemId = modListItem[dataKey] && modListItem[dataKey].id;
            $rootScope.$broadcast(itemRemovedMessage, itemId);
            customCallback(removeLabel, modListItem);
            $scope.$broadcast('updateItems');
        };
    };

    this.buildSortFunctions = function($scope, label, dataLabel, itemSortKey) {
        var capLabel = label.capitalize();
        var orderLabel = label + ' order';
        var orderLabelTitle = orderLabel.titleCase();
        var pluralDataLabel = dataLabel + 's';

        // start sort
        var orderKey = capLabel + 'Order';
        var resolveAllOrderMessage = 'resolveAll' + orderKey;
        var sortLabel = 'sort' + orderKey;
        var startSortLabel = 'start' + sortLabel.capitalize();

        $scope[startSortLabel] = function() {
            // Display activity modal
            $scope.startActivity('Sorting '+orderLabelTitle);
            $scope.setActivityMessage('Preparing mod list for sorting');

            // Prepare to sort
            sortUtils.setSortTarget($scope.mod_list, pluralDataLabel);
            sortUtils.prepareToSort();

            // Save changes and call sort function if successful
            $scope.saveChanges(true).then(function() {
                $scope[sortLabel]();
            }, function() {
                $scope.$emit('customMessage', {
                    type: 'error',
                    text: "Failed to sort "+orderLabel+".  Couldn't save mod list."
                });
                $scope.setActivityMessage('Failed to prepare mod list for sorting');
                $scope.completeActivity();
            });
        };

        $scope[sortLabel] = function() {
            // STEP 1: Build groups for categories
            $scope.setActivityMessage('Building category groups');
            var groups = sortUtils.buildGroups();

            // STEP 2: Merge category groups with less than 5 members into super category groups
            sortUtils.combineGroups(groups, $scope.categories);

            // STEP 3: Sort groups and sort items in groups by asset file count
            $scope.setActivityMessage('Sorting groups and '+pluralDataLabel);
            sortUtils.sortGroupsByPriority(groups);
            sortUtils.sortItems(groups, dataLabel, itemSortKey);
            listUtils.updateItems(groups, 1);

            // STEP 4: Save the new groups and associate items with groups
            $scope.setActivityMessage('Saving groups');
            sortUtils.setSaveTarget($scope.model, $scope.originalModList);
            var groupPromises = sortUtils.saveGroups(groups);

            $q.all(groupPromises).then(function() {
                // STEP 5: Sort items per notes
                sortUtils.sortModel();
                $scope.setActivityMessage('Handling '+orderLabel+' notes');
                $scope.$broadcast(resolveAllOrderMessage);

                // STEP 6: Save changes
                $timeout(function() {
                    $scope.setActivityMessage('Finalizing changes');
                    $scope.saveChanges().then(function() {
                        $scope.setActivityMessage('All done!');
                        $scope.completeActivity();
                    }, function() {
                        $scope.setActivityMessage('Failed to save changes, please save manually.');
                        $scope.completeActivity();
                    });
                });
            });
        };
    };
});