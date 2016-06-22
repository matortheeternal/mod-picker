app.service('errorService', function ($rootScope, $location) {
    this.handleError = function (label, errorResponse) {
        $rootScope.error = {
            code: errorResponse.status,
            url: errorResponse.request_url,
            label: label
        };
    };
});
