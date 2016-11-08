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

    this.searchModOptions = function(name, modIds) {
        var postData = {
            filters: {
                search: name
            }
        };
        if (angular.isDefined(modIds)) {
            postData.filters.mods = modIds;
        }
        return backend.post('/mod_options/search', postData);
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

    this.searchModListTools = function(str) {
        var postData =  {
            filters: {
                search: str,
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
        backend.post('/mods/' + modId + '/' + route, options).then(function(data) {
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
        backend.retrieve('/mods/' + modId + '/' + 'analysis').then(function(analysis) {
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

    this.newMod = function() {
        return backend.retrieve('/mods/new');
    };

    this.editMod = function(modId) {
        return backend.retrieve('/mods/' + modId + '/edit');
    };

    this.starMod = function(modId, starred) {
        if (starred) {
            return backend.delete('/mods/' + modId + '/star');
        } else {
            return backend.post('/mods/' + modId + '/star', {});
        }
    };

    this.hideMod = function(modId, hidden) {
        return backend.post('/mods/' + modId + '/hide', {hidden: hidden});
    };

    this.approveMod = function(modId, approved) {
        return backend.post('/mods/' + modId + '/approve', {approved: approved});
    };

    this.prepareModAuthors = function(mod) {
        var mod_authors = [];
        mod.mod_authors && mod.mod_authors.forEach(function(author) {
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

        return mod_authors;
    };

    this.prepareRequiredMods = function(mod) {
        var required_mods = [];
        mod.requirements && mod.requirements.forEach(function(requirement) {
            if (requirement._destroy) {
                required_mods.push({
                    id: requirement.id,
                    _destroy: true
                })
            } else if (!requirement.hasOwnProperty('id')) {
                required_mods.push({
                    required_id: requirement.required_id
                })
            }
        });

        return required_mods;
    };

    this.prepareCustomSources = function(customSources) {
        if (!customSources) return null;
        var custom_sources = [];
        customSources && customSources.forEach(function(source) {
            custom_sources.push({
                id: source.id,
                label: source.label,
                url: source.url,
                _destroy: source._destroy
            })
        });

        return custom_sources;
    };

    this.sanitizePlugin = function(plugin) {
        return {
            id: plugin.id,
            _destroy: plugin._destroy,
            author: plugin.author,
            filename: plugin.filename,
            crc_hash: plugin.crc_hash,
            description: plugin.description,
            file_size: plugin.file_size,
            record_count: plugin.record_count,
            override_count: plugin.override_count,
            master_plugins: plugin.master_plugins,
            dummy_masters: plugin.dummy_masters,
            overrides_attributes: plugin.overrides_attributes,
            plugin_errors_attributes: plugin.plugin_errors_attributes,
            plugin_record_groups_attributes: plugin.plugin_record_groups_attributes
        };
    };

    this.sanitizePlugins = function(plugins) {
        var sanitizedPlugins = [];
        plugins.forEach(function(plugin) {
            sanitizedPlugins.push(service.sanitizePlugin(plugin));
        });
        objectUtils.deleteEmptyProperties(sanitizedPlugins, 1);
        return sanitizedPlugins;
    };

    this.sanitizeModOption = function(option) {
        var sanitizedPlugins = service.sanitizePlugins(option.plugins);
        return {
            id: option.id,
            _destroy: option._destroy,
            name: option.name,
            display_name: option.display_name,
            size: option.size,
            default: option.default,
            is_fomod_option: option.is_fomod_option,
            plugin_dumps: sanitizedPlugins,
            asset_paths: option.assets
        };
    };

    this.buildDestroyedOldPlugins = function(newOption, mod) {
        if (!newOption.id || newOption._destroy || !mod.mod_options) return;
        var oldOption = mod.mod_options.find(function(oldOption) {
            return newOption.id == oldOption.id;
        });
        oldOption.plugins.forEach(function(plugin) {
            if (!plugin._destroy) return;
            newOption.plugin_dumps.push({
                id: plugin.id,
                _destroy: true
            });
        });
    };

    this.buildNewModOptions = function(options, mod) {
        mod.analysis.mod_options.forEach(function(option) {
            var newOption = service.sanitizeModOption(option);
            service.buildDestroyedOldPlugins(newOption, mod);
            options.push(newOption);
        });
    };

    this.buildOldModOptions = function(options, mod) {
        mod.mod_options.forEach(function(option) {
            options.push(service.sanitizeModOption(option));
        });
    };

    this.buildDestroyedOldModOptions = function(options, mod) {
        if (!mod.mod_options) return;
        mod.mod_options.forEach(function(option) {
            if (!option._destroy) return;
            var newOption = options.find(function(newOption) {
                return option.id == newOption.id;
            });
            if (!newOption) {
                options.push({
                    id: option.id,
                    _destroy: true
                });
            }
        });
    };

    this.prepareModOptions = function(mod) {
        var options = [];
        if (mod.analysis) {
            service.buildDestroyedOldModOptions(options, mod);
            service.buildNewModOptions(options, mod);
        } else if (mod.mod_options) {
            service.buildOldModOptions(options, mod);
        }
        objectUtils.deleteEmptyProperties(options, 1);
        return options;
    };
    
    this.getDate = function(mod, dateKey, dateTest) {
        var date = mod[dateKey];
        var sourceKeys = ["nexus", "lab", "workshop"];
        sourceKeys.forEach(function(sourceKey) {
            if (mod.hasOwnProperty(sourceKey) && mod[sourceKey]) {
                var source = mod[sourceKey];
                if (!date || dateTest(source[dateKey], date)) {
                    date = source[dateKey];
                }
            }
        });

        return date;
    };

    this.submitMod = function(mod) {
        // load earliest date released and latest date updated from sources
        var released = service.getDate(mod, 'released', function(newDate, oldDate) {
            return newDate < oldDate;
        });
        var updated = service.getDate(mod, 'updated', function(newDate, oldDate) {
            return newDate > oldDate;
        });

        // prepare associations
        var required_mods = service.prepareRequiredMods(mod);
        var custom_sources = service.prepareCustomSources(mod.custom_sources);
        var mod_options = service.prepareModOptions(mod);

        // prepare mod record
        var modData = {
            mod: {
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                is_utility: mod.is_utility,
                has_adult_content: mod.has_adult_content,
                curate: mod.curate,
                game_id: mod.game_id,
                released: released || DateTime.now(),
                updated: updated,
                primary_category_id: mod.categories[0],
                secondary_category_id: mod.categories[1],
                nexus_info_id: mod.nexus && mod.nexus.id,
                workshop_info_id: mod.workshop && mod.workshop.id,
                lover_info_id: mod.lab && mod.lab.id,
                tag_names: mod.tags,
                mod_options_attributes: mod_options,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };
        objectUtils.deleteEmptyProperties(modData, 1);

        // submit mod
        return backend.post('/mods', modData);
    };

    this.getModData = function(mod) {
        // prepare associations
        var mod_authors = service.prepareModAuthors(mod);
        var required_mods = service.prepareRequiredMods(mod);
        var custom_sources = service.prepareCustomSources(mod.custom_sources);
        var mod_options = service.prepareModOptions(mod);

        // prepare mod record
        var modData = {
            mod: {
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                status: mod.status,
                is_utility: mod.is_utility,
                game_id: mod.game_id,
                released: mod.released,
                updated: mod.updated,
                mark_updated: mod_options.length > 0,
                primary_category_id: mod.primary_category_id,
                secondary_category_id: mod.secondary_category_id || null,
                nexus_info_id: mod.nexus && mod.nexus.id,
                workshop_info_id: mod.workshop && mod.workshop.id,
                lover_info_id: mod.lab && mod.lab.id,
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
                hidden: mod.hidden,
                approved: mod.approved
            }
        };
        objectUtils.deleteEmptyProperties(modData, 1);

        return modData;
    };

    this.getDifferentModValues = function(originalMod, mod) {
        var originalModData = service.getModData(originalMod);
        var modData = service.getModData(mod);
        return objectUtils.getDifferentObjectValues(originalModData, modData);
    };

    this.updateMod = function(modId, modData) {
        return backend.update('/mods/' + modId, modData);
    };

    this.submitImage = function(modId, image) {
        return backend.postFile('/mods/' + modId + '/image', 'image', image);
    };

    this.getInstallOrderMod = function(installOrder, modOptionId) {
        return installOrder.find(function(item) {
            return item.mod_list_mod_options.find(function(option) {
                return option.mod_option_id == modOptionId;
            });
        });
    };

    this.associateInstallOrderMods = function(items, installOrder) {
        items.forEach(function(item) {
            item.mod = angular.copy(service.getInstallOrderMod(installOrder, item.mod_option_id));
        });
    };
});
