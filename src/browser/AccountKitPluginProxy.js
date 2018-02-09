

module.exports = {

  loginWithEmail: function(onSuccess, onFailure, options) {
    options = options || {};

      AccountKit.login('PHONE', options, function(response) {

        if (response.status === "PARTIALLY_AUTHENTICATED") {
          var code = response.code;
          var csrf = response.state;
          // Send code to server to exchange for access token
          onSuccess(response);
        }
        else if (response.status === "NOT_AUTHENTICATED") {
          // handle authentication failure
          onFailure(response);
        }
        else if (response.status === "BAD_PARAMS") {
          // handle bad parameters
          onFailure(response);
        }
      });

  },

  loginWithPhoneNumber: function(onSuccess, onFailure, options) {
  },

  getAccount: function(onSuccess, onFailure) {
  },

  logout: function(onSuccess, onFailure) {
  }

};

require('cordova/exec/proxy').add('AccountKitPlugin', module.exports);
