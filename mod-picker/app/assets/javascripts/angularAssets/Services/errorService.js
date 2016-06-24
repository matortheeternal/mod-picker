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
            type: "error",
            text: label + ", " + errorResponse.status + ": " + errorResponse.statusText
        }
    };
});
