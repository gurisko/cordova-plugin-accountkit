#import <Cordova/CDVPlugin.h>
#import <AccountKit/AccountKit.h>

@interface AccountKitPlugin : CDVPlugin {
  AKFAccountKit *_accountKit;
}

- (void)loginWithPhone:(CDVInvokedUrlCommand *)command;
- (void)loginWithEmail:(CDVInvokedUrlCommand *)command;
- (void)logout:(CDVInvokedUrlCommand *)command;

@end
