var exec = require('cordova/exec');

var PLUGIN_NAME = 'AccountKitPlugin';

var AccountKitPlugin = {
  loginWithPhone: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'loginWithPhone', []);
  },
  loginWithEmail: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'loginWithEmail', []);
  },
  logout: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'logout', []);
  }
};

module.exports = AccountKitPlugin;
