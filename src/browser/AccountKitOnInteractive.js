var AccountKit_OnInteractive = function() {

  AccountKit.init({
    appId:"{{FACEBOOK_APP_ID}}",
    state:"{{csrf}}",
    version:"{{ACCOUNT_KIT_API_VERSION}}",
    fbAppEventsEnabled: true,
    display: 'modal',
    debug: true
  });

};

module.exports = AccountKit_OnInteractive;
