//
//  ViewController.m
//  demomacOS
//
//  Created by jia yu on 2024/10/2.
//

#import "ViewController.h"
#import <HansTranslation/HansTranslation.h>

@interface ViewController()<NSTextFieldDelegate>{
    
}
@property (nonatomic) IBOutlet NSTextField *sourceTextField;
@property (nonatomic) IBOutlet NSComboButton *sourceLanguageButton;

@property (nonatomic) IBOutlet NSComboButton *targetLanguageButton;
@property (nonatomic) IBOutlet NSTextField *targetTextField;
@end

@implementation ViewController
@synthesize sourceTextField;
@synthesize sourceLanguageButton;
@synthesize targetTextField;
@synthesize targetLanguageButton;

-(void)changeTargetIdentifier:(id)sender{
    NSMenuItem *item = (NSMenuItem *)sender;
    targetLanguageButton.title = item.title;
    return;
    
}

-(void)changeSourceIdentifier:(id)sender{
    NSMenuItem *item = (NSMenuItem *)sender;
    sourceLanguageButton.title = item.title;
    return;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [sourceLanguageButton.menu removeAllItems];
    [targetLanguageButton.menu removeAllItems];
    
    sourceTextField.stringValue = @"Hello World\nHello Hans\nApple";
    
    NSArray *array = [HansTranslation existLanguageIdentfiers];
    for (NSString *identifier in array){
        NSString *name = [HansTranslation nameWithLocalIdentifier:identifier];
        NSString *title = [[NSString alloc] initWithFormat:@"%@ (%@)", name, identifier];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(changeSourceIdentifier:) keyEquivalent:@""];
        [sourceLanguageButton.menu addItem:item];
        
        item = [[NSMenuItem alloc] initWithTitle:title action:@selector(changeTargetIdentifier:) keyEquivalent:@""];
        [targetLanguageButton.menu addItem:item];
    }
    
    array = [HansTranslation availableLanguageIdentifiers];
    for (NSString *identifier in array){
        NSString *name = [HansTranslation nameWithLocalIdentifier:identifier];
        NSString *title = [[NSString alloc] initWithFormat:@"%@ (%@)", name, identifier];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(changeSourceIdentifier:) keyEquivalent:@""];
        [sourceLanguageButton.menu addItem:item];

        item = [[NSMenuItem alloc] initWithTitle:title action:@selector(changeTargetIdentifier:) keyEquivalent:@""];
        [targetLanguageButton.menu addItem:item];
    }

    sourceLanguageButton.title = sourceLanguageButton.menu.itemArray.firstObject.title;
    targetLanguageButton.title = [targetLanguageButton.menu.itemArray objectAtIndex:1].title;
    return;
}

-(NSString *)identifierForTitle:(NSString *)title{
    NSRange range = [title rangeOfString:@"("];
    if (range.location > 0 && range.length > 0){
        NSString *res = [title substringFromIndex:range.location + range.length];
        range = [res rangeOfString:@")"];
        return [res substringToIndex:range.location];
    }
    return title;
}

-(IBAction)translate:(id)sender{
    NSLog(@"%@", sourceLanguageButton.title);
    NSLog(@"%@", targetLanguageButton.title);
    NSString *sourceId = [self identifierForTitle:sourceLanguageButton.title];
    NSString *targetId = [self identifierForTitle:targetLanguageButton.title];
    HansTranslation *transfer = [[HansTranslation alloc] initWithSourceLanguage:sourceId
                                                             withTargetLanguage:targetId];
//    HansTranslation *transfer = [[HansTranslation alloc] initWithSourceLanguage:@"en-CN"            // Warning about your input text language.
//                                                             withTargetLanguage:@"zh-Hans-CN"];     // Warning for translation target language.
    transfer.headerText = [NSString stringWithFormat:@"Translate to %@\nAre you sure?\n\n", [HansTranslation nameWithLocalIdentifier:targetId]];
    transfer.buttonText = @"Sure";
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    if (sourceTextField.stringValue && sourceTextField.stringValue.length > 0){
        NSArray *array = [sourceTextField.stringValue componentsSeparatedByString:@"\n"];
        for (NSString *str in array){
            if (str && str.length > 0){
                [sources addObject:str];
            }
        }
    }else{
        [sources addObject:@"Hello World"];
        [sources addObject:@"Hello Hans"];
        [sources addObject:@"Apple"];
    }
    
    [transfer translate:sources
             withRootVC:self
            withHandler:^(HansTranslation * _Nullable translater,
                          NSArray<NSString *> * _Nullable resultsArray,
                          NSError * _Nullable error) {
        if (error){
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Error";
            alert.informativeText = error.localizedDescription;
            [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    
            }];
            return;
        }
        NSMutableString *res = [[NSMutableString alloc] init];
        for (int i=0;i<resultsArray.count;i++){
            NSString *source = [sources objectAtIndex:i];
            NSString *target = [resultsArray objectAtIndex:i];
            [res appendFormat:@"%@ -> %@\n", source, target];
        }
        NSLog(@"%@", res);
        res = [[NSMutableString alloc] init];
        for (NSString *str in resultsArray){
            [res appendString:str];
            [res appendString:@"\n"];
        }
        self->targetTextField.stringValue = res;
//        NSAlert *alert = [[NSAlert alloc] init];
//        alert.messageText = @"Apple Translation";
//        alert.informativeText = res;
//        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
//            
//        }];
        return;
    }];
    return;
}
@end
