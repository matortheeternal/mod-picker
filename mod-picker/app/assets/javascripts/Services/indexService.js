app.service('indexService', function(objectUtils) {
    var service = this;

    this.getUrl = function(base, params) {
        var output = '/'+base+'?';
        for (var property in params) {
            if (params.hasOwnProperty(property)) {
                if (typeof params[property] === 'string' || params[property] instanceof String) {
                    output += property;
                    output += '&';
                } else {
                    output += '{' + property + ':' + objectUtils.getShortTypeString(params[property]) + '}';
                    output += '&';
                }
            }
        }
        return output.slice(0, -1);
    };

    this.setSortFromParams = function(sort, params) {
        if (params.scol) {
            sort.column = params.scol;
        }
        if (params.sdir) {
            sort.direction = params.sdir;
        }
    };

    this.setFilterFromParam = function(filters, key, paramValue) {
        if (typeof paramValue !== "undefined") {
            if (key.indexOf(".") > -1) {
                objectUtils.setDeepValue(filters, key, paramValue);
            } else {
                filters[key] = paramValue;
            }
        }
    };

    this.setListFilterFromParam = function(filters, filter, paramValue) {
        if (paramValue) {
            var key = filter.data;
            if (filter.subtype === "Integer") {
                filters[key] = paramValue.split(',').map(function(val) {
                    return parseInt(val);
                });
            } else {
                filters[key] = paramValue.split(',');
            }
        }
    };

    this.setTagGroupFilterFromParam = function(filters, filter, paramValue) {
        if (paramValue) {
            var key = filter.data;
            filters[key] = paramValue.split(';').map(function(tagGroup) {
                var includedTags = [], excludedTags = [], obj = {};
                tagGroup.slice(1, -1).split(',').forEach(function(tagText) {
                    (tagText[0] == '-') ? excludedTags.push(tagText.slice(1)) : includedTags.push(tagText);
                });
                if (includedTags.length) obj.include = includedTags;
                if (excludedTags.length) obj.exclude = excludedTags;
                return obj;
            });
        }
    };

    this.setSliderFilterFromParam = function(filters, filter, paramValue) {
        var filterVals = paramValue.split('-');

        // special date filter handling
        if (filter.subtype === "Date") {
            filters[filter.data] = {
                min: filterVals[0].replace(/\./g, "/"),
                max: filterVals[1].replace(/\./g, "/")
            };
        } else {
            filters[filter.data] = {
                min: parseInt(filterVals[0]),
                max: parseInt(filterVals[1])
            };
        }
    };

    this.setDefaultParamsFromFilters = function(params, filterPrototypes) {
        filterPrototypes.forEach(function(filter) {
            if (filter.default) {
                params[filter.param] = filter.default;
            } else {
                params[filter.param] = '';
            }
        });
    };

    this.setFiltersFromParams = function(filters, filterPrototypes, stateParams) {
        filterPrototypes.forEach(function(filter) {
            // skip filters which we don't have a param set for
            if (!stateParams[filter.param]) {
                return;
            }

            // handle range filters (sliders)
            if (filter.type === 'Range') {
                service.setSliderFilterFromParam(filters, filter, stateParams[filter.param]);
            }
            // handle list filters
            else if (filter.type === 'List') {
                service.setListFilterFromParam(filters, filter, stateParams[filter.param]);
            }
            // handle tag group filters
            else if (filter.type === 'TagGroup') {
                service.setTagGroupFilterFromParam(filters, filter, stateParams[filter.param]);
            }
            // handle normal filters
            else {
                service.setFilterFromParam(filters, filter.data, stateParams[filter.param]);
            }
        });
    };

    this.getParams = function(filters, sort, filterPrototypes) {
        var params = {
            scol: sort.column,
            sdir: sort.direction
        };
        filterPrototypes.forEach(function(filter) {
            // this is the filter values stored on the scope of the view
            var filterValue = objectUtils.deepValue(filters, filter.data);

            // return if the filter has not been set
            if (filterValue === null) {
                return;
            }

            // if the filter is a range filter, it will have a min and max value
            if (filter.type === 'Range') {
                // special handling for date slider filters
                if (filter.subtype === 'Date') {
                    params[filter.param] = (filterValue.min + "-" + filterValue.max).replace(/\//g, ".");
                } else {
                    params[filter.param] = filterValue.min + "-" + filterValue.max;
                }
            }
            // else if the filter is a list filter, generate param as comma separated list
            else if (filter.type === 'List') {
                params[filter.param] = filterValue.join(',');
            }
            // else if the filter is a TagGroup filter, generate param as comma separated list
            else if (filter.type === 'TagGroup') {
                if (filterValue.reduce) {
                    var tagGroups = filterValue.reduce(function(a, group) {
                        var tags = angular.copy(group.exclude || []).map(function(tag) {
                            return '-' + tag;
                        }).concat(group.include || []);
                        return a.concat(['(' + tags.join(',') + ')']);
                    }, []);
                    params[filter.param] = tagGroups.join(';');
                }
            }
            // else if filter is a boolean filter, serialize to 1 or 0
            else if (filter.type === 'Boolean') {
                params[filter.param] = filterValue ? '1' : '0';
            }
            // else the filter should be just a value
            else {
                params[filter.param] = filterValue.toString();
            }
        });

        return params;
    };
});
