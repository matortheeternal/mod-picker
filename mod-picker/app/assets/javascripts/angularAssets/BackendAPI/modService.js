app.service('modService', function(backend, $q, pageUtils, objectUtils, contributionService, userTitleService, reviewSectionService, recordGroupService, pluginService, assetUtils) {
    var service = this;

    this.retrieveMods = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/index', options).then(function(data) {
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
        return backend.retrieve('/mods/' + modId);
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
                contributionService.associateHelpfulMarks(user_review, data.helpful_marks);
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

            // set default options to active
            analysis.mod_options.forEach(function(option) {
                option.active = option.default;
            });

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

    this.prepareModAuthors = function(mod) {
        var mod_authors = [];
        if (mod.mod_authors) {
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

        return mod_authors;
    };

    this.prepareRequiredMods = function(mod) {
        var required_mods = [];
        if (mod.requirements) {
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

        return required_mods;
    };

    this.prepareCustomSources = function(customSources) {
        var custom_sources = [];
        customSources.forEach(function(source) {
            custom_sources.push({
                id: source.id,
                label: source.label,
                url: source.url,
                _destroy: source._destroy
            })
        });

        return custom_sources;
    };

    this.prepareModOptions = function(mod) {
        var mod_options = [];
        mod.analysis.mod_options.forEach(function(option) {
            mod_options.push({
                name: option.name,
                size: option.size,
                default: option.default,
                is_fomod_option: option.is_fomod_option,
                plugin_dumps: option.plugins,
                asset_paths: option.assets
            })
        });
        objectUtils.deleteEmptyProperties(mod_options, 1);

        return mod_options;
    };

    // when mode is true: get earliest date
    // when mode is false: get latest date
    this.getDate = function(mod, sources, dateKey, dateTest) {
        var date = mod[dateKey];
        for (var property in sources) {
            if (sources.hasOwnProperty(property) && sources[property]) {
                var source = sources[property];
                if (!date || dateTest(source[dateKey], date)) {
                    date = source[dateKey];
                }
            }
        }

        return date;
    };

    this.submitMod = function(mod, sources, customSources) {
        // load earliest date released and latest date updated from sources
        var released = getDate(mod, sources, 'released', function(newDate, oldDate) {
            return newDate < oldDate;
        });
        var updated = getDate(mod, sources, 'updated', function(newDate, oldDate) {
            return newDate > oldDate;
        });

        // prepare associations
        var required_mods = prepareRequiredMods(mod);
        var custom_sources = prepareCustomSources(customSources);
        var mod_options = prepareModOptions(mod);

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
                mod_options_attributes: mod_options,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };
        objectUtils.deleteEmptyProperties(modData, 1);

        // submit mod
        return backend.post('/mods', modData);
    };

    this.updateMod = function(mod, sources, customSources) {
        // prepare associations
        var mod_authors = prepareModAuthors(mod);
        var required_mods = prepareRequiredMods(mod);
        var custom_sources = prepareCustomSources(customSources);
        var mod_options = prepareModOptions(mod);

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
                mod_options_attributes: mod_options,
                mod_authors_attributes: mod_authors,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods,
                config_files_attributes: mod.config_files,
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
            item.mod = angular.copy(service.getInstallOrderMod(installOrder, item.mod_id));
        });
    };
});
