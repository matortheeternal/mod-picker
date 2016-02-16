/**
 * Created by r79 on 2/11/2016.
 */
app.service('backend', function ($q, $http) {

    //Constant to be flexible in the future. Us as prefix for ALL requests
    var BASE_LOCATION = '';

    //TODO: replace with REST Calls
    function retrieve(context, additionalAttributes) {
        var promise = $q.defer();
        $http({
            url: BASE_LOCATION + context + '.json',
            method: 'GET',
            params: additionalAttributes && additionalAttributes.params || undefined,
            cache: additionalAttributes && additionalAttributes.cache || false
        }).then(function (data) {
            promise.resolve(data.data);
        });
        return promise.promise;
    }
    this.retrieve = retrieve;
});