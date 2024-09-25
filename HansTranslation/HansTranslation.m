//
//  SRTTranslation.m
//  Build SRT
//
//  Created by jia yu on 2024/9/20.
//

#import <HansTranslation-Swift.h>
#import "HansTranslation.h"
#import <Translation/Translation.h>
#import "HansTranslationPrivate.h"

// Google 的翻译API
// https://developers.google.com/ml-kit/language/translation/ios

HansTranslation *staticSRTTranslation;
@interface HansTranslation(){
    SRTTranslation_Handler completedHandler;
    UIViewController *swiftViewController;
    BridgingClass *bridging;
}
@end

@implementation HansTranslation
@synthesize sourceLanguage,targetLanguage;

-(id)init{
    self = [super init];
    if (self){
        bridging = [BridgingClass alloc];
        swiftViewController = [bridging makeMainView];
    }
    return self;
}

-(BOOL)availableForIdentifier:(NSString *)identifier{
    NSArray <NSString *>*availables = [HansTranslation existLanguageIdentfiers];
    for (NSString *str in availables){
        if ([str isEqualToString:identifier]){
            return YES;
        }
    }
    
    availables = [HansTranslation availableLanguageIdentifiers];
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
        && [staticSRTTranslation.sourceLanguage isEqualToString:source]
        && [staticSRTTranslation.targetLanguage isEqualToString:target]){
        //same source and target, return last object.
    }else{
        self = [super init];
        if (self){
            bridging = [BridgingClass alloc];
            swiftViewController = [bridging makeMainView];
            sourceLanguage = source;
            targetLanguage = target;
            
            NSString *file = [NSHomeDirectory() stringByAppendingString:sourceLanguageFileName];
            [sourceLanguage writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            file = [NSHomeDirectory() stringByAppendingString:targetLanguageFileName];
            [targetLanguage writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
    [swiftViewController dismissViewControllerAnimated:YES completion:nil];
    return;
}

-(BOOL)translate:(NSArray <NSString *>*)sourceArray
      withRootVC:(UIViewController *)rootVC
     withHandler:(SRTTranslation_Handler)handler{
    completedHandler = handler;

    NSString *file = [NSHomeDirectory() stringByAppendingString:sourceFileName];
    [sourceArray writeToFile:file atomically:YES];
    
    swiftViewController.title = @"Translate by iOS 18";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:swiftViewController];
    [rootVC presentViewController:nav animated:YES completion:^{
        self->swiftViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTranslate)];
    }];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(translateCompletedNotification:)
                                               name:completedNotificationName
                                             object:nil];
    return YES;
}

#pragma mark - Translate completed notification
-(void)translateCompletedNotification:(NSNotification *)notification{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    id returnObject = notification.object;

    NSString *resultFile = [NSHomeDirectory() stringByAppendingString:resultFileName];
    NSArray *res = [[NSArray alloc] initWithContentsOfFile:resultFile];
    
    [swiftViewController dismissViewControllerAnimated:YES completion:^{
        if (self->completedHandler){
            if ([returnObject isKindOfClass:[NSError class]]){
                NSError *error = (NSError *)returnObject;
                self->completedHandler(self, res, error);
            }else{
                self->completedHandler(self, res, nil);
            }
        }
    }];
    return;
}
@end
