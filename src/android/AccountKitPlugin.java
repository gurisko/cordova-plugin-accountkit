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
import com.facebook.accountkit.ui.AccountKitActivity;
import com.facebook.accountkit.ui.AccountKitConfiguration;
import com.facebook.accountkit.ui.LoginType;


public class AccountKitPlugin extends CordovaPlugin {
  private static final String TAG = "AccountKitPlugin";


  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);

    AccountKit.initialize(cordova.getActivity().getApplicationContext());
  }

  @Override
  public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    if ("loginWithPhone".equals(action)) {
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          login(args, LoginType.PHONE);
          callbackContext.success();
        }
      });
    } else if ("loginWithEmail".equals(action)) {
      cordova.getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          login(args, LoginType.EMAIL);
          callbackContext.success();
        }
      });
    } else if ("logout".equals(action)) {
      AccountKit.logOut();
    } else {
      callbackContext.error("Unknown Action: " + action);
      return false;
    }
    return true;
  }

  public final void login(JSONArray args, LoginType type) {
    Log.d(TAG, "Login");
    JSONObject parameters;

    try {
      parameters = args.getJSONObject(0);
    } catch (JSONException e) {
      parameters = new JSONObject();
    }

    // TODO: Add configuration

    Context context = this.cordova.getActivity();
    Intent intent = new Intent(context, AccountKitActivity.class);
    AccountKitConfiguration.AccountKitConfigurationBuilder configurationBuilder =
      new AccountKitConfiguration.AccountKitConfigurationBuilder(
        type,
        AccountKitActivity.ResponseType.CODE);
    intent.putExtra(
      AccountKitActivity.ACCOUNT_KIT_ACTIVITY_CONFIGURATION,
      configurationBuilder.build());
    context.startActivity(intent);
  }

}
