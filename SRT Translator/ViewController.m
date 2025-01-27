//
//  ViewController.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/14.
//

#import "ViewController.h"
#import <HansTranslation/HansTranslation.h>
#import <HansServer/HansServer.h>
#import "SRTObject.h"
#import "TransLateLanguageSelectView.h"
#import "SRTHistoryTableView.h"
#define LAST_SOURCE_LANGUAGE @"last_source"
#define LAST_TARGET_LANGUAGE @"last_target"

@interface ViewController ()<UIDocumentPickerDelegate,UIDocumentBrowserViewControllerDelegate>{
    UIView *sourceBGView;
    UIHansButton *sourceLanguageButton;
    NSString *sourceLanguageIdentifier;
    UIHansButton *selectFileButton;
    
    UIView *targetBGView;
    UIHansButton *targetLanguageButton;
    NSString *targetLanguageIdentifier;
    
    UIHansButton *exchangeButton;
    UIImageView *exchangeView;
    
    NSArray <SRTObject *>*srtObjects;
    NSURL *sourceURL;
    UIAlertController *progressAlert;
    TransLateLanguageSelectView *languageSelector;
    NSArray *preferredArray;
    
    NSMutableArray *sourceStrings;
    SRTHistoryTableView *historyTableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    preferredArray = [HansTranslationObject existLanguageIdentfiers];
    for (NSString *identifier in preferredArray){
        NSLog(@"系统已安装语言: %@", [HansLocal mixedDescriptionLocalIdentifier:identifier]);
    }
//    NSString *autoRes = [HansLocal dominantLocalWithString:@"哈哈哈"];
    
