app.service('quoteService', function (backend, $q) {
    function randomElement(array) {
        return array[Math.floor(Math.random() * array.length)];
    }

    this.retrieveQuotes = function () {
        return backend.retrieve('/quotes');
    };

    var allQuotes = this.retrieveQuotes();

    this.getRandomQuote = function (label) {
        var output = $q.defer();
        allQuotes.then(function(quotes) {
            if (label) {
                var filteredQuotes = quotes.filter(function(quote) {
                    return (quote.label === label);
                });
                output.resolve(randomElement(filteredQuotes));
            } else {
                output.resolve(randomElement(quotes));
            }
        });
        return output.promise;
    };
});
