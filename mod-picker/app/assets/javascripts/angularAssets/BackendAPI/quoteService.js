app.service('quoteService', function (backend, $q) {
    function randomElement(array) {
        return array[Math.floor(Math.random() * array.length)]
    }

    this.retrieveQuotes = function () {
        return backend.retrieve('/quotes');
    };

    this.getRandomQuote = function (quotes, label) {
        if (label) {
            var filteredQuotes = quotes.filter(function(quote) {
                return (quote.label === label);
            });
            return randomElement(filteredQuotes);
        } else {
            return randomElement(quotes);
        }
    };
});