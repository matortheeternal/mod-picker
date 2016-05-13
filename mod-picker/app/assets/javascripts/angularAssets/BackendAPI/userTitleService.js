app.service('userTitleService', function (backend, $q) {
    this.retrieveUserTitles = function () {
        return backend.retrieve('/user_titles');
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
        for (var i = 0; i < gameTitles.length; i++) {
            var title = gameTitles[i];
            if (reputation < title.rep_required) {
                return prevTitle.title;
            }
            prevTitle = title;
        }
        return prevTitle.title;
    };

    this.associateTitles = function(gameTitles, data) {
        var service = this;
        data.forEach(function(item) {
            // if user is defined and they don't have a custom title
            if (item.user && !item.user.title) {
                // get their default title
                item.user.title = service.getUserTitle(gameTitles, item.user.reputation.overall);
            }
        });
    }
});