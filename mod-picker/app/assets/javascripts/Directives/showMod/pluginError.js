app.directive('pluginError', function () {
    return {
        scope: {
            error: '='
        },
        template: '{{template}}',
        link: function(scope) {
            switch(scope.error.group) {
                // OE
                case 0: 
                    scope.template = scope.error.data;
                    break;
                // ITM
                case 1:
                    scope.template = scope.error.name;
                    break;
                // ITPO
                case 2:
                    scope.template = scope.error.name;
                    break;
                // UDR
                case 3:
                    scope.template = scope.error.name +
                        '\n\r - Record marked as deleted but contains: ' + scope.error.data;
                    break;
                // UES
                case 4:
                    scope.template = scope.error.name +
                        '\n\r - Error: Record (' + scope.error.data.split(",")[0] + ') contains unexpected (or out of order) subrecord '+ scope.error.data.split(",")[1];
                    break;
                // URR
                case 5:
                    scope.template = scope.error.name +
                        '\n\r - ' + scope.error.path + ': [' + scope.error.data + '] < Error: Could not be resolved >';
                    break;
                // UER
                case 6:
                    scope.template = scope.error.name +
                        '\n\r - ' + scope.error.path + ': Found a (' + scope.error.data.split(",")[0] + ') reference, expected: ' + scope.error.data.split(",")[1];
                    break;
            }
        }
    }
});