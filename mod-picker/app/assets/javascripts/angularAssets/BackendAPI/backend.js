/**
 * Created by r79 on 2/11/2016.
 */
app.service('backend', function ($q, $http) {

    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';

    this.retrieve = function (context, additionalAttributes) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            params: additionalAttributes,
            cache: additionalAttributes && additionalAttributes.cache || false
        }).then(function (result) {
            promise.resolve(result.data);
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
        }).then(function (result) {
            promise.resolve(result.data);
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
        }).then(function (result) {
            promise.resolve(result.data);
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
        }).then(function (result) {
            promise.resolve(result.data);
        });
        return promise.promise;
    };

});