app.service('modIndexService', function() {
    var service = this;

    this.getParams = function() {
        return {
            //column sort
            sort: 'name',
            direction: 'desc',

            //searches
            'name-search': '',
            'author-search': '',

            //sources
            nexus: 'true',
            steam: 'true',
            lovers: 'true',
            other: 'true',
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
