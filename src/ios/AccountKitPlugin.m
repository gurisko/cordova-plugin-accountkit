#import "AccountKitPlugin.h"

#import <Cordova/CDVAvailability.h>
#import <AccountKit/AccountKit.h>

@implementation AccountKitPlugin

- (void)pluginInitialize {
  if (_accountKit == nil) {
    _accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
  }
}

- (void)loginWithPhone:(CDVInvokedUrlCommand *)command {
  UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForPhoneLoginWithPhoneNumber:nil state:nil];
  [viewController setEnableSendToFacebook:YES];
  [self.viewController presentViewController:viewController animated:YES completion:^{}];
}

- (void)loginWithEmail:(CDVInvokedUrlCommand *)command {
  UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForEmailLoginWithEmail:nil state:nil];
  [viewController setEnableSendToFacebook:YES];
  [self.viewController presentViewController:viewController animated:YES completion:^{}];
}

- (void)logout:(CDVInvokedUrlCommand *)command {
  NSString* phrase = [command.arguments objectAtIndex:0];
  NSLog(@"%@", phrase);  [_accountKit logOut];
}

@end
