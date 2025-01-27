//
//  SRTHistoryTableView.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/18.
//
#import <HansServer/HansServer.h>
#import "SRTHistoryTableView.h"
#import "SRTHistoryTableViewCell.h"
@interface SRTHistoryTableView()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *files;
}
@end

@implementation SRTHistoryTableView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame style:UITableViewStyleInsetGrouped];
    if (self){
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.layer.cornerRadius = 8.f;
        self.layer.masksToBounds = YES;
        self.dataSource = self;
        self.delegate = self;
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSArray *fs = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
        files = [[NSMutableArray alloc] initWithArray:fs];
        [files sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *file1 = obj1;
            NSString *file2 = obj2;
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSDictionary *dict1 = [NSFileManager.defaultManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file1] error:nil];
            NSDictionary *dict2 = [NSFileManager.defaultManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file2] error:nil];
            NSDate *date1 = [dict1 valueForKey:@"NSFileModificationDate"];
            NSDate *date2 = [dict2 valueForKey:@"NSFileModificationDate"];
            return [date1 compare:date2];
        }];
        
    }
    return self;
}

-(void)insertNewFile:(NSString *)newFile{
    [files insertObject:newFile atIndex:0];
    [self beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self endUpdates];
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [UIHans shareFile:[path stringByAppendingPathComponent:newFile] withName:@"Translated SRT file" withExtName:@"txt" withSize:CGSizeMake(500.f, 300.f) withArrowView:self withArrowFrom:CGRectMake(0.f, 0.f, 100.f, 50.f)];
    return;
}

-(void)openFile:(NSString *)file{
    NSString *target = [[NSString alloc] initWithFormat:@"%@/Documents/%@", NSHomeDirectory(), file];
    UIDocumentInteractionController *c = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:target]];
    c.delegate = UIHans.defaultUIHans;
    [c presentPreviewAnimated:YES];
    return;
}

-(void)removeFile:(NSIndexPath *)indexPath{
    NSString *file = [files objectAtIndex:indexPath.row];
    NSString *target = [[NSString alloc] initWithFormat:@"%@/Documents/%@", NSHomeDirectory(), file];
    [NSFileManager.defaultManager removeItemAtPath:target error:nil];
    
    [self beginUpdates];
    [files removeObjectAtIndex:indexPath.row];
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
    return;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return files.count;
}

-(SRTHistoryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"SRTHistoryTableViewCell";
    SRTHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[SRTHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.file = [files objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SRTHistoryTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self openFile:cell.file];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self removeFile:indexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"History:";
}
@end
