app.service('userTitleService', function (backend, $q, $timeout) {
    this.retrieveUserTitles = function () {
        var titles = $q.defer();
        backend.retrieve('/user_titles').then(function(data) {
            titles.resolve(data);
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
        for (var i = 0; i < gameTitles.length; i++) {
            var title = gameTitles[i];
            if (reputation < title.rep_required) {
                return prevTitle.title;
            }
            prevTitle = title;
        }
        return prevTitle.title;
    };

    this.associateTitles = function(data, userTitles) {
        var service = this;
        if (userTitles.length == 0) {
            $timeout(function() {
                service.associateTitles(data, userTitles);
            }, 100);
            return;
        }

        data.forEach(function(item) {
            // if user is defined and they don't have a custom title
            if (item.user && !item.user.title) {
                // get their default title
                item.user.title = service.getUserTitle(userTitles, item.user.reputation.overall);
            }
        });
    }
});