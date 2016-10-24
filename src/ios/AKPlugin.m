#import "AKPlugin.h"
#import "AKPluginViewController.h"


@implementation AKPlugin {
  AKFAccountKit *_accountKit;
  AKFTheme *_theme;
}

- (void)pluginInitialize {
  if (_accountKit == nil) {
    _accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    _theme = [AKFTheme defaultTheme];
  }
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(processResponse:)
                                               name:@"AccountKitDone"
                                             object:nil];
}

#pragma mark - Public API

- (void)loginWithPhoneNumber:(CDVInvokedUrlCommand *)command {
  AKPluginViewController *vc = [self _prepareViewController];
  [vc loginWithPhoneNumber:command.callbackId];
}

- (void)loginWithEmail:(CDVInvokedUrlCommand *)command {
  AKPluginViewController *vc = [self _prepareViewController];
  [vc loginWithEmail:command.callbackId];
}

- (void)getAccessToken:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *result = nil;
  id<AKFAccessToken> accessToken = [_accountKit currentAccessToken];

  if ([accessToken accountID]) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsDictionary:[self formatAccessToken:accessToken]];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"Session not open."];
  }

  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)logout:(CDVInvokedUrlCommand *)command {
  [_accountKit logOut];

  CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
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

  if ([response objectForKey:@"success"]) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsDictionary:[self formatAccessToken:[response objectForKey:@"data"]]];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:[response objectForKey:@"error"]];
  }
    
  [self.commandDelegate sendPluginResult:result
                              callbackId:[response objectForKey:@"callbackId"]];
}

- (NSMutableDictionary*)formatAccessToken:(id<AKFAccessToken>)accessToken {
  if( accessToken == nil ) return nil;
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  result[@"accountId"] = accessToken.accountID;
  result[@"applicationId"] = accessToken.applicationID;
  result[@"token"] = accessToken.tokenString;
  result[@"lastRefresh"] = @([accessToken lastRefresh].timeIntervalSince1970 * 1000);
  result[@"refreshInterval"] = @(accessToken.tokenRefreshInterval);
  return result;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
