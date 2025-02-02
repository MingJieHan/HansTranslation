//
//  TransLateLanguageCell.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/15.
//

#import "TransLateLanguageCell.h"
#import <HansTranslation/HansTranslation.h>

@interface TransLateLanguageCell(){
    
}
@end

@implementation TransLateLanguageCell
@synthesize languageIdentifier;
@synthesize isCurrent;
@synthesize available;

-(void)setAvailable:(BOOL)_available{
    available = _available;
    if (available){
        self.textLabel.textColor = [UIColor blackColor];
    }else{
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
    return;
}

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self){
        
    }
    return self;
}

-(void)setLanguageIdentifier:(NSString *)_languageIdentifier{
    languageIdentifier = _languageIdentifier;
    self.textLabel.text = [HansTranslationObject stringForLanguageCode:languageIdentifier];
}

-(void)setIsCurrent:(BOOL)_isCurrent{
    isCurrent = _isCurrent;
    if (isCurrent){
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return;
}
@end
