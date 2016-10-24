#import <Cordova/CDVPlugin.h>
#import <AccountKit/AccountKit.h>


@interface AKPluginViewController : UIViewController<AKFViewControllerDelegate>

@property(nonatomic, strong) AKFTheme *theme;
@property(nonatomic, strong) NSString *callbackId;

- (instancetype)init:(AKFAccountKit *)accountKit;
- (void)loginWithPhoneNumber:(NSString *)callbackId;
- (void)loginWithEmail:(NSString *)callbackId;

@end
