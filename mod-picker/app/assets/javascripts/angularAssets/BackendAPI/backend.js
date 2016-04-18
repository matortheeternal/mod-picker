/**
 * Created by r79 on 2/11/2016.
 */
//TODO: this whole service feels like there is some redundancy to kill ;)
app.service('backend', function ($q, $http) {
    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';

    //This function is only there to set a global timeout for all requests to mock a slow response from the server
    //Why, you might ask: To see how the page behaves when the server is loaded too heavily and to check high ping
    //connections.
    function resolver(promise, result) {
        //TODO: remove Timeout before going live!!!
        //setTimeout(function () {
            promise.resolve(result.data);
        //}, 500);
    }

    this.retrieve = function (context, additionalAttributes) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            params: additionalAttributes,
            cache: additionalAttributes && additionalAttributes.cache || false
        }).then(function(result) {
            resolver(promise, result);
        });
        return promise.promise;
    };

    this.post = function (context, data) {
        var promise = $q.defer();
        data.authenticity_token = window._token;
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'POST',
            data: data
        }).then(function(result) {
            resolver(promise, result);
        });
        return promise.promise;
    };

    this.postFile = function (context, key, file) {
        var promise = $q.defer();

        var data = new FormData();
        data.append(key, file);
        data.append('authenticity_token', window._token);

        $http.post(BASE_LOCATION + context, data, {
            transformRequest: angular.identity,
            headers: {
                'Content-Type': undefined
            }
        }).then(function(result) {
            resolver(promise, result);
        });
        return promise.promise;
    };

    this.update = function (context, data) {
        var promise = $q.defer();
        data.authenticity_token = window._token;
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'PATCH',
            data: data
        }).then(function(result) {
            resolver(promise, result);
        });
        return promise.promise;
    };

    this.delete = function (context) {
        var promise = $q.defer();
        data = {};
        data.authenticity_token = window._token;
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'DELETE',
            params: data
        }).then(function(result) {
            resolver(promise, result);
        });
        return promise.promise;
    };

});