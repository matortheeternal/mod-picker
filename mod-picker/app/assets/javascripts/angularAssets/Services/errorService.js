app.service('errorService', function ($rootScope) {
    var service = this;

    this.createErrorLink = function(errors, errorResponse, id, baseId) {
        var url, label;
        switch(errorResponse.config.url) {
            case "/compatibility_notes.json":
                url = "#/mod/" + baseId + "/compatibility/" + id;
                label = "Compatibility Note";
                break;
            case "/install_order_notes.json":
                url = "#/mod/" + baseId + "/install-order/" + id;
                label = "Install Order Note";
                break;
            case "/load_order_notes.json":
                url = "#/mod/" + baseId + "/load-order/" + id;
                label = "Load Order Note";
                break;
        }
        errors.push({
            type: "error",
            text: "Click here to view the conflicting " + label,
            url: url
        });
    };

    this.errorMessages = function (label, errorResponse, resourceId) {
        var errors = [];

        // parse json errors into error messages if the response is json
        if (typeof errorResponse.data == "object") {
            // loop through response
            var data = errorResponse.data;
            for (var property in data) {
                if (data.hasOwnProperty(property)) {
                    // handle link_id errors
                    if (property === 'link_id') {
                        service.createErrorLink(errors, errorResponse, data[property], resourceId);
                        continue;
                    }
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
