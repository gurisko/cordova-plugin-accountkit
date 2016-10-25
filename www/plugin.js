var exec = require('cordova/exec');

var PLUGIN_NAME = 'AccountKitPlugin';

var AccountKitPlugin = {
  loginWithPhoneNumber: function(s, f) {
    exec(s, f, PLUGIN_NAME, 'loginWithPhoneNumber', []);
  },
  loginWithEmail: function(s, f) {
    exec(s, f, PLUGIN_NAME, 'loginWithEmail', []);
  },
  getAccessToken: function(s, f) {
    exec(s, f, PLUGIN_NAME, 'getAccessToken', []);
  },
  logout: function(s, f) {
    exec(s, f, PLUGIN_NAME, 'logout', []);
  }
};

module.exports = AccountKitPlugin;
