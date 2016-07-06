app.service('modIndexService', function(filtersFactory) {
    var service = this;

    this.getParams = function() {
        var output = {
            //column sort
            scol: 'name',
            sdir: 'desc',

            //searches
            n: '',
            a: '',

            //modlist compatibility filter
            cf: true,

            //sources
            nm: true,
            sw: true,
            ll: true,
            ot: true,
            t: '',
            c: ''
        };
        var setFilterParam = function(filter) {
            output[filter.param] = '';
        };

        filtersFactory.modStatisticFilters().forEach(setFilterParam);
        filtersFactory.modPickerFilters().forEach(setFilterParam);
        filtersFactory.modDateFilters().forEach(setFilterParam);

        return output;
    };

    var params = this.getParams();

    this.getUrl = function() {
        var output = '/mods?';
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

    this.setSliderFiltersFromParams = function(filters, filterPrototypes, stateParams) {
        filterPrototypes.forEach(function(filter) {
            if (!stateParams[filter.param]) {
                return;
            }
            var filterVals = stateParams[filter.param].split('-');

            filters[filter.data] = {
                min: parseInt(filterVals[0]),
                max: parseInt(filterVals[1])
            };
        });
    };

    this.getParamsFromFilters = function(filters, filterPrototypes) {
        var params = {};
        var setParams = function(protoFilter) {
            // this is the filter values stored on the scope of the view
            var filter = filters[protoFilter.data];
            // if the filter has been set to a non-default value it will be defined
            if (filter) {
                // if the filter is a range filter, it will have a min and max value
                if (filter.min && filter.max) {
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

    this.state = {
        stateName: 'base.mods',
        name: 'base.mods',
        templateUrl: '/resources/partials/browse/mods.html',
        controller: 'modsController',
        url: service.getUrl(),
        params: params,
        type: 'lazy'
    };

});
