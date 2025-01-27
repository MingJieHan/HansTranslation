//
//  TransLateLanguageSelectViewController.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/15.
//

#import "TransLateLanguageSelectView.h"
#import <HansTranslation/HansTranslation.h>
#import "TransLateLanguageCell.h"
@interface TransLateLanguageSelectView ()<UITableViewDelegate, UITableViewDataSource>{
    UIView *cancelGestureRecognizerView;
    UITableView *targetLanguagesTableView;
    CGRect tableViewRect;
    CGRect fromRect;
    NSArray *existLanguages;
    NSArray *availableLanguages;
}
@end

@implementation TransLateLanguageSelectView
@synthesize handler;
@synthesize stringForDominant;
@synthesize currentLanguageIdentifier;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.f;
        self.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.4];
        cancelGestureRecognizerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
        [self addSubview:cancelGestureRecognizerView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCancelAction:)];
        [cancelGestureRecognizerView addGestureRecognizer:tap];

        tableViewRect = CGRectMake(10.f, 100.f,300.f, frame.size.height-150.f);
        if (nil == targetLanguagesTableView){
            targetLanguagesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            targetLanguagesTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            targetLanguagesTableView.delegate = self;
            targetLanguagesTableView.dataSource = self;
            targetLanguagesTableView.layer.masksToBounds = YES;
            targetLanguagesTableView.layer.cornerRadius = 8.f;
            [self addSubview:targetLanguagesTableView];
        }
        
        if (nil == existLanguages){
            existLanguages = [HansTranslationObject existLanguageIdentfiers];
        }
        if (nil == availableLanguages){
            availableLanguages = [HansTranslationObject availableLanguageIdentifiers];
        }
    }
    return self;
}

-(void)tapCancelAction:(UITapGestureRecognizer *)sender{
    [self hidden];
}

-(void)showFrom:(UIViewController *)vc fromRect:(CGRect)_fromRect{
    fromRect = _fromRect;
    [targetLanguagesTableView setFrame:fromRect];
    [targetLanguagesTableView reloadData];
    self.alpha = 0.f;
    [vc.view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.f;
        [self->targetLanguagesTableView setFrame:self->tableViewRect];
    }];
}

-(void)hidden{
    [UIView animateWithDuration:0.3 animations:^{
        [self->targetLanguagesTableView setFrame:self->fromRect];
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return existLanguages.count;
        case 1:
            return availableLanguages.count;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"TransLateLanguageSelectViewControllerCell";
    TransLateLanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[TransLateLanguageCell alloc] initWithReuseIdentifier:identifier];
    }
    NSString *cellIdentifier = nil;
    switch (indexPath.section) {
        case 0:
            cellIdentifier = [existLanguages objectAtIndex:indexPath.row];
            break;
        case 1:
            cellIdentifier = [availableLanguages objectAtIndex:indexPath.row];
        default:
            break;
    }
    cell.languageIdentifier = cellIdentifier;
    if ([cellIdentifier isEqualToString:currentLanguageIdentifier]){
        cell.isCurrent = YES;
    }else{
        cell.isCurrent = NO;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TransLateLanguageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Selected %@", cell.languageIdentifier);
    if (handler){
        handler(cell.languageIdentifier);
    }
    [self hidden];
    return;
}
@end
