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

    this.getUserTitle = function (titles, reputation) {
        var prevTitle = "";
        var gameTitles = titles.filter(function(title) {
            return (title.game_id === window._current_game_id);
        });
        gameTitles.forEach(function(title) {
            if (reputation < title.rep_required) {
                return prevTitle;
            }
            prevTitle = title;
        });
    };
});