    if (nil == sourceBGView){
        sourceBGView = [[UIView alloc] initWithFrame:CGRectMake(10.f, 70.f, self.view.frame.size.width-20.f, 140.f)];
        sourceBGView.layer.masksToBounds = YES;
        sourceBGView.layer.cornerRadius = 8.f;
        sourceBGView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:sourceBGView];
    }
    
    if (nil == sourceLanguageButton){
        sourceLanguageButton = [[UIHansButton alloc] initWithFrame:CGRectMake(20.f, 10.f, 150.f, 40.f)];
        sourceLanguageButton.enabled = YES;
        sourceLanguageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [sourceLanguageButton addTarget:self action:@selector(selectLanguageAction:) forControlEvents:UIControlEventTouchUpInside];
        [sourceLanguageButton setTitleColor:[UIHans colorFromHEXString:@"000000"] forState:UIControlStateNormal];
        [sourceLanguageButton setBackgroundColor:[UIHans white] forState:UIControlStateNormal];
        [sourceLanguageButton setBackgroundColor:[UIHans gray] forState:UIControlStateHighlighted];
        [self setSourceLanguage:nil];
        [sourceBGView addSubview:sourceLanguageButton];
    }
    
    if (nil == selectFileButton){
        selectFileButton = [[UIHansButton alloc] initWithFrame:CGRectMake( (sourceBGView.frame.size.width-200.f)/2.f,
                                                                          50.f, 200.f, 40.f)];
        selectFileButton.enabled = YES;
        selectFileButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"files" ofType:@"png"]];
        [selectFileButton setImage:image forState:UIControlStateNormal];
        [selectFileButton setTitle:NSLocalizedString(@"Source SRT file", nil) forState:UIControlStateNormal];
        [selectFileButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [selectFileButton addTarget:self action:@selector(selectFileAction) forControlEvents:UIControlEventTouchUpInside];
        [selectFileButton setBackgroundColor:[UIHans white] forState:UIControlStateNormal];
        [selectFileButton setBackgroundColor:[UIHans lightestGray] forState:UIControlStateHighlighted];
        [sourceBGView addSubview:selectFileButton];
    }
    
    if (nil == targetBGView){
        float y = CGRectGetMaxY(sourceBGView.frame) + 0.8f;
        targetBGView = [[UIView alloc] initWithFrame:CGRectMake(10.f, y, self.view.frame.size.width-20.f, 140.f)];
        targetBGView.layer.masksToBounds = YES;
        targetBGView.layer.cornerRadius = 8.f;
        targetBGView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:targetBGView];
    }
    
    if (nil == targetLanguageButton){
        targetLanguageButton = [[UIHansButton alloc] initWithFrame:CGRectMake(20.f, 10.f, 150.f, 40.f)];
        targetLanguageButton.enabled = YES;
        targetLanguageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [targetLanguageButton addTarget:self action:@selector(selectLanguageAction:) forControlEvents:UIControlEventTouchUpInside];
        [targetLanguageButton setTitleColor:[UIHans colorFromHEXString:@"2A9FB8"] forState:UIControlStateNormal];
        [targetLanguageButton setBackgroundColor:[UIHans white] forState:UIControlStateNormal];
        [targetLanguageButton setBackgroundColor:[UIHans gray] forState:UIControlStateHighlighted];
        [self setTargetLanguage:nil];
        [targetBGView addSubview:targetLanguageButton];
    }
    
    if (nil == exchangeButton){
        exchangeButton = [[UIHansButton alloc] initWithFrame:CGRectMake( (targetBGView.frame.size.width-200.f)/2.f,
                                                                          50.f, 200.f, 40.f)];
        exchangeButton.enabled = YES;
        exchangeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [exchangeButton setTitle:NSLocalizedString(@"SRT file", nil)
                          forState:UIControlStateNormal];
        [exchangeButton setTitleColor:[UIHans colorFromHEXString:@"C0E4E7"] forState:UIControlStateNormal];
        [exchangeButton addTarget:self action:@selector(exchangeAction) forControlEvents:UIControlEventTouchUpInside];
        [exchangeButton setBackgroundColor:[UIHans white] forState:UIControlStateNormal];
        [exchangeButton setBackgroundColor:[UIHans lightestGray] forState:UIControlStateHighlighted];
        [targetBGView addSubview:exchangeButton];
    }
    
    if (nil == exchangeView){
        float width = 36.f;
        float y = CGRectGetMaxY(sourceBGView.frame) - width/2.f;
        exchangeView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-width)/2.f, y, width, width)];
        exchangeView.userInteractionEnabled = YES;
        exchangeView.backgroundColor = [UIColor clearColor];
        exchangeView.image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"exchange" ofType:@"png"]];
        [self.view addSubview:exchangeView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeAction)];
        [exchangeView addGestureRecognizer:tap];
    }
    
    if (nil == historyTableView){
        float y = CGRectGetMaxY(targetBGView.frame) + 20.f;
        historyTableView = [[SRTHistoryTableView alloc] initWithFrame:CGRectMake(10.f, y, self.view.frame.size.width-20.f, self.view.frame.size.height-y-20.f)];
        [self.view addSubview:historyTableView];
    }
}

