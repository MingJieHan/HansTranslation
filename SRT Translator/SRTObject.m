//
//  SRTObject.m
//  SRT Translater
//
//  Created by jia yu on 2024/11/14.
//

#import "SRTObject.h"



@implementation SRTObject
@synthesize index;
@synthesize durationString;
@synthesize string;
@synthesize translatedString;

-(id)initWithString:(NSString *)str{
    self = [super init];
    if (self){
        if (nil == str){
            return nil;
        }
        NSString *info = [[NSString alloc] initWithString:str];
        
        //去掉处理字符串开始位置的\n
        NSRange range = [info rangeOfString:@"\n"];
        while (0 == range.location && 1 == range.length) {
            info = [info substringFromIndex:1];
            range = [info rangeOfString:@"\n"];
        }
        
        NSArray *array = [info componentsSeparatedByString:@"\n"];
        if (array.count < 2){
            return nil;
        }
        index = [[array objectAtIndex:0] integerValue];
        durationString = [[array objectAtIndex:1] stringValue];
        string = [[NSMutableString alloc] init];
        if (array.count >= 3){
            for (int i=2;i<array.count;i++){
                if (string.length > 0){
                    [string appendString:@"\n"];
                }
                [string appendString:[array objectAtIndex:i]];
            }
        }
    }
    return self;
}


+(NSArray <SRTObject *>*)initWithSRTSourceFile:(NSURL *)fileURL{
    if (nil == fileURL){
        return nil;
    }
    NSError *error = nil;
    [fileURL startAccessingSecurityScopedResource];
    NSString *info = [[NSString alloc] initWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    [fileURL stopAccessingSecurityScopedResource];
    if (nil == info){
        return nil;
    }
    NSArray *array = [info componentsSeparatedByString:@"\n\n"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSString *str in array){
        SRTObject *obj = [[SRTObject alloc] initWithString:str];
        if (obj){
            [result addObject:obj];
        }
    }
    return result;
}

+(BOOL)exportTranslated:(NSArray <SRTObject *>*)srtObjects intoSRTFile:(NSString *)exportFile{
    NSMutableString *info = [[NSMutableString alloc] init];
    for (SRTObject *o in srtObjects){
        [info appendFormat:@"%lu", o.index];
        [info appendString:@"\n"];
        [info appendString:o.durationString];
        [info appendString:@"\n"];
        [info appendString:o.translatedString];
        [info appendString:@"\n\n"];
    }
    NSError *error = nil;
    BOOL success = [info writeToFile:exportFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error){
        NSLog(@"Write file error:%@", error.localizedDescription);
        return NO;
    }
    return success;
}
@end
