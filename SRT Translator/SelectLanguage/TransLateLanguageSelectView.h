//
//  TransLateLanguageSelectViewController.h
//  SRT Translater
//
//  Created by jia yu on 2024/11/15.
//

#import <UIKit/UIKit.h>

typedef void (^TransLateLanguageSelectView_CompletedHandler) (NSString * _Nullable selectedIdentifier);

NS_ASSUME_NONNULL_BEGIN
@interface TransLateLanguageSelectView:UIView
@property (nonatomic) TransLateLanguageSelectView_CompletedHandler handler;
@property (nonatomic) NSString * _Nullable currentLanguageIdentifier;
@property (nonatomic) NSString * _Nullable stringForDominant;

-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame;

-(void)showFrom:(UIViewController *)vc fromRect:(CGRect)fromRect;
@end
NS_ASSUME_NONNULL_END
