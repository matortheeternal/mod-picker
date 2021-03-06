app.service('backend', function($q, $http, objectUtils) {
    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';
    var service = this;

    this.retrieve = function(context, params) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            params: params,
            cache: params && params.cache || false
        }).then(function(response) {
            promise.resolve(response.data);
        }, function(response) {
            promise.reject(response);
        });
        return promise.promise;
    };

    this.post = function(context, data) {
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

    this.postFormData = function(context, data) {
        var promise = $q.defer();
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
        return promise.promise
    };

    this.postFile = function(context, key, file) {
        var data = new FormData();
        data.append(key, file);
        data.append('authenticity_token', window._token);
        return service.postFormData(context, data);
    };

    this.postImages = function(context, images) {
        var data = new FormData();
        images.forEach(function(image) {
            data.append(image.label, image.file);
        });
        data.append('authenticity_token', window._token);
        return service.postFormData(context, data);
    };

    this.update = function(context, data) {
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

    this.delete = function(context, params) {
        var promise = $q.defer();
        var reqData = objectUtils.shallowCopy(params || {});
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
