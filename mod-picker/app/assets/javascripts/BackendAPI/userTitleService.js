app.service('userTitleService', function (backend, $q) {
    var service = this;

    this.retrieveUserTitles = function () {
        var userTitles = $q.defer();

        backend.retrieve('/user_titles').then(function(titles) {
            userTitles.resolve(titles);
        });
        return userTitles.promise;
    };

    this.getSortedGameTitles = function(titles) {
        var gameTitles = titles.filter(function(title) {
            return (title.game_id === window._current_game_id);
        });
        gameTitles.sort(function(a, b) {
            return a.rep_required - b.rep_required;
        });
        return gameTitles;
    };

    //initialize title variables
    var allTitles = this.retrieveUserTitles();

    var gameTitles = allTitles.then(function(titles) {
        return service.getSortedGameTitles(titles);
    });


    this.getUserTitle = function (reputation) {
        var output = $q.defer();
        gameTitles.then(function(titles) {
            var prevTitle = titles[0];
            for (var i = 0; i < titles.length; i++) {
                var title = titles[i];
                if (reputation < title.rep_required) {
                    output.resolve(prevTitle.title);
                    return;
                }
                prevTitle = title;
            }
            output.resolve(prevTitle.title);
        });
        return output.promise;
    };

    this.associateTitles = function(data) {
        data.forEach(function(item) {
            // if user is defined and they don't have a custom title
            if (item.submitter && !item.submitter.title) {
                // get their default title
                service.getUserTitle(item.submitter.reputation.overall).then(function(title) {
                    item.submitter.title = title;
                });
            }
        });
    };
});
