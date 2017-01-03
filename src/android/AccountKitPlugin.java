package org.apache.cordova.facebook;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import com.facebook.accountkit.Account;
import com.facebook.accountkit.AccountKit;
import com.facebook.accountkit.AccountKitCallback;
import com.facebook.accountkit.AccountKitError;
import com.facebook.accountkit.AccessToken;
import com.facebook.accountkit.AccountKitLoginResult;
import com.facebook.accountkit.PhoneNumber;
import com.facebook.accountkit.ui.AccountKitActivity;
import com.facebook.accountkit.ui.AccountKitConfiguration;
import com.facebook.accountkit.ui.LoginType;


public class AccountKitPlugin extends CordovaPlugin {
  public static final String TAG = "AccountKitPlugin";
  private static final int APP_REQUEST_CODE = 65537;

  public static final String LOGIN_WITH_PHONE_NUMBER = "loginWithPhoneNumber";
  public static final String LOGIN_WITH_EMAIL = "loginWithEmail";
  public static final String GET_ACCOUNT = "getAccount";
  public static final String LOGOUT = "logout";

  private static CallbackContext callback;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);

    AccountKit.initialize(cordova.getActivity().getApplicationContext());
  }

  @Override
  public boolean execute(String action, final JSONArray data, final CallbackContext callbackContext) throws JSONException {
    callback = callbackContext;
    if (LOGIN_WITH_PHONE_NUMBER.equals(action)) {
      final JSONObject options = (data.length() > 0) ? data.getJSONObject(0) : new JSONObject();
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          try {
            executeLogin(LoginType.PHONE, options);
          } catch (Throwable t) {
            Log.e(TAG, Log.getStackTraceString(t));
          }
        }
      });
      return true;

    } else if (LOGIN_WITH_EMAIL.equals(action)) {
      final JSONObject options = (data.length() > 0) ? data.getJSONObject(0) : new JSONObject();
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          try {
            executeLogin(LoginType.EMAIL, options);
          } catch (Throwable t) {
            Log.e(TAG, Log.getStackTraceString(t));
          }
        }
      });
      return true;

    } else if (GET_ACCOUNT.equals(action)) {
      if (hasAccessToken()) {
        executeGetAccount();
      } else {
        callback.error("Access token not found");
      }
      return true;

    } else if (LOGOUT.equals(action)) {
      AccountKit.logOut();
      callback.success();
      return true;

    } else {
      Log.e(TAG, "Invalid action: " + action);
    }
    return false;
  }

  public final void executeLogin(LoginType type, JSONObject options) throws JSONException {
    // Set a pending callback to cordova
    PluginResult pr = new PluginResult(PluginResult.Status.NO_RESULT);
    pr.setKeepCallback(true);
    callback.sendPluginResult(pr);

    try {
      if (hasAccessToken()) {
        callback.success(formatAccessToken(AccountKit.getCurrentAccessToken()));
        return;
      }
    } catch (JSONException e) {
      callback.error(Log.getStackTraceString(e));
      return;
    }

    boolean useAccessToken = options.optBoolean("useAccessToken", false);

    Intent intent = new Intent(this.cordova.getActivity(), AccountKitActivity.class);
    AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder =
      new AccountKitConfiguration.AccountKitConfigurationBuilder(
        type,
        useAccessToken ? AccountKitActivity.ResponseType.TOKEN : AccountKitActivity.ResponseType.CODE);

    configurationBuilder.setDefaultCountryCode(options.optString("defaultCountryCode", null));
    configurationBuilder.setFacebookNotificationsEnabled(options.optBoolean("facebookNotificationsEnabled", false));

    if (type == LoginType.PHONE) {
      JSONArray phoneNumber = options.optJSONArray("initialPhoneNumber");
      if (phoneNumber != null && phoneNumber.length() == 2) {
        configurationBuilder.setInitialPhoneNumber(new PhoneNumber(phoneNumber.getString(0), phoneNumber.getString(1)));
      }
    } else if (type == LoginType.EMAIL) {
      configurationBuilder.setInitialEmail(options.optString("initialEmail", null));
    }

    intent.putExtra(AccountKitActivity.ACCOUNT_KIT_ACTIVITY_CONFIGURATION, configurationBuilder.build());

    cordova.setActivityResultCallback(this);
    cordova.startActivityForResult(this, intent, APP_REQUEST_CODE);
  }

  public void onActivityResult(int requestCode, int resultCode, final Intent intent) {
    super.onActivityResult(requestCode, resultCode, intent);

    // Sometimes intent is null what crashes the app. This is a workaround rather than a solution.
    if (requestCode != APP_REQUEST_CODE || intent == null) {
      return;
    }

    AccountKitLoginResult loginResult = intent.getParcelableExtra(AccountKitLoginResult.RESULT_KEY);
    if (loginResult.getError() != null) {
      callback.error(loginResult.getError().getErrorType().getMessage());

    } else if (loginResult.wasCancelled()) {
      callback.error("User cancelled");

    } else {
      JSONObject result = null;

      try {
        final AccessToken accessToken = loginResult.getAccessToken();
        final String authorizationCode = loginResult.getAuthorizationCode();

        if (accessToken != null) {
          result = formatAccessToken(accessToken);
        } else if (authorizationCode != null) {
          result = new JSONObject();
          result.put("code", authorizationCode);
          result.put("state", loginResult.getFinalAuthorizationState());
        } else {
          callback.error("Unknown response type");
          return;
        }
        callback.success(result);
      } catch (JSONException e) {
        callback.error(Log.getStackTraceString(e));
      }
    }
  }

  private boolean hasAccessToken() {
    return AccountKit.getCurrentAccessToken() != null;
  }

  public void executeGetAccount() {
    AccountKit.getCurrentAccount(new AccountKitCallback<Account>() {
      @Override
      public void onSuccess(final Account account) {
        AccessToken accessToken = AccountKit.getCurrentAccessToken();

        String email = account.getEmail();
        PhoneNumber phoneNumber = account.getPhoneNumber();

        try {
          JSONObject result = formatAccessToken(accessToken);

          if (email != null) {
            result.put("email", email);
          }
          if (phoneNumber != null) {
            result.put("phoneNumber", phoneNumber.toString());
          }

          callback.success(result);

        } catch (JSONException e) {
          callback.error(Log.getStackTraceString(e));
        }
      }

      @Override
      public void onError(final AccountKitError error) {
        callback.error(error.getErrorType().getMessage());
      }
    });
  }

  private JSONObject formatAccessToken(AccessToken accessToken) throws JSONException {
    JSONObject result = new JSONObject();
    result.put("accountId", accessToken.getAccountId());
    result.put("applicationId", accessToken.getApplicationId());
    result.put("token", accessToken.getToken());
    result.put("lastRefresh", accessToken.getLastRefresh().getTime());
    result.put("refreshInterval", accessToken.getTokenRefreshIntervalSeconds());
    return result;
  }
}
