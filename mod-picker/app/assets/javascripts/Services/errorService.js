app.service('errorService', function($q) {
    var service = this;

    this.criticalError = function(response) {
        try {
            switch(response.status) {
                case 404:
                case 422:
                    window.location.href = '/' + response.status;
                    break;
                default:
                    window.location.href = '/500';
            }
        } catch (x) {
            console.log(x);
            window.location.href = '/500';
        }
    };

    this.frontendError = function(errorText, stateName, statusCode, statusText) {
        return {
            text: errorText,
            stateName: stateName,
            response: {
                status: statusCode,
                statusText: statusText,
                data: null
            },
            stateUrl: window.location.href
        };
    };

    this.criticalRequest = function(requestFunction, arg) {
        var request = $q.defer();
        try {
            requestFunction(arg).then(function(data) {
                request.resolve(data);
            }, function(response) {
                service.criticalError(response);
            });
            return request.promise;
        } catch (x) {
            console.log(x);
            window.location.href = '/500';
        }
    };

    this.createErrorLink = function(errors, errorResponse, id, baseId) {
        var url, label;
        switch(errorResponse.config.url) {
            case "/compatibility_notes.json":
                url = "mods/" + baseId + "/compatibility/" + id;
                label = "Compatibility Note";
                break;
            case "/install_order_notes.json":
                url = "mods/" + baseId + "/install-order/" + id;
                label = "Install Order Note";
                break;
            case "/load_order_notes.json":
                url = "mods/" + baseId + "/load-order/" + id;
                label = "Load Order Note";
                break;
        }
        errors.push({
            type: "error",
            text: "Click here to view the conflicting " + label,
            url: url
        });
    };

    this.generateErrors = function(label, errorResponse, resourceId, data) {
        // loop through errors array
        var errors = [];
        for (var property in data) {
            if (data.hasOwnProperty(property)) {
                // handle link_id errors
                if (property === 'link_id') {
                    service.createErrorLink(errors, errorResponse, data[property], resourceId);
                    continue;
                }
                for (var i = 0; i < data[property].length; i++) {
                    var item = data[property][i];
                    errors.push({
                        type: "error",
                        text: label + ", " + property + ": " + item
                    });
                }
            }
        }

        // return errors we generated
        return errors;
    };

    this.errorMessages = function(label, errorResponse, resourceId) {
        var errors = [];

        // parse json errors into error messages if the response is json
        if (typeof errorResponse.data == "object") {
            // loop through response
            var data = errorResponse.data;
            if (data.error) {
                errors.push({
                    type: "error",
                    text: label + ", " + data.error
                });
            } else {
                errors.unite(service.generateErrors(label, errorResponse, resourceId, data));
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

    this.flattenErrors = function(errorResponse) {
        var data = errorResponse.data;
        if (data.error) return [data.error];

        var errors = [];
        if (typeof data === "object") {
            for (var prop in data) {
                if (data.hasOwnProperty(prop)) {
                    data[prop].forEach(function(error) {
                        errors.push(prop.capitalize() + ": " + error);
                    });
                }
            }
        }
        return errors;
    };
});
