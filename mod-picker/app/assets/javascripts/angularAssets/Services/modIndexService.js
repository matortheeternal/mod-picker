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
