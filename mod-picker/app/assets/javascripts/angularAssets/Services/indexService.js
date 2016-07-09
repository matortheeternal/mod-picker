app.service('indexService', function() {
    this.getUrl = function(base, params) {
        var output = '/'+base+'?';
        for (var property in params) {
            if (params.hasOwnProperty(property)) {
                if (typeof params[property] === 'string' || params[property] instanceof String) {
                    output += property;
                    output += '&';
                } else {
                    output += '{' + property + ':' + getShortTypeString(params[property]) + '}';
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
        if (paramValue) {
            filters[key] = paramValue;
        }
    };

    this.setListFilterFromParam = function(filters, key, paramValue) {
        if (paramValue) {
            filters[key] = paramValue.split(',');
        }
    };

    this.setParamFromFilter = function(filters, key, params, paramKey) {
        if (filters.hasOwnProperty(key)) {
            params[paramKey] = filters[key];
        }
    };

    this.setListParamFromFilter = function(filters, key, params, paramKey) {
        if (filters.hasOwnProperty(key)) {
            params[paramKey] = filters[key].join(',');
        }
    };

    this.setSliderFiltersFromParams = function(filters, filterPrototypes, stateParams) {
        filterPrototypes.forEach(function(filter) {
            if (!stateParams[filter.param]) {
                return;
            }
            var filterVals = stateParams[filter.param].split('-');

            // special date filter handling
            if (filter.type === 'Date') {
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
        });
    };

    this.getParamsFromSliderFilters = function(filters, filterPrototypes) {
        var params = {};
        var setParams = function(protoFilter) {
            // this is the filter values stored on the scope of the view
            var filter = filters[protoFilter.data];
            // if the filter has been set to a non-default value it will be defined
            if (filter) {
                // special handling for date slider filters
                if (protoFilter.type === 'Date') {
                    params[protoFilter.param] = (filter.min + "-" + filter.max).replace(/\//g, ".");
                }
                // if the filter is a range filter, it will have a min and max value
                else if (filter.hasOwnProperty('min') && filter.hasOwnProperty('max')) {
                    params[protoFilter.param] = filter.min + "-" + filter.max;
                }
                // else if the filter is an array, make it into a comma separate list
                else if (filter.constructor === Array) {
                    params[protoFilter.param] = filter.join(',');
                }
                // else the filter should be just a value
                else {
                    params[protoFilter.param] = filter.toString();
                }
            }
        };

        filterPrototypes.forEach(setParams);

        return params;
    };
});
