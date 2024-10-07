//
//  ViewController.m
//  test
//
//  Created by jia yu on 2024/9/22.
//

#import "ViewController.h"
#import <HansTranslation/HansTranslation.h>

@interface ViewController (){
    NSMutableArray *targetArray;
    NSInteger runningIndex;
    
    NSString *sourceIdentifier;
    NSArray <NSString *>*demoStrings;
}
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)translateAction{
    if (runningIndex >= targetArray.count){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"translation completed." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *target = [targetArray objectAtIndex:runningIndex];
    
    if (@available(iOS 18.0, *)) {
        HansTranslationObject *transer = [[HansTranslationObject alloc] initWithSourceLanguage:sourceIdentifier
                                                                withTargetLanguage:target];
        transer.title = @"只有iOS 18 以后的操作系统才可用";
        transer.headerText = @"点击翻译按钮继续";
        transer.buttonText = @"翻译";
        transer.footerText = @"尾巴";
        [transer translate:demoStrings
                withRootVC:self
               withHandler:^(HansTranslationObject * _Nullable translater,
                     NSArray<NSString *> * _Nullable resultsArray,
                     NSError * _Nullable error) {
            if (error){
                NSLog(@"Translate error:%@", error.localizedDescription);
                return;
            }

            NSString *title = [[NSString alloc] initWithFormat:@"%@ translate to %@",
                [HansTranslationObject nameWithLocalIdentifier:self->sourceIdentifier],
                [HansTranslationObject nameWithLocalIdentifier:target]];
            NSMutableString *message = [[NSMutableString alloc] init];
            for (int i=0;i<resultsArray.count;i++){
                NSString *from = [self->demoStrings objectAtIndex:i];
                NSString *to = [resultsArray objectAtIndex:i];
                [message appendFormat:@"%@ -> %@\n\n", from, to];
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Stop" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:ok];
            if (self->runningIndex < self->targetArray.count){
                UIAlertAction *next = [UIAlertAction actionWithTitle:@"Next Language" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    self->runningIndex ++;
                    [self translateAction];
                }];
                [alert addAction:next];
            }
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (@available(iOS 18.0, *)) {
        NSArray <NSString *>*array = [HansTranslationObject existLanguageIdentfiers];
        if (array && array.count > 0){
            for (NSString *str in array){
                NSLog(@"%@ (%@) Installed.", [HansTranslationObject nameWithLocalIdentifier:str], str);
            }
        }else{
            NSLog(@"Warning HansTranslation existLanguageIdentfiers failed.");
        }
        
        array = [HansTranslationObject availableLanguageIdentifiers];
        for (NSString *str in array){
            NSLog(@"Available %@ (%@).", [HansTranslationObject nameWithLocalIdentifier:str], str);
        }
        
        sourceIdentifier = @"en-CN";
        demoStrings = @[
            @"My name is Hans.",
            @"Input a word.",
            @"Hello world.",
            @"This year’s WWDC session named What’s New in Swift has got the following sample code!"
        ];
        
        targetArray = [[NSMutableArray alloc] init];
        for (NSString *str in [HansTranslationObject existLanguageIdentfiers]){
            if ([str isEqualToString:sourceIdentifier]){
                continue;
            }
            [targetArray addObject:str];
        }
        for (NSString *str in [HansTranslationObject availableLanguageIdentifiers]){
            [targetArray addObject:str];
        }
        runningIndex = 0;
        [self translateAction];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"HansTranslation available iOS18." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    return;
}

@end
