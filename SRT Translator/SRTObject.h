//
//  SRTObject.h
//  SRT Translater
//
//  Created by jia yu on 2024/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SRTObject:NSObject
@property (nonatomic,readonly) NSUInteger index;
@property (nonatomic,readonly) NSString *durationString;  //@"00:00:00,123 --> 00:00:00,789"
@property (nonatomic,readonly) NSMutableString *string;
@property (nonatomic,nullable) NSString *translatedString;

-(id)init NS_UNAVAILABLE;
-(id)initWithString:(NSString *)str;    //part of srt from index to \n\n end.
+(NSArray <SRTObject *>*)initWithSRTSourceFile:(NSURL *)fileURL;

+(BOOL)exportTranslated:(NSArray <SRTObject *>*)srtObjects intoSRTFile:(NSString *)exportFile;
@end
NS_ASSUME_NONNULL_END
