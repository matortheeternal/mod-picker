/**
 * Created by r79 on 2/11/2016.
 */
//TODO: this whole service feels like there is some redundancy to kill ;)
app.service('backend', function ($q, $http, objectUtils) {
    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';

    this.retrieve = function (context, options) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            params: options,
            cache: options && options.cache || false
        }).then(function(response) {
            promise.resolve(response.data);
        }, function(response) {
            promise.reject(response);
        });
        return promise.promise;
    };

    this.post = function (context, data) {
        var promise = $q.defer();
        var reqData = objectUtils.shallowCopy(data);
        reqData.authenticity_token = window._token;
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'POST',
            data: reqData
        }).then(function(response) {
            promise.resolve(response.data);
        }, function(response) {
            promise.reject(response);
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
        }).then(function(response) {
            promise.resolve(response.data);
        }, function(response) {
            promise.reject(response);
        });
        return promise.promise;
    };

    this.update = function (context, data) {
        var promise = $q.defer();
        var reqData = objectUtils.shallowCopy(data);
        reqData.authenticity_token = window._token;
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'PATCH',
            data: reqData
        }).then(function(response) {
            promise.resolve(response.data);
        }, function(response) {
            promise.reject(response);
        });
        return promise.promise;
    };

    this.delete = function (context, options) {
        var promise = $q.defer();
        var reqData = objectUtils.shallowCopy(options || {});
        reqData.authenticity_token = window._token;
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'DELETE',
            params: reqData
        }).then(function(response) {
            promise.resolve(response.data);
        }, function(response) {
            promise.reject(response);
        });
        return promise.promise;
    };

});
