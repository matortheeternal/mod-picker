app.service('quoteService', function (backend, $q) {
    function randomElement(array) {
        return array[Math.floor(Math.random() * array.length)]
    }

    this.retrieveQuotes = function () {
        var quotes = $q.defer();
        backend.retrieve('/quotes').then(function (data) {
            setTimeout(function () {
                quotes.resolve(data);
            }, 1000);
        });
        return quotes.promise;
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