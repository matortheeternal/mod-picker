app.service('userTitleService', function (backend, $q) {
    this.retrieveUserTitles = function () {
        var titles = $q.defer();
        backend.retrieve('/user_titles').then(function (data) {
            setTimeout(function () {
                titles.resolve(data);
            }, 1000);
        });
        return titles.promise;
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

    this.getUserTitle = function (gameTitles, reputation) {
        var prevTitle = gameTitles[0];
        gameTitles.forEach(function(title) {
            if (reputation < title.rep_required) {
                return prevTitle;
            }
            prevTitle = title;
        });
    };
});