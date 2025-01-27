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
    UIBarButtonItem *skipButtonItem;
}
@end

API_AVAILABLE(ios(18.0), macos(15.0)) API_UNAVAILABLE(macCatalyst)
@implementation HansTranslationObject
@synthesize sourceLanguageIdentifier,targetLanguageIdentifier;
@synthesize title, headerText, buttonText, translatingText, footerText;

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

+(NSArray <NSString *>*)existLanguageIdentfiers{
    NSArray <NSString *> *array = NSLocale.preferredLanguages;  //系统已经安装的语言
    return array;
}

+(NSArray <NSString *>*)existLanguageNames{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSString *identifier in [HansTranslationObject existLanguageIdentfiers]){
        [results addObject:[HansTranslationObject nameWithLocalIdentifier:identifier]];
    }
    return results;
}

+(NSArray <NSString *>*)availableLanguageIdentifiers{
    NSArray <NSString *> *array = [NSLocale availableLocaleIdentifiers];
    return array;
}

+(NSArray <NSString *>*)availableLanguageNames{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSString *identifier in [HansTranslationObject availableLanguageIdentifiers]){
        [results addObject:[HansTranslationObject nameWithLocalIdentifier:identifier]];
    }
    return results;
}

+(NSString *)nameWithLocalIdentifier:(NSString *)identifier{
    if (nil == identifier){
        return nil;
    }
    return [NSLocale.currentLocale localizedStringForLanguageCode:identifier];
}

-(void)cancelTranslate{
#if TARGET_OS_IOS
    [swiftViewController dismissViewControllerAnimated:YES completion:^{
        if (self->completedHandler){
            self->completedHandler(self, nil, nil);
            self->completedHandler = nil;
        }
    }];
#else
    [rootWindow endSheet:swiftViewController.view.window];
    if (self->completedHandler){
        self->completedHandler(self, nil, nil);
        self->completedHandler = nil;
    }
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
    
    NSString *progressNotificationName = @"SRTTranslatingProgress";
    NSString *completedNotificationName = @"SRTTranslateCompleted";
    bridging = [BridgingClass alloc];
    bridging.headerText = headerText;
    bridging.buttonText = buttonText;
    bridging.translatingText = translatingText;
    bridging.footerText = footerText;
    
    bridging.sourceArray = sourceArray;
    bridging.progressNotificationName = progressNotificationName;
    bridging.completedNotificationName = completedNotificationName;
    bridging.sourceLanguageIdentifier = sourceLanguageIdentifier;
    bridging.targetLanguageIdentifier = targetLanguageIdentifier;
    
    swiftViewController = [bridging makeTranslateViewController];
    
    
#if TARGET_OS_IOS
    swiftViewController.title = title;
    skipButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTranslate)];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:swiftViewController];
    swiftViewController.navigationItem.leftBarButtonItem = skipButtonItem;
    [rootVC presentViewController:nav animated:YES completion:^{
        
    }];
#else
    rootWindow = rootVC.view.window;
    swiftViewController.preferredContentSize = CGSizeMake(400.f, 230.f);
    NSWindow *win = [NSWindow windowWithContentViewController:swiftViewController];
    [rootWindow beginSheet:win completionHandler:^(NSModalResponse returnCode) {
        
    }];
#endif
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(translateProgressNotification:)
                                               name:progressNotificationName
                                             object:nil];
    
    
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
            self->completedHandler(self, res, error.localizedDescription);
            self->completedHandler = nil;
        }
    }];
#else
    [rootWindow endSheet:swiftViewController.view.window];
    if (self->completedHandler){
        self->completedHandler(self, res, error.localizedDescription);
        self->completedHandler = nil;
    }
#endif
    return;
}

-(void)translateProgressNotification:(NSNotification *)notification{
    skipButtonItem.enabled = NO;
    return;
}

@end
