//
//  SRTHistoryTableViewCell.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/18.
//

#import "SRTHistoryTableViewCell.h"
#import <HansServer/HansServer.h>

@interface SRTHistoryTableViewCell(){
    
}
@end


@implementation SRTHistoryTableViewCell
@synthesize file;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.textLabel.textColor = [UIHans colorFromHEXString:@"2A9FB8"];
        self.textLabel.userInteractionEnabled = NO;
        self.detailTextLabel.userInteractionEnabled = NO;
    }
    return self;
}

-(void)setFile:(NSString *)_file{
    file = _file;
    self.textLabel.text = [file lastPathComponent];
    return;
}

@end
