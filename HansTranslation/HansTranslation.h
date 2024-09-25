//
//  HansTranslation.h
//  HansTranslation
//
//  Created by jia yu on 2024/9/22.
//

#import <UIKit/UIKit.h>

//! Project version number for HansTranslation.
FOUNDATION_EXPORT double HansTranslationVersionNumber;

//! Project version string for HansTranslation.
FOUNDATION_EXPORT const unsigned char HansTranslationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HansTranslation/PublicHeader.h>
#import <HansTranslation/HansTranslation.h>

#ifndef HansTranslation_KEYS
#define HansTranslation_KEYS
//TODO I want to move those into HansTranslationPrivate is NOT public header.
//But I can NOT, Swift can NOT found those.
#define completedNotificationName @"SRTTranslateCompleted"
#define sourceFileName @"/Documents/source.plist"
#define resultFileName @"/Documents/results.plist"
#define sourceLanguageFileName @"/Documents/sourceLanguage.txt"
#define targetLanguageFileName @"/Documents/targetLanguage.txt"
#endif

@class HansTranslation;
typedef void (^SRTTranslation_Handler) (HansTranslation * _Nullable translater,
                                        NSArray <NSString *>* _Nullable resultsArray,
                                        NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN API_AVAILABLE(ios(18.0)) API_UNAVAILABLE(macCatalyst)
@interface HansTranslation : NSObject
-(id)init NS_UNAVAILABLE;
@property (nonatomic, readonly) NSString *sourceLanguage;
@property (nonatomic, readonly) NSString *targetLanguage;

-(id)initWithSourceLanguage:(NSString *)source withTargetLanguage:(NSString *)target;

-(BOOL)translate:(NSArray <NSString *>*)sourceArray
      withRootVC:(UIViewController *)rootVC
     withHandler:(SRTTranslation_Handler)handler;

//Exist languages in this device, without download anything in translate action.
+(NSArray *)existLanguageIdentfiers;

//Can selected language target, and may need download in translation view.
+(NSArray *)availableLanguageIdentifiers;

//return name for identifier with current system language.
+(NSString *)nameWithLocalIdentifier:(NSString *)identifier;
@end
NS_ASSUME_NONNULL_END
