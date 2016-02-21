/**
 * Created by r79 on 2/11/2016.
 */
app.factory('backend', function ($q, $http) {

    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';

    //TODO: replace with REST Calls
    function retrieve(context) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            cache: true
        }).then(function (data) {
            promise.resolve(data.data);
        });
        return promise.promise;
    }

    function mockRetrieve(location, additionalParam) {
        var currentPromise = $q.defer();

        var returnData = [];

        var async = false;

        switch (location) {
            case '/search':
                if (additionalParam && additionalParam.name) {
                    retrieve('/mods').then(function (mods) {
                        mods.forEach(function (mod) {
                            if (mod.name.toLowerCase().indexOf(additionalParam.name.toLowerCase()) > -1) {
                                returnData.push(mod);
                            }
                        });
                    });
                }
                break;

            case '/category':
                async = true;
                retrieve('/categories').then(function (data) {
                    data.forEach(function (category) {
                        if (additionalParam === 'primary' ? !category.parent_id : category.parent_id == additionalParam) {
                            returnData.push(category);
                        }
                    });
                    currentPromise.resolve(returnData);
                });
        }

        if (!async) {
            //I currently work with Timeout to give it the feel of needing to load stuff from the server
            setTimeout(function () {
                currentPromise.resolve(returnData);
            }, 1000);
        }

        return currentPromise.promise;
    }

    return {
        //caching layer and exposure
        retrieveMods: function () {
            return retrieve('/mods');
        },
        retrieveMod: function (id) {
            return retrieve('/mods/' + id);
        },
        retrieveUsers: function () {
            return retrieve('/users');
        },
        retrieveUser: function (id) {
            return retrieve('/users/' + id);
        },
        retrieveCompatibilityNotes: function () {
            return retrieve('/compatibility_notes');
        },
        retrieveInstallationNotes: function () {
            return retrieve('/installation_notes');
        },
        retrieveReviews: function () {
            return retrieve('/reviews');
        },
        search: function (searchParams) {
            //not implemented in the Backend yet
            return mockRetrieve('/search', searchParams);
        },
        retrievePrimaryCategory: function () {
            return mockRetrieve('/category', 'primary');
        },
        retrieveSecondaryCategory: function (primaryCategoryId) {
            return mockRetrieve('/category', primaryCategoryId);
        }
    }
});