//
//  TransLateLanguageCell.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/15.
//

#import "TransLateLanguageCell.h"
#import <HansTranslation/HansTranslation.h>
#import <HansServer/HansServer.h>

@interface TransLateLanguageCell(){
    
}
@end

@implementation TransLateLanguageCell
@synthesize languageIdentifier;
@synthesize isCurrent;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self){
        
    }
    return self;
}

-(void)setLanguageIdentifier:(NSString *)_languageIdentifier{
    languageIdentifier = _languageIdentifier;
    self.textLabel.text = [HansLocal targetLocalIdentifierDescription:languageIdentifier];
    self.detailTextLabel.text = [HansLocal systemDescriptionLocalIdentifier:languageIdentifier];
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
