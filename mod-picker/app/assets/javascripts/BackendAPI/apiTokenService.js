app.service('apiTokenService', function(backend) {
    var service = this;

    this.retrieveUserTokens = function(userId) {
        return backend.retrieve('/users/' + userId + '/api_tokens');
    };

    this.expireToken = function(tokenId) {
        return backend.delete('/api_tokens/' + tokenId);
    };

    this.getTokenPostData = function(name) {
        return {
            api_token: {
                name: name
            }
        };
    };

    this.createToken = function(name) {
        var postData = service.getTokenPostData(name);
        return backend.post('/api_tokens', postData);
    };

    this.updateToken = function(token) {
        var postData = service.getTokenPostData(token.name);
        return backend.update('/api_tokens/' + token.id, postData);
    }
});