-(void)setTargetLanguage:(NSString *)languageIdentifier{
    targetLanguageIdentifier = languageIdentifier;
    if (nil == targetLanguageIdentifier){
        targetLanguageIdentifier = [NSUserDefaults.standardUserDefaults valueForKey:LAST_TARGET_LANGUAGE];
    }else{
        [NSUserDefaults.standardUserDefaults setValue:targetLanguageIdentifier forKey:LAST_TARGET_LANGUAGE];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    if (nil == targetLanguageIdentifier){
        targetLanguageIdentifier = preferredArray.firstObject;
    }
    NSString *showLanguageString = [HansLocal mixedDescriptionLocalIdentifier:targetLanguageIdentifier];
    [targetLanguageButton setTitle:showLanguageString forState:UIControlStateNormal];
    return;
}

-(void)setSourceLanguage:(NSString *)languageIdentifier{
    sourceLanguageIdentifier = languageIdentifier;
    if (nil == sourceLanguageIdentifier){
        sourceLanguageIdentifier = [NSUserDefaults.standardUserDefaults valueForKey:LAST_SOURCE_LANGUAGE];
    }else{
        [NSUserDefaults.standardUserDefaults setValue:sourceLanguageIdentifier forKey:LAST_SOURCE_LANGUAGE];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    if (nil == sourceLanguageIdentifier){
        sourceLanguageIdentifier = preferredArray.firstObject;
    }
    NSString *showLanguageString = [HansLocal mixedDescriptionLocalIdentifier:sourceLanguageIdentifier];
    [sourceLanguageButton setTitle:showLanguageString forState:UIControlStateNormal];
    return;
}

-(void)selectLanguageAction:(id)sender{
    if (nil == languageSelector){
        languageSelector = [[TransLateLanguageSelectView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    ViewController *strongSelf = self;
    CGRect fromRect = CGRectZero;
    if (sender == sourceLanguageButton){
        languageSelector.handler = ^(NSString * _Nullable selectedIdentifier) {
            [strongSelf setSourceLanguage:selectedIdentifier];
        };
        fromRect = sourceLanguageButton.frame;
        languageSelector.currentLanguageIdentifier = sourceLanguageIdentifier;
    }
    if (sender == targetLanguageButton){
        languageSelector.handler = ^(NSString * _Nullable selectedIdentifier) {
            [strongSelf setTargetLanguage:selectedIdentifier];
        };
        fromRect = targetLanguageButton.frame;
        languageSelector.currentLanguageIdentifier = targetLanguageIdentifier;
    }
    [languageSelector showFrom:self fromRect:fromRect];
}

-(void)exchangeAction{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        if (0 != self->exchangeView.tag){
            self->exchangeView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self->exchangeView.tag = 0;
        }else{
            self->exchangeView.transform = CGAffineTransformMakeScale(1.0, -1.0);
            self->exchangeView.tag = 1;
        }
        NSString *tmpTarget = self->targetLanguageIdentifier;
        [self setTargetLanguage:self->sourceLanguageIdentifier];
        [self setSourceLanguage:tmpTarget];
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
    return;
}

#pragma mark - My Functions
-(void)startTranslate{
    sourceStrings = [[NSMutableArray alloc] init];
    for (SRTObject *o in srtObjects){
        if (o.string && o.string.length > 0){
            [sourceStrings addObject:o.string];
        }
    }
    
    if (nil == sourceStrings || 0 == sourceStrings.count){
        [self->progressAlert dismissViewControllerAnimated:YES completion:^{
            [UIHans alertTitle:@"Error" withMessage:@"NOT FOUND any string in selected file."];
        }];
        return;
    }
    
    //TODO 这里可以把 sourceStrings 字符内容重复的删除掉

    NSString *sourceIdentifier = sourceLanguageIdentifier;  //@"zh-Hans-CN"; //@"zh-Hans-CN";
    NSString *target = targetLanguageIdentifier;            //@"en-CN";
    HansTranslationObject *transer = [[HansTranslationObject alloc] initWithSourceLanguage:sourceIdentifier
                                                            withTargetLanguage:target];
    transer.title = @"SRT Translater";
    transer.headerText = [[NSString alloc] initWithFormat:@"%lu word or phrase waiting translate.", (unsigned long)sourceStrings.count];
    transer.buttonText = @"Translate Action";
    transer.translatingText = @"Translating ...\nPlease waiting for completed.";
    transer.footerText = [NSString stringWithFormat:@"SRT Translater Version %@ Build %@  @Mingjie Han", UIHans.appVersion , UIHans.appBuildVersion];
    [transer translate:sourceStrings
            withRootVC:progressAlert
           withHandler:^(HansTranslationObject * _Nullable translater,
                 NSArray<NSString *> * _Nullable resultsArray,
                  NSString * _Nullable errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->progressAlert dismissViewControllerAnimated:YES completion:^{
                [self completedTranslateWith:resultsArray errorString:errorString];
            }];
        });
        return;
    }];    
}

-(void)pickupURLs:(NSArray *)urls{
    sourceURL = urls.firstObject;
    srtObjects = [SRTObject initWithSRTSourceFile:sourceURL];
    progressAlert = [UIAlertController alertControllerWithTitle:@"Translating" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:progressAlert animated:YES completion:^{
        [self startTranslate];
    }];
    return;
}

-(void)completedTranslateWith:(NSArray *)resultsArray errorString:(NSString *)errorString{
    if (nil == resultsArray || 0 == resultsArray.count){
        if (errorString){
            [UIHans alertTitle:@"Error" withMessage:errorString];
        }
        return;
    }
    if (resultsArray.count != sourceStrings.count){
        [UIHans alertTitle:@"Error" withMessage:@"SRT objects number is different with translated results."];
        return;
    }
    
    //为 srtObjects 中每个对象，赋予翻译后的字符串
    for (SRTObject *obj in srtObjects){
        if (nil == obj.string){
            obj.translatedString = nil;
            continue;
        }
        if (0 == obj.string.length){
            obj.translatedString = @"";
            continue;
        }
        NSUInteger index;
        for (index = 0;index < sourceStrings.count;index++){
            if ([[sourceStrings objectAtIndex:index] isEqualToString:obj.string]){
                break;
            }
        }
        if (index >= resultsArray.count){
            obj.translatedString = @"";
        }else{
            obj.translatedString = [resultsArray objectAtIndex:index];
        }
    }
    
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *sourceName = [[[sourceURL lastPathComponent] stringByDeletingPathExtension] stringByDeletingPathExtension];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:NSTimeZone.systemTimeZone];
    [df setCalendar:NSCalendar.currentCalendar];
    [df setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *newName = [[NSString alloc] initWithFormat:@"translated_%@_For%@.srt.txt", [df stringFromDate:NSDate.date], sourceName];
    file = [file stringByAppendingPathComponent:newName];
    if ([NSFileManager.defaultManager fileExistsAtPath:file]){
        [NSFileManager.defaultManager removeItemAtPath:file error:nil];
    }
    BOOL success = [SRTObject exportTranslated:srtObjects intoSRTFile:file];
    if (success){
        [historyTableView insertNewFile:newName];
//        [UIHans shareFile:file];
    }else{
        [UIHans alertTitle:@"Error" withMessage:@"Export translated result failed."];
    }
}

-(void)selectFileAction{
    if ([sourceLanguageIdentifier isEqualToString:targetLanguageIdentifier]){
        [UIHans alertTitle:@"Error" withMessage:@"不能执行翻译，因为翻译前后的设置语种相同。"];
        return;
    }
    
    UIDocumentPickerViewController *picker = nil;
    NSArray *types = @[@"txt", @"srt"];
    NSMutableArray *utTypes = [[NSMutableArray alloc] init];
    for (NSString *tString in types){
        UTType *type = [UTType typeWithTag:tString tagClass:UTTagClassFilenameExtension conformingToType:nil];
        [utTypes addObject:type];
    }
    types = utTypes;
    if (@available(macCatalyst 14, *)) {
        UIDocumentBrowserViewController *b = [[UIDocumentBrowserViewController alloc] initForOpeningContentTypes:types];
        b.allowsPickingMultipleItems = NO;
        b.allowsDocumentCreation = NO;
        b.delegate = self;
        [UIHans.currentVC presentViewController:b animated:YES completion:nil];
        return;
    }else{
        picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:types];
    }
    
    picker.allowsMultipleSelection = NO;
    picker.delegate = self;
    [UIHans.currentVC presentViewController:picker animated:YES completion:nil];
    return;
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller
        didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls API_AVAILABLE(ios(11.0)){
    [controller dismissViewControllerAnimated:YES completion:^{
        [self pickupURLs:urls];
    }];
    return;
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    return;
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *> *)documentURLs API_AVAILABLE(ios(12.0)){
    [controller dismissViewControllerAnimated:YES completion:^{
        [self pickupURLs:documentURLs];
    }];
    return;
}
@end
