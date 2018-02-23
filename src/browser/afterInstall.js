var xml2js = require('xml2js');
var fs = require('fs');
var path = require('path');
var replace = require('replace');


function readConfig() {

  var configPath = path.resolve(__dirname,'..','..','..','..','config.xml');
  var parser = new xml2js.Parser();

  console.log('Parsing config: ', configPath);

  return new Promise( function(fulfill, reject) {

    fs.readFile(configPath, function(err, data) {

        parser.parseString(data, function (err, result) {

          var plugins = result.widget.plugin;
          var config = plugins.find(function(plugin) {
            return plugin.$.name === 'cordova-plugin-accountkit';
          });

          fulfill(config);

        });
    });
  });

}

readConfig().then(function(config) {

  var options = {
    state: '__dummy_csrf__',
    debug: true
  };
  config.variable.forEach(function(variable) {
    if (variable.$.name === 'APP_ID') {
      options.appId = variable.$.value;
    } else if (variable.$.name === 'API_VERSION') {
      options.version = variable.$.value;
    }

  });

  return options;

}).then(function(options) {

  console.log(options);
  var optionsPath =
    path.resolve(__dirname,'..','..','..','..',
      'platforms',
      'browser',
      'platform_www',
      'plugins',
      'cordova-plugin-accountkit',
      'src',
      'browser',
      'AccountKitOnInteractive.js');

  replace({
    regex: '{{FACEBOOK_APP_ID}}',
    replacement: options.appId,
    paths:[optionsPath],
    recursive:false,
    silent: true
  });

  replace({
    regex: '{{csrf}}',
    replacement: options.state,
    paths:[optionsPath],
    recursive:false,
    silent: true
  });

  replace({
    regex: '{{ACCOUNT_KIT_API_VERSION}}',
    replacement: options.version,
    paths:[optionsPath],
    recursive:false,
    silent: true
  });

  console.log('Done');
});
