#import "AKPluginViewController.h"

#import <Cordova/CDVPlugin.h>


@implementation AKPluginViewController {
  AKPluginViewController *_instance;
  AKFAccountKit *_accountKit;
}

#pragma mark - View Management

- (instancetype)init:(AKFAccountKit *)accountKit {
  self = [super init];
  _accountKit = accountKit;
  _instance = self;

  return self;
}

- (void)loginWithPhoneNumber:(AKFPhoneNumber *)preFillPhoneNumber
          defaultCountryCode:(NSString *)defaultCountryCode
        enableSendToFacebook:(BOOL)facebookNotificationsEnabled
                    callback:(NSString *)callbackId {
  NSString *inputState = [[NSUUID UUID] UUIDString];
  self.callbackId = callbackId;

  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController<AKFViewController> *vc = [_accountKit viewControllerForPhoneLoginWithPhoneNumber:preFillPhoneNumber
                                                                                                state:inputState];
    vc.enableSendToFacebook = facebookNotificationsEnabled;
    vc.defaultCountryCode = defaultCountryCode;
    [self _prepareLoginViewController:vc];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController presentViewController:vc animated:YES completion:nil];
  });
}

- (void)loginWithEmailAddress:(NSString *)preFillEmailAddress
           defaultCountryCode:(NSString *)defaultCountryCode
         enableSendToFacebook:(BOOL)facebookNotificationsEnabled
                     callback:(NSString *)callbackId {
  NSString *inputState = [[NSUUID UUID] UUIDString];
  self.callbackId = callbackId;

  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController<AKFViewController> *vc = [_accountKit viewControllerForEmailLoginWithEmail:preFillEmailAddress
                                                                                          state:inputState];
    vc.enableSendToFacebook = facebookNotificationsEnabled;
    vc.defaultCountryCode = defaultCountryCode;
    [self _prepareLoginViewController:vc];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController presentViewController:vc animated:YES completion:nil];
  });
}

- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)viewController {
  viewController.delegate = self;
}

# pragma mark - AKFViewControllerDelegate

/*!
 @abstract Called when the login completes with an authorization code response type.
 
 @param viewController the AKFViewController that was used
 @param code the authorization code that can be exchanged for an access token with the app secret
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAuthorizationCode:(NSString *)code state:(NSString *)state {
  NSDictionary* response = @{
                             @"callbackId": self.callbackId,
                             @"data": @{
                                 @"code": code,
                                 @"state": state
                                 },
                             @"name": @"didCompleteLoginWithAuthorizationCode"
                             };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountKitDone"
                                                      object:nil
                                                    userInfo:response];
}

/*!
 @abstract Called when the login completes with an access token response type.
 
 @param viewController the AKFViewController that was used
 @param accessToken the access token for the logged in account
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state {
  NSDictionary* response = @{
                             @"callbackId": self.callbackId,
                             @"data": accessToken,
                             @"name": @"didCompleteLoginWithAccessToken"
                             };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountKitDone"
                                                      object:nil
                                                    userInfo:response];
}

/*!
 @abstract Called when the login failes with an error
 
 @param viewController the AKFViewController that was used
 @param error the error that occurred
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController
      didFailWithError:(NSError *)error {
  NSDictionary* response = @{
                             @"callbackId": self.callbackId,
                             @"data": [error localizedDescription],
                             @"name": @"didFailWithError"
                             };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountKitDone"
                                                      object:nil
                                                    userInfo:response];
}

/*!
 @abstract Called when the login flow is cancelled through the UI.
 
 @param viewController the AKFViewController that was used
 */
- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController {
  NSDictionary* response = @{
                             @"callbackId": self.callbackId,
                             @"data": @"User cancelled",
                             @"name": @"didFailWithError"
                             };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountKitDone"
                                                      object:nil
                                                    userInfo:response];
}

@end
