//
//  SRTTranslation.m
//
//
//  Created by MingJie Han on 2024/9/20.
//

#import <HansTranslation-Swift.h>
#import "HansTranslationObject.h"

#import <Translation/Translation.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

// Google 的翻译API
// https://developers.google.com/ml-kit/language/translation/ios

HansTranslationObject *staticSRTTranslation;

API_AVAILABLE(ios(18.0), macos(15.0)) API_UNAVAILABLE(macCatalyst)
@interface HansTranslationObject(){
    SRTTranslation_Handler completedHandler;
#if TARGET_OS_IOS
    UIViewController *swiftViewController;
#else
    NSViewController *swiftViewController;
    NSWindow *rootWindow;
#endif
    BridgingClass *bridging;
}
@end

API_AVAILABLE(ios(18.0), macos(15.0)) API_UNAVAILABLE(macCatalyst)
@implementation HansTranslationObject
@synthesize sourceLanguageIdentifier,targetLanguageIdentifier;
@synthesize title, headerText, buttonText, footerText;

-(BOOL)availableForIdentifier:(NSString *)identifier{
    NSArray <NSString *>*availables = [HansTranslationObject existLanguageIdentfiers];
    for (NSString *str in availables){
        if ([str isEqualToString:identifier]){
            return YES;
        }
    }
    
    availables = [HansTranslationObject availableLanguageIdentifiers];
    for (NSString *str in availables){
        if ([str isEqualToString:identifier]){
            return YES;
        }
    }
    return NO;
}

-(id)initWithSourceLanguage:(NSString *)source withTargetLanguage:(NSString *)target{
    if (NO == [self availableForIdentifier:source]){
        NSLog(@"initWithSourceLanguage failed, source identifier %@ is not available.", source);
        return nil;
    }
    if (NO == [self availableForIdentifier:target]){
        NSLog(@"initWithSourceLanguage failed, target identifier %@ is not available.", target);
        return nil;
    }
    if (staticSRTTranslation
        && [staticSRTTranslation.sourceLanguageIdentifier isEqualToString:source]
        && [staticSRTTranslation.targetLanguageIdentifier isEqualToString:target]){
        //same source and target, return last object.
    }else{
        self = [super init];
        if (self){
            title = @"iOS 18 only";
            headerText = @"Press for action.";
            buttonText = @"Translate";
            footerText = @"";
            
            sourceLanguageIdentifier = source;
            targetLanguageIdentifier = target;
        }
        staticSRTTranslation = self;
    }
    return staticSRTTranslation;
}

+(NSArray *)existLanguageIdentfiers{
    NSArray <NSString *> *array = NSLocale.preferredLanguages;  //系统已经安装的语言
    return array;
}

+(NSArray *)availableLanguageIdentifiers{
    NSArray <NSString *> *array = [NSLocale availableLocaleIdentifiers];
    return array;
}

+(NSString *)nameWithLocalIdentifier:(NSString *)identifier{
    if (nil == identifier){
        return nil;
    }
    return [NSLocale.currentLocale localizedStringForLanguageCode:identifier];
}

-(void)cancelTranslate{
#if TARGET_OS_IOS
    [swiftViewController dismissViewControllerAnimated:YES completion:nil];
#else
    [swiftViewController dismissViewController:swiftViewController];
#endif
    return;
}

-(BOOL)translate:(NSArray <NSString *>*)sourceArray
#if TARGET_OS_IOS
      withRootVC:(UIViewController *)rootVC
#else
      withRootVC:(NSViewController *)rootVC
#endif
     withHandler:(SRTTranslation_Handler)handler{
    if (nil == rootVC){
        NSLog(@"HansTranslation rootVC can NOT nil.");
        return NO;
    }
    if (nil == sourceArray || 0 == sourceArray.count){
        NSLog(@"sources is nil.");
        return NO;
    }
    completedHandler = handler;

    NSString *completedNotificationName = @"SRTTranslateCompleted";
    bridging = [BridgingClass alloc];
    bridging.headerText = headerText;
    bridging.buttonText = buttonText;
    bridging.footerText = footerText;

    bridging.sourceArray = sourceArray;
    bridging.completedNotificationName = completedNotificationName;
    bridging.sourceLanguageIdentifier = sourceLanguageIdentifier;
    bridging.targetLanguageIdentifier = targetLanguageIdentifier;
    
    swiftViewController = [bridging makeTranslateViewController];
    
    
#if TARGET_OS_IOS
    swiftViewController.title = title;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:swiftViewController];
    [rootVC presentViewController:nav animated:YES completion:^{
        self->swiftViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTranslate)];
    }];
#else
    rootWindow = rootVC.view.window;
    swiftViewController.preferredContentSize = CGSizeMake(400.f, 230.f);
    NSWindow *win = [NSWindow windowWithContentViewController:swiftViewController];
    [rootWindow beginSheet:win completionHandler:^(NSModalResponse returnCode) {
        
    }];
#endif
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(translateCompletedNotification:)
                                               name:completedNotificationName
                                             object:nil];
    return YES;
}

#pragma mark - Translate completed notification
-(void)translateCompletedNotification:(NSNotification *)notification{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    id returnObject = notification.object;
    
    NSArray *res = nil;
    NSError *error = nil;
    if ([returnObject isKindOfClass:[NSArray class]]){
        res = (NSArray *)returnObject;
    }else if ([returnObject isKindOfClass:[NSError class]]){
        error = (NSError *)returnObject;
    }
#if TARGET_OS_IOS
    [swiftViewController dismissViewControllerAnimated:YES completion:^{
        if (self->completedHandler){
            self->completedHandler(self, res, error);
        }
    }];
#else
    [rootWindow endSheet:swiftViewController.view.window];
    if (self->completedHandler){
        self->completedHandler(self, res, error);
    }
#endif
    return;
}

@end
