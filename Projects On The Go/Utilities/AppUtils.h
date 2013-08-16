//
//  AppUtils.h
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject
+ (NSDate *)dateWithUTCDateString:(NSString*)dateString;
+ (NSDate *)stringToDate:(NSString*)dateString;
+ (NSString *)gmtStringWildFireFromUtc:(NSString *)date;
+ (NSDate *)convertGMTtoLocal:(NSString *)localDateStr;
+ (NSURL*)documentDirectoryURL;
+ (NSString*)mimeTypeForFileURL:(NSURL*)fileURL;
+ (NSString *)fileTypeFromFilename:(NSString *)filename;
@end
