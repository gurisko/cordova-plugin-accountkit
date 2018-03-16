#import "AKPlugin.h"
#import "AKPluginViewController.h"


@implementation AKPlugin {
  AKFResponseType _responseType;
  AKFAccountKit *_accountKit;
  AKFTheme *_theme;
}

- (void)pluginInitialize {
  _theme = [AKFTheme defaultTheme];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(processResponse:)
                                               name:@"AccountKitDone"
                                             object:nil];
}

#pragma mark - Public API

- (void)loginWithPhoneNumber:(CDVInvokedUrlCommand *)command {
  NSDictionary *options = [command.arguments objectAtIndex:0];
  AKFPhoneNumber *preFillPhoneNumber = nil;

  BOOL useAccessToken = [[options objectForKey:@"useAccessToken"] boolValue];
  NSString *defaultCountryCode = [options objectForKey:@"defaultCountryCode"];
  BOOL facebookNotificationsEnabled = [[options objectForKey:@"facebookNotificationsEnabled"] boolValue];
  NSArray *initialPhoneNumber = [options objectForKey:@"initialPhoneNumber"];
  if ([initialPhoneNumber count] == 2) {
    preFillPhoneNumber = [[AKFPhoneNumber alloc]initWithCountryCode:[initialPhoneNumber objectAtIndex:0]
                                                        phoneNumber:[initialPhoneNumber objectAtIndex:1]];
  }

  _responseType = useAccessToken ? AKFResponseTypeAccessToken: AKFResponseTypeAuthorizationCode;
  _accountKit = [[AKFAccountKit alloc] initWithResponseType:_responseType];

  AKPluginViewController *vc = [self _prepareViewController];
  [vc loginWithPhoneNumber:preFillPhoneNumber
        defaultCountryCode:defaultCountryCode
      enableSendToFacebook:facebookNotificationsEnabled
                  callback:command.callbackId];
}

- (void)loginWithEmail:(CDVInvokedUrlCommand *)command {
  NSDictionary *options = [command.arguments objectAtIndex:0];

  BOOL useAccessToken = [[options objectForKey:@"useAccessToken"] boolValue];
  NSString *defaultCountryCode = [options objectForKey:@"defaultCountryCode"];
  BOOL facebookNotificationsEnabled = [[options objectForKey:@"facebookNotificationsEnabled"] boolValue];
  NSString *initialEmail = [options objectForKey:@"initialEmail"];

  _responseType = useAccessToken ? AKFResponseTypeAccessToken: AKFResponseTypeAuthorizationCode;
  _accountKit = [[AKFAccountKit alloc] initWithResponseType:_responseType];

  AKPluginViewController *vc = [self _prepareViewController];
  [vc loginWithEmailAddress:initialEmail
         defaultCountryCode:defaultCountryCode
       enableSendToFacebook:facebookNotificationsEnabled
                   callback:command.callbackId];
}

- (void)getAccount:(CDVInvokedUrlCommand *)command {
  if (_accountKit == nil) {
      _accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
  }
  id<AKFAccessToken> accessToken = [_accountKit currentAccessToken];

  if (accessToken == nil) {
      CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                  messageAsString:@"No Access token present"];
      [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      _accountKit = nil;
      return;
  }
  
  [_accountKit requestAccount:^(id<AKFAccount> account, NSError *error) {
    CDVPluginResult *result = nil;
    if (error) {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                 messageAsString:error.localizedDescription];
      [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      return;
    }

    NSMutableDictionary *message = [self formatAccessToken:accessToken];

    if ([[account emailAddress] length] > 0) {
      [message setValue:account.emailAddress forKey:@"email"];
    }

    if ([account phoneNumber] != nil) {
      [message setValue:[[account phoneNumber] stringRepresentation] forKey:@"phoneNumber"];
    }

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }];
}

- (void)logout:(CDVInvokedUrlCommand *)command {
  [_accountKit logOut];

  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - Private methods

- (AKPluginViewController *)_prepareViewController {
  AKPluginViewController *vc = [[AKPluginViewController alloc] init:_accountKit];
  vc.theme = _theme;
  return vc;
}

- (void)processResponse:(NSNotification *)notification {
  CDVPluginResult *result;
  NSDictionary *response = [notification userInfo];
  NSString *name = [response objectForKey:@"name"];

  NSLog(@"%@", name);

  if ([name isEqualToString:@"didCompleteLoginWithAuthorizationCode"]) {

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsDictionary:[response objectForKey:@"data"]];

  } else if ([name isEqualToString:@"didCompleteLoginWithAccessToken"]) {

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsDictionary:[self formatAccessToken:[response objectForKey:@"data"]]];

  } else if ([name isEqualToString:@"didFailWithError"]) {

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:[response objectForKey:@"data"]];

  }

  [self.commandDelegate sendPluginResult:result
                              callbackId:[response objectForKey:@"callbackId"]];
}

- (NSMutableDictionary*)formatAccessToken:(id<AKFAccessToken>)accessToken {
  if (accessToken == nil) {
    return nil;
  }
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  result[@"accountId"] = accessToken.accountID;
  result[@"applicationId"] = accessToken.applicationID;
  result[@"token"] = accessToken.tokenString;
  result[@"lastRefresh"] = @([accessToken lastRefresh].timeIntervalSince1970 * 1000);
  result[@"refreshInterval"] = @(accessToken.tokenRefreshInterval);
  return result;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"AccountKitDone"
                                                object:nil];
}

@end
