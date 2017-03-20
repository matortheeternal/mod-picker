app.service('modsIndexFactory', function(modService, categoryService, tagService, modListService, indexService, helpFactory, sliderFactory, columnsFactory, detailsFactory, sortFactory, filtersFactory, actionsFactory, indexFactory, eventHandlerFactory) {
    this.buildModsIndex = function($scope, $rootScope, $stateParams, $state) {
        // inherited variables
        $scope.currentUser = $rootScope.currentUser;
        $scope.currentGame = $rootScope.currentGame;
        $scope.categories = $rootScope.categories;
        $scope.activeModList = $rootScope.activeModList;
        $scope.permissions = angular.copy($rootScope.permissions);
        $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

        // set page title
        $scope.$emit('setPageTitle', 'Browse Item Mods');

        // columns for view
        $scope.columns = columnsFactory.modColumns();
        $scope.columnGroups = columnsFactory.modColumnGroups();

        // details for view
        $scope.details = detailsFactory.modDetails();
        $scope.detailGroups = detailsFactory.modDetailGroups();

        // sort options for view
        $scope.baseSortOptions = sortFactory.modSortOptions();

        // set help context
        helpFactory.setHelpContexts($scope, [helpFactory.modsIndex]);

        /* helper functions */
        $scope.showDetailsModal = function() {
            $scope.$broadcast('configureDetails');
        };

        $scope.enableTag = function(tagText) {
            $scope.tagGroups.forEach(function(tagGroup) {
                tagGroup.tag_group_tags.forEach(function(tag) {
                    if (tag.tag_text === tagText) {
                        tag.enabled = true;
                    }
                })
            });
        };

        $scope.excludeTagGroup = function(tagGroup) {
            var excludedTags = tagGroup.exclude.join(',');
            for (var i = 0; i < $scope.tagGroups.length; i++) {
                var group = $scope.tagGroups[i];
                var tagTexts = $scope.tagTexts(group.tag_group_tags).join(',');
                if (tagTexts === excludedTags) {
                    group.excluded = true;
                    return;
                }
            }
        };

        $scope.categoriesChanged = function() {
            var subcategoryIds = $scope.subcategories.filter(function(subcategory) {
                return subcategory.enabled;
            }).map(function(subcategory) {
                return subcategory.id;
            });
            $scope.filters.categories = subcategoryIds.length > 0 ? subcategoryIds : $scope.categoryIds;
        };

        $scope.tagTexts = function(tags) {
            return tags.map(function(tag) {
                return tag.tag_text;
            })
        };

        $scope.tagGroupFilter = function(tagGroup) {
            if (tagGroup.excluded) {
                return {
                    exclude: $scope.tagTexts(tagGroup.tag_group_tags)
                };
            } else {
                var enabledTags = tagGroup.tag_group_tags.filter(function(tag) {
                    return tag.enabled;
                });
                return {
                    include: $scope.tagTexts(enabledTags)
                }
            }
        };

        $scope.tagsChanged = function() {
            $scope.filters.tag_groups = $scope.tagGroups.map(function(tagGroup) {
                return $scope.tagGroupFilter(tagGroup);
            }).filter(function(tagGroupFilter) {
                return tagGroupFilter.exclude || tagGroupFilter.include.length;
            });
        };

        // adds a mod to the user's mod list
        $scope.$on('addMod', function(event, mod) {
            modListService.addModListMod($scope.activeModList, mod).then(function() {
                $scope.$emit('successMessage', 'Added mod "'+mod.name+'" to your mod list successfully.');
            }, function(response) {
                var params = {
                    label: 'Error adding mod "'+mod.name+'" to your mod list',
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        });

        // removes a mod from the user's mod list
        $scope.$on('removeMod', function(event, mod) {
            modListService.removeModListMod($scope.activeModList, mod).then(function() {
                $scope.$emit('successMessage', 'Removed mod "'+mod.name+'" from your mod list successfully.');
            }, function(response) {
                var params = {
                    label: 'Error removing mod "'+mod.name+'" from your mod list',
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        });

        // filters for view
        $scope.category = angular.copy(categoryService.getCategoryByName($scope.categories, $scope.categoryName));
        $scope.category.enabled = true;
        $scope.subcategories = angular.copy(categoryService.filterCategories($scope.categories, $scope.category.id));
        categoryService.removeSuperCategoryNames($scope.subcategories);
        $scope.modelCategories = [$scope.category].concat($scope.subcategories);
        $scope.subcategoryIds = $scope.subcategories.map(function(subcategory) {
            return subcategory.id;
        });
        $scope.categoryIds = [$scope.category.id].concat($scope.subcategoryIds);
        $scope.tagGroups = tagService.categoryTagGroups($rootScope.tagGroups, $scope.categoryIds);
        categoryService.associateTagGroupCategories($scope.modelCategories, $scope.tagGroups);
        $scope.filterPrototypes = filtersFactory.modCategoryFilters();
        $scope.dateFilters = filtersFactory.modDateFilters();
        $scope.filters = {
            game: $scope.currentGame.id,
            categories: $scope.categoryIds
        };

        // build generic controller stuff
        $scope.route = 'mods';
        $scope.retrieve = modService.retrieveMods;
        indexFactory.buildIndex($scope, $stateParams, $state);
        eventHandlerFactory.buildMessageHandlers($scope);

        // load tag groups from params into view model
        if ($scope.filters.tag_groups) {
            $scope.filters.tag_groups.forEach(function(tagGroup) {
                if (tagGroup.include) {
                    tagGroup.include.forEach(function(tag) {
                        $scope.enableTag(tag);
                    });
                } else {
                    $scope.excludeTagGroup(tagGroup);
                }
            });
        }

        // load categories from params into view model
        if ($scope.filters.categories.length != $scope.categoryIds.length) {
            $scope.subcategories.forEach(function(subcategory) {
                if ($scope.filters.categories.indexOf(subcategory.id) > -1) {
                    subcategory.enabled = true;
                }
            });
        }

        // override some data from the generic controller
        $scope.actions = actionsFactory.modIndexActions();

        // manipulate data before displaying it on the view
        $scope.dataCallback = function() {
            $scope.mods.forEach(function(mod) {
                categoryService.resolveModCategories($scope.categories, mod);
            });
        };

        $scope.$watch('tagGroups', $scope.tagsChanged, true);
    };

    this.buildModsIndexState = function(label, filterPrototypes) {
        // convert label to dash format
        var dashLabel = label.underscore('-');

        // base params
        var params = {
            //column sort
            scol: 'submitted',
            sdir: 'DESC'
        };
        indexService.setDefaultParamsFromFilters(params, filterPrototypes);

        // construct and return the state
        return {
            stateName: 'base.mods-' + dashLabel,
            name: 'base.mods-' + dashLabel,
            templateUrl: '/resources/partials/browse/modsCategoryIndex.html',
            controller: label.toCamelCase() + 'Controller',
            url: indexService.getUrl('mods/' + dashLabel, params),
            params: params,
            type: 'lazy'
        };
    };
});