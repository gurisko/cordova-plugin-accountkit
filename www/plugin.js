var exec = require('cordova/exec');

var PLUGIN_NAME = 'AccountKitPlugin';

var AccountKitPlugin = {
  loginWithPhoneNumber: function(s, f, o) {
    exec(s, f, PLUGIN_NAME, 'loginWithPhoneNumber', [o]);
  },
  loginWithEmail: function(s, f, o) {
    exec(s, f, PLUGIN_NAME, 'loginWithEmail', [o]);
  },
  getAccessToken: function(s, f) {
    exec(s, f, PLUGIN_NAME, 'getAccessToken', []);
  },
  logout: function(s, f) {
    exec(s, f, PLUGIN_NAME, 'logout', []);
  }
};

module.exports = AccountKitPlugin;
