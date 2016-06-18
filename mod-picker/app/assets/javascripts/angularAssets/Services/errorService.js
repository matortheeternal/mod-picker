app.service('errorService', function ($rootScope, $location) {
    this.handleError = function (label, errorResponse) {
        $rootScope.error = {
            code: errorResponse.status,
            url: errorResponse.request_url,
            label: label
        };
    };

    this.errorMessage = function (label, errorResponse) {
        return {
            message: label + ", " + errorResponse.status + ": " + errorResponse.statusText
        }
    };
});
