app.service('helpfulMarkService', function (fileUtils) {
    this.associateHelpfulMarks = function(data, helpfulMarks) {
        // loop through data
        data.forEach(function(item) {
            // see if we have a matching helpful mark
            var helpfulMark = helpfulMarks.find(function(mark) {
                return mark.helpfulable_id == item.id;
            });
            // if we have a matching helpful mark, assign it to the item
            if (helpfulMark) {
                item.helpful = helpfulMark.helpful;
            }
        });
    };
});
