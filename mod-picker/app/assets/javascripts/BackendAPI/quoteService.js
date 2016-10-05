app.service('quoteService', function(backend, $q) {
    function randomElement(array) {
        return array[Math.floor(Math.random() * array.length)];
    }

    this.retrieveQuotes = function() {
        return backend.retrieve('/quotes');
    };

    var allQuotes = this.retrieveQuotes();

    this.getRandomQuote = function(label) {
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

    this.getErrorQuote = function(errorCode) {
        var errorQuotes = [{
            codes: [401, 403, 550],
            quotes: [
                "Hmm. I still don't like it, but I guess I'll overlook it. This time.",
                "My cousin is out fighting dragons. And what do I get? Guard duty.",
                "Let me guess, someone stole your sweetroll?"
            ],
            class: "guard-quote"
        }, {
            codes: [404, 410],
            quotes: [
                "I'm fairly certain you've wandered into the wrong building, friend.",
                "Move along citizen!",
                "Citizen, you must be lost, the tavern is down the road a piece."
            ],
            class: "penitus-quote"
        }, {
            codes: [429, 503],
            quotes: [
                "I can't carry any more.",
                "I am sworn to carry your burdens.",
                "There's something... wrong here."
            ],
            class: "lydia-quote"
        }, {
            codes: [500],
            quotes: [
                "The butler did it! Or is it the advisor? Whoever that man behind the throne was.",
                "Hmmmm... 'Fixed' is such a subjective term. I think 'treated' is far more appropriate, don't you? Like one does to a rash, or an arrow in the face.",
                "Cheese! For everyone!"
            ],
            class: "sheogorath-quote"
        }];

        // get the object matching the input errorCode OR the last quote object in the array
        var obj = errorQuotes.find(function(quote) {
            return quote.codes.indexOf(errorCode) > -1;
        }) || errorQuotes[errorQuotes.length - 1];

        // return a random quote from the object
        return {
            text: randomElement(obj.quotes),
            class: obj.class
        }
    };
});
