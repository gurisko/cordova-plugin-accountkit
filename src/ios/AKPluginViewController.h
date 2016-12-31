#import <Cordova/CDVPlugin.h>
#import <AccountKit/AccountKit.h>


@interface AKPluginViewController : UIViewController<AKFViewControllerDelegate>

@property(nonatomic, strong) AKFTheme *theme;
@property(nonatomic, strong) NSString *callbackId;

- (instancetype)init:(AKFAccountKit *)accountKit;
- (void)loginWithPhoneNumber:(AKFPhoneNumber *)preFillPhoneNumber
          defaultCountryCode:(NSString *)defaultCountryCode
        enableSendToFacebook:(BOOL)facebookNotificationsEnabled
                    callback:(NSString *)callbackId;
- (void)loginWithEmailAddress:(NSString *)preFillEmailAddress
           defaultCountryCode:(NSString *)defaultCountryCode
         enableSendToFacebook:(BOOL)facebookNotificationsEnabled
                     callback:(NSString *)callbackId;

@end
