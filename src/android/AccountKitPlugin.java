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

import com.facebook.accountkit.AccountKit;
import com.facebook.accountkit.AccessToken;
import com.facebook.accountkit.AccountKitLoginResult;
import com.facebook.accountkit.ui.AccountKitActivity;
import com.facebook.accountkit.ui.AccountKitConfiguration;
import com.facebook.accountkit.ui.LoginType;


public class AccountKitPlugin extends CordovaPlugin {
  private static final String TAG = "AccountKitPlugin";
  public static int APP_REQUEST_CODE = 42;
  private CallbackContext loginContext = null;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);

    AccountKit.initialize(cordova.getActivity().getApplicationContext());
  }

  @Override
  public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    if ("loginWithPhoneNumber".equals(action)) {
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          executeLogin(LoginType.PHONE, callbackContext);
        }
      });
      return true;

    } else if ("loginWithEmail".equals(action)) {
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          executeLogin(LoginType.EMAIL, callbackContext);
        }
      });
      return true;

    } else if ("getAccessToken".equals(action)) {
      if (hasAccessToken()) {
        callbackContext.success(formatAccessToken(AccountKit.getCurrentAccessToken()));
      } else {
        callbackContext.error("Session not open.");
      }
      return true;

    } else if ("logout".equals(action)) {
      AccountKit.logOut();
      callbackContext.success();
      return true;

    }
    return false;
  }

  public final void executeLogin(LoginType type, CallbackContext callbackContext) {
    // Set a pending callback to cordova
    loginContext = callbackContext;
    PluginResult pr = new PluginResult(PluginResult.Status.NO_RESULT);
    pr.setKeepCallback(true);
    loginContext.sendPluginResult(pr);

    try {
      if (hasAccessToken()) {
        callbackContext.success(formatAccessToken(AccountKit.getCurrentAccessToken()));
        return;
      }
    } catch (JSONException e) {
      e.printStackTrace();
    }

    Intent intent = new Intent(this.cordova.getActivity(), AccountKitActivity.class);
    AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder =
      new AccountKitConfiguration.AccountKitConfigurationBuilder(
        type,
        AccountKitActivity.ResponseType.TOKEN);
    intent.putExtra(AccountKitActivity.ACCOUNT_KIT_ACTIVITY_CONFIGURATION, configurationBuilder.build());

    cordova.setActivityResultCallback(this);
    cordova.startActivityForResult(this, intent, APP_REQUEST_CODE);
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (requestCode != APP_REQUEST_CODE) {
      return;
    }

    AccountKitLoginResult loginResult = data.getParcelableExtra(AccountKitLoginResult.RESULT_KEY);
    if (loginResult.getError() != null) {
      loginContext.error(loginResult.getError().getErrorType().getMessage());

    } else if (loginResult.wasCancelled()) {
      loginContext.error("User cancelled dialog");

    } else {
      JSONObject result = null;

      try {
        final AccessToken accessToken = loginResult.getAccessToken();
        if (accessToken != null) {
          result = formatAccessToken(accessToken);
        } else {
          result = new JSONObject();
          result.put("code", loginResult.getAuthorizationCode());
          result.put("state", loginResult.getFinalAuthorizationState());
        }
        loginContext.success(result);
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
    loginContext = null;
  }

  private boolean hasAccessToken() {
    return AccountKit.getCurrentAccessToken() != null;
  }

  public JSONObject formatAccessToken(AccessToken accessToken) throws JSONException {
    JSONObject result = new JSONObject();
    result.put("accountId", accessToken.getAccountId());
    result.put("applicationId", accessToken.getApplicationId());
    result.put("token", accessToken.getToken());
    result.put("lastRefresh", accessToken.getLastRefresh().getTime() * 1000);
    result.put("refreshInterval", accessToken.getTokenRefreshIntervalSeconds());
    return result;
  }
}
