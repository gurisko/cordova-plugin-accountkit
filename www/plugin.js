var exec = require('cordova/exec');

var PLUGIN_NAME = 'AccountKitPlugin';

var AccountKitPlugin = {
  loginWithEmail: function(options, onSuccess, onFailure) {
    options = options || {};
    exec(onSuccess, onFailure, PLUGIN_NAME, 'loginWithEmail', [options]);
  },

  loginWithPhoneNumber: function(options, onSuccess, onFailure) {
    options = options || {};
    exec(onSuccess, onFailure, PLUGIN_NAME, 'loginWithPhoneNumber', [options]);
  },

  getAccount: function(onSuccess, onFailure) {
    exec(onSuccess, onFailure, PLUGIN_NAME, 'getAccount', []);
  },

  logout: function(onSuccess, onFailure) {
    exec(onSuccess, onFailure, PLUGIN_NAME, 'logout', []);
  }
};

module.exports = AccountKitPlugin;
