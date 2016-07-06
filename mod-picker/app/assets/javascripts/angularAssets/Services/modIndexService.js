app.service('modIndexService', function() {
    var service = this;

    this.getParams = function() {
        return {
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
            ot: true
        };
    };

    this.state = {
        stateName: 'base.mods',
        name: 'base.mods',
        templateUrl: '/resources/partials/browse/mods.html',
        controller: 'modsController',
        url: '/mods?sort',
        params: service.getParams(),
        type: 'lazy'

    };

});
