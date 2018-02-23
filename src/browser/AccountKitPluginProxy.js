var AccountKitPlugin = {

  /* params
  {
      initialEmail: [initial email]
  }
  */
  loginWithEmail: function(params, onSuccess, onFailure) {

    var options = {};

    if (params.useAccessToken) {
      onFailure({error:"BAD_PARAMS"});
      return;
    }

    if (params.initialEmail) {
      options.emailAddress = params.initialEmail;
    }

    AccountKit.login('EMAIL', options, function(response) {

      if (response.status === "PARTIALLY_AUTHENTICATED") {
        var code = response.code;
        var csrf = response.state;
        // Send code to server to exchange for access token
        onSuccess({code:code, state:csrf});
      }
      else if (response.status === "NOT_AUTHENTICATED") {
        // handle authentication failure
        onFailure({error:"NOT_AUTHENTICATED"});
      }
      else if (response.status === "BAD_PARAMS") {
        // handle bad parameters
        onFailure({error:"BAD_PARAMS"});
      }
    });

  },

  /* params
  {
      defaultCountryCode: [country code],
      initialPhoneNumber: [initial phone number]
  }
  */
  loginWithPhoneNumber: function(params, onSuccess, onFailure) {

    var options = {};

    if (params.useAccessToken) {
      onFailure({error:"BAD_PARAMS"});
      return;
    }

    if (params.defaultCountryCode) {
      options.countryCode = params.defaultCountryCode;
    }
    if (params.initialPhoneNumber) {
      options.phoneNumber = params.initialPhoneNumber;
    }

    AccountKit.login('PHONE', options, function(response) {

      console.log(response);

      if (response.status === "PARTIALLY_AUTHENTICATED") {
        var code = response.code;
        var csrf = response.state;
        // Send code to server to exchange for access token
        onSuccess({code:code, state:csrf});
      }
      else if (response.status === "NOT_AUTHENTICATED") {
        // handle authentication failure
        onFailure({error:response.status});
      }
      else if (response.status === "BAD_PARAMS") {
        // handle bad parameters
        onFailure({error:response.status});
      }
    });
  },

  getAccount: function(onSuccess, onFailure) {
    onFailure({error:"NOT_SUPPORTED"});
  },

  logout: function(onSuccess, onFailure) {
    onFailure({error:"NOT_SUPPORTED"});
  }

};

module.exports = AccountKitPlugin;
require('cordova/exec/proxy').add('AccountKitPlugin', module.exports);
