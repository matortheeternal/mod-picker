app.service('modService', function(backend, $q, categoryService, errorsFactory, pageUtils, objectUtils, contributionService, userTitleService, reviewSectionService, recordGroupService, pluginService, assetUtils) {
    var service = this;

    this.retrieveMods = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/index', options).then(function (data) {
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.searchMods = function(name, utility) {
        var postData =  {
            filters: {
                search: name
            }
        };
        if (angular.isDefined(utility)) {
            postData.filters.utility = utility;
        }
        return backend.post('/mods/search', postData);
    };

    this.searchModListMods = function(name) {
        var postData =  {
            filters: {
                search: name,
                include_games: true
            }
        };
        return backend.post('/mods/search', postData);
    };

    this.searchModListTools = function() {
        var postData =  {
            filters: {
                search: name,
                utility: true
            }
        };
        return backend.post('/mods/search', postData);
    };
    
    this.retrieveMod = function(modId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId).then(function(data) {
            categoryService.resolveModCategories(data);
            output.resolve(data);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.retrieveModContributions = function(modId, route, options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/' + modId + '/' + route, options).then(function (data) {
            var contributions = data[route];
            contributionService.associateHelpfulMarks(contributions, data.helpful_marks);
            contributionService.handleEditors(contributions);
            userTitleService.associateTitles(contributions);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(contributions);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModReviews = function(modId, options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/' + modId + '/reviews', options).then(function(data) {
            // prepare reviews
            var reviews = data.reviews;
            contributionService.associateHelpfulMarks(reviews, data.helpful_marks);
            userTitleService.associateTitles(reviews);
            reviewSectionService.associateReviewSections(reviews);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            // prepare user review if present
            if (data.user_review && data.user_review.id) {
                var user_review = [data.user_review];
                service.associateHelpfulMarks(user_review, data.helpful_marks);
                userTitleService.associateTitles(user_review);
                reviewSectionService.associateReviewSections(user_review);
            }
            // resolve data
            action.resolve({ reviews: data.reviews, user_review: data.user_review });
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModAnalysis = function(modId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + 'analysis').then(function (analysis) {
            // create nestedAssets tree
            analysis.nestedAssets = assetUtils.getNestedAssets(analysis.assets);
            assetUtils.sortNestedAssets(analysis.nestedAssets);

            // prepare plugin data for display
            recordGroupService.associateGroups(analysis.plugins);
            pluginService.combineAndSortMasters(analysis.plugins);
            pluginService.associateOverrides(analysis.plugins);
            pluginService.sortErrors(analysis.plugins);

            output.resolve(analysis);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.editMod = function(modId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/edit').then(function(data) {
            output.resolve(data);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.starMod = function(modId, starred) {
        if (starred) {
            return backend.delete('/mods/' + modId + '/star');
        } else {
            return backend.post('/mods/' + modId + '/star', {});
        }
    };

    this.submitMod = function (mod, sources, customSources) {
        // load earliest date released and latest date updated from sources
        var released = mod.released;
        var updated = mod.updated;
        for (var property in sources) {
            if (sources.hasOwnProperty(property) && sources[property]) {
                var source = sources[property];
                if (!released || source.released < released) {
                    released = source.released;
                }
                if (!updated || source.updated > updated) {
                    updated = source.updated;
                }
            }
        }

        // prepare required mods
        var required_mods = [];
        mod.requirements.forEach(function(requirement) {
            required_mods.push({
                required_id: requirement.required_id
            })
        });

        // prepare custom sources
        var custom_sources = [];
        customSources.forEach(function(source) {
            custom_sources.push({
                label: source.label,
                url: source.url
            })
        });

        // prepare mod record
        var modData = {
            mod: {
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                is_utility: mod.is_utility,
                has_adult_content: mod.has_adult_content,
                game_id: mod.game_id,
                released: released || DateTime.now(),
                updated: updated,
                primary_category_id: mod.categories[0],
                secondary_category_id: mod.categories[1],
                nexus_info_id: sources.nexus && sources.nexus.id,
                workshop_info_id: sources.workshop && sources.workshop.id,
                lover_info_id: sources.lab && sources.lab.id,
                tag_names: mod.newTags,
                asset_paths: mod.analysis.assets,
                plugin_dumps: mod.analysis.plugins,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };

        // submit mod
        return backend.post('/mods', modData);
    };

    this.updateMod = function(mod, sources, customSources) {
        // prepare mod authors
        if (mod.mod_authors) {
            var mod_authors = [];
            mod.mod_authors.forEach(function(author) {
                if (author._destroy) {
                    mod_authors.push({
                        id: author.id,
                        _destroy: true
                    })
                } else if (author.id) {
                    mod_authors.push({
                        id: author.id,
                        role: author.role
                    })
                } else {
                    mod_authors.push({
                        role: author.role,
                        user_id: author.user_id
                    })
                }
            });
        }

        // prepare required mods
        if (mod.requirements) {
            var required_mods = [];
            mod.requirements.forEach(function(requirement) {
                if (requirement._destroy) {
                    required_mods.push({
                        id: requirement.id,
                        _destroy: true
                    })
                } else {
                    required_mods.push({
                        required_id: requirement.required_id
                    })
                }
            });
        }

        // prepare custom sources
        var custom_sources = [];
        customSources.forEach(function(source) {
            custom_sources.push({
                id: source.id,
                label: source.label,
                url: source.url,
                _destroy: source._destroy
            })
        });

        // prepare mod record
        var modData = {
            mod: {
                id: mod.id,
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                is_utility: mod.is_utility,
                game_id: mod.game_id,
                released: mod.released,
                updated: mod.updated,
                primary_category_id: mod.primary_category_id,
                secondary_category_id: mod.secondary_category_id,
                nexus_info_id: sources.nexus && sources.nexus.id,
                workshop_info_id: sources.workshop && sources.workshop.id,
                lover_info_id: sources.lab && sources.lab.id,
                tag_names: mod.newTags,
                asset_paths: mod.analysis && mod.analysis.assets,
                plugin_dumps: mod.analysis && mod.analysis.plugins,
                mod_authors_attributes: mod_authors,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods,
                disallow_contributors: mod.disallow_contributors,
                disable_reviews: mod.disable_reviews,
                lock_tags: mod.lock_tags,
                has_adult_content: mod.has_adult_content,
                hidden: mod.hidden
            }
        };
        objectUtils.deleteEmptyProperties(modData, 1);

        // submit mod
        return backend.update('/mods/' + mod.id, modData);
    };

    this.submitImage = function(modId, image) {
        return backend.postFile('/mods/' + modId + '/image', 'image', image);
    };

    this.getInstallOrderMod = function(installOrder, modId) {
        return installOrder.find(function(item) {
            return item.mod_id == modId;
        });
    };

    this.associateInstallOrderMods = function(items, installOrder) {
        items.forEach(function(item) {
            item.mod = service.getInstallOrderMod(installOrder, item.mod_id);
        });
    };
});
