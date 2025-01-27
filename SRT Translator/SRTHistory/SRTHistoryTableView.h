//
//  SRTHistoryTableView.h
//  SRT Translater
//
//  Created by jia yu on 2024/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SRTHistoryTableView : UITableView
-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
-(void)insertNewFile:(NSString *)newFile;
@end
NS_ASSUME_NONNULL_END
