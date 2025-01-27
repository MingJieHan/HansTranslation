//
//  TransLateLanguageCell.h
//  SRT Translater
//
//  Created by jia yu on 2024/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface TransLateLanguageCell : UITableViewCell
@property (nonatomic) NSString *languageIdentifier;
@property (nonatomic) BOOL isCurrent;

-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame reuseIdentifier:(nullable NSString *)reuseIdentifier NS_UNAVAILABLE;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier NS_UNAVAILABLE;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end
NS_ASSUME_NONNULL_END
