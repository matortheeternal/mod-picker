app.service('errorService', function ($rootScope, $location) {
    this.handleError = function (label, errorResponse) {
        $rootScope.error = {
            code: errorResponse.status,
            url: errorResponse.request_url,
            label: label
        };
    };

    this.errorMessages = function (label, errorResponse) {
        var errors = [];

        // parse json errors into error messages if the response is json
        if (typeof errorResponse.data == "object") {
            // loop through response
            var data = errorResponse.data;
            for (var property in data) {
                if (data.hasOwnProperty(property)) {
                    // loop through errors array
                    for (var i = 0; i < data[property].length; i++) {
                        var item = data[property][i];
                        errors.push({
                            type: "error",
                            text: label + ", " + property + ": " + item
                        })
                    }
                }
            }
            // return errors array if we found any in the response json
            if (errors.length) {
                return errors;
            }
        }

        // default return
        return [{
            type: "error",
            text: label + ", " + errorResponse.status + ": " + errorResponse.statusText
        }]
    };
});
