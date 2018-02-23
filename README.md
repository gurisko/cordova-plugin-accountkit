[![npm version](https://badge.fury.io/js/cordova-plugin-accountkit.svg)](https://badge.fury.io/js/cordova-plugin-accountkit)

Cordova AccountKit Plugin
======

The Apache Cordova wrapper around the Facebook [AccountKit](https://www.accountkit.com/).


## Installation

1. Create Facebook Developer Account
2. Get a Facebook App ID  (`APP_ID`)
3. Get an AccountKit client token (`CLIENT_TOKEN`)
4. To install the plugin in your app, execute the following (replace variables where necessary):

```bash
cordova plugin add cordova-plugin-accountkit --save \
   --variable APP_ID="123456789" \
   --variable APP_NAME="myApplication" \
   --variable CLIENT_TOKEN="abcdefghijklmnopqrstuvwxyz" \
   --variable API_VERSION="v1.1"
```

If you need to change your `APP_ID` after installation, it's recommended that you remove and then re-add the plugin as above. Note that changes to the `APP_ID` value in your `config.xml` file will *not* be propagated to the individual platform builds.

### Additional Steps
If you want to use Access Tokens flow with this plugin, you have to set _Enable Client Access Token Flow_ in your app's dashboard to **ON** (for more information on Client Access Token Flow, see [Access Tokens and Authorization Codes](https://developers.facebook.com/docs/accountkit/accesstokens)).

### Android

It is recommended to add these permission to `config.xml` of your Cordova project to reduce the friction during the login process ([more info](https://developers.facebook.com/docs/accountkit/android/configuration)):
```xml
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.GET_ACCOUNTS" />
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## API

### Login with an email address

```javascript
AccountKitPlugin.loginWithEmail(Object options, Function success, Function failure)
```

Available options:

	{
		useAccessToken: true,
		defaultCountryCode: "US",
		facebookNotificationsEnabled: true,
		initialEmail: "joe@doe.com"
	}

Available country codes can be found [here](https://developers.facebook.com/docs/accountkit/countrycodes).

Success function returns an Object like:

	{
		accountId: "<string>",
		applicationId: "<string>",
		token: "<long string>",
		lastRefresh: 1451606400,
		refreshInterval: 2592000
	}

If you do not use access tokens an Object looks like:

	{
		code: "<long string>",
		state: "<string>"
	}

Failure function returns an error String.

### Login with a phone number

```javascript
AccountKitPlugin.loginWithPhoneNumber(Object options, Function success, Function failure)
```

Available options:

	{
		useAccessToken: true,
		defaultCountryCode: "US",
		facebookNotificationsEnabled: true,
		initialPhoneNumber: ["420", "123456789"]
	}

Available dialing codes and country codes can be found [here](https://developers.facebook.com/docs/accountkit/countrycodes).

Success function returns an Object like:

	{
		accountId: "<string>",
		applicationId: "<string>",
		token: "<long string>",
		lastRefresh: 1451606400,
		refreshInterval: 2592000
	}

If you do not use access tokens an Object looks like:

	{
		code: "<long string>",
		state: "<string>"
	}

Failure function returns an error String.

### Logout

```javascript
AccountKitPlugin.logout()
```

### Get account

This method only works when login method was called with `{ useAccessToken: true }`.

```javascript
AccountKitPlugin.getAccount(Function success, Function failure)
```

Success function returns an Object like:

	{
		accountId: "<string>",
		applicationId: "<string>",
		token: "<long string>",
		lastRefresh: 1451606400,
		refreshInterval: 2592000,
		email: "<string>",
		phoneNumber: "<string>"
	}
