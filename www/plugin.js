var exec = require('cordova/exec');

var PLUGIN_NAME = 'AccountKitPlugin';

var AccountKitPlugin = {
  loginWithPhoneNumber: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'loginWithPhoneNumber', []);
  },
  loginWithEmail: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'loginWithEmail', []);
  },
  getAccessToken: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'getAccessToken', []);
  },
  logout: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'logout', []);
  }
};

module.exports = AccountKitPlugin;
