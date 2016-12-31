#import <Cordova/CDVPlugin.h>
#import <AccountKit/AccountKit.h>


@interface AKPlugin : CDVPlugin

@property (nonatomic, strong) AKFAccountKit *accountKit;

- (void)loginWithPhoneNumber:(CDVInvokedUrlCommand *)command;
- (void)loginWithEmail:(CDVInvokedUrlCommand *)command;
- (void)getAccount:(CDVInvokedUrlCommand *)command;
- (void)logout:(CDVInvokedUrlCommand *)command;

@end
