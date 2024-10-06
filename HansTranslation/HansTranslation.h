//
//  HansTranslation.h
//  HansTranslation
//
//  Created by MingJie Han on 2024/9/22.
//

//
//#if TARGET_OS_IOS
//#import <UIKit/UIKit.h>
//#elif TARGET_OS_MAC
//#import <Cocoa/Cocoa.h>
//#endif
#import <Foundation/Foundation.h>
#import <HansTranslation/HansTranslation.h>

//! Project version number for HansTranslation.
FOUNDATION_EXPORT double HansTranslationVersionNumber;

//! Project version string for HansTranslation.
FOUNDATION_EXPORT const unsigned char HansTranslationVersionString[];


//https://developer.apple.com/documentation/Translation/translating-text-within-your-app

@class HansTranslation;
typedef void (^SRTTranslation_Handler) (HansTranslation * _Nullable translater,
                                        NSArray <NSString *>* _Nullable resultsArray,
                                        NSError * _Nullable error);
@class UIViewController,NSViewController;
NS_ASSUME_NONNULL_BEGIN
API_AVAILABLE(macos(15.0)) API_AVAILABLE(ios(18.0)) API_UNAVAILABLE(macCatalyst)
@interface HansTranslation : NSObject
-(id)init NS_UNAVAILABLE;
@property (nonatomic, readonly) NSString *sourceLanguageIdentifier;
@property (nonatomic, readonly) NSString *targetLanguageIdentifier;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *headerText;
@property (nonatomic) NSString *buttonText;
@property (nonatomic) NSString *footerText;

-(id)initWithSourceLanguage:(NSString *)source withTargetLanguage:(NSString *)target;

-(BOOL)translate:(nonnull NSArray <NSString *>*)sourceArray
#if TARGET_OS_IOS
      withRootVC:(nonnull UIViewController *)rootVC
#else
      withRootVC:(nonnull NSViewController *)rootVC
#endif
     withHandler:(nonnull SRTTranslation_Handler)handler;

//Exist languages in this device, without download anything in translate action.
+(NSArray *)existLanguageIdentfiers;

//Can selected language target, and may need download in translation view.
+(NSArray *)availableLanguageIdentifiers;

//return name for identifier with current system language.
+(NSString *)nameWithLocalIdentifier:(NSString *)identifier;
@end
NS_ASSUME_NONNULL_END
