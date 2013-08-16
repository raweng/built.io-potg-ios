//
//  AppUtils.m
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "AppUtils.h"
#import <MobileCoreServices/UTType.h>

@implementation AppUtils

+ (NSDate *)dateWithUTCDateString:(NSString*)dateString{
    
    NSString* mydate = [dateString substringToIndex:[dateString length] - 8];
	mydate = [mydate stringByAppendingFormat:@"GMT%@",[dateString substringFromIndex:[mydate length]] ];
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc]
                                 initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormat setLocale:enUSPOSIXLocale];
    [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm"];
    return [dateFormat dateFromString:mydate];
    
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
//    
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//    [dateFormatter setTimeZone:gmt];
//    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
}

+(NSDate *)stringToDate:(NSString*)dateString{
    NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
    [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    [isoDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    return [isoDateFormatter dateFromString:dateString];
}

+(NSString *)gmtStringWildFireFromUtc:(NSString *)date{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate * localDate = [formatter dateFromString:date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *timeStamp = [dateFormatter stringFromDate:localDate];
    
    NSDateFormatter* dateFormatterA = [[NSDateFormatter alloc] init];
    [dateFormatterA setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateString = [dateFormatterA dateFromString:timeStamp];
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
    
    [components month]; //gives you month
    [components day]; //gives you day
    [components year];
    
    return timeStamp;
}

+(NSDate *)convertGMTtoLocal:(NSString *)localDateStr
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    NSDate *localDate = [formatter dateFromString: localDateStr];
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method

    NSTimeInterval gmtTimeInterval = [localDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    return gmtDate;
}

+(NSURL*)documentDirectoryURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSString*)mimeTypeForFileURL:(NSURL*)fileURL {
    
    CFStringRef pathExtension = (__bridge_retained CFStringRef)fileURL.pathExtension;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    
    // The UTI can be converted to a mime type:
    
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    return mimeType;
}

+ (NSString *)fileTypeFromFilename:(NSString *)filename{
    NSString *extension = [filename pathExtension];
    if ([extension isEqual:@"jpg"] || [extension isEqual:@"jpeg"]) {
        return @"jpg";
    }
    if ([extension isEqual:@"mp3"] || [extension isEqual:@"wav"]) {
        return @"aud";
    }
    if ([extension isEqual:@"bmp"]) {
        return @"bmp";
    }

    if ([extension isEqual:@"gif"]) {
        return @"gif";
    }

    if ([extension isEqual:@"png"]) {
        return @"png";
    }

    if ([extension isEqual:@"txt"]) {
        return @"text";
    }
    if ([extension isEqual:@"mp4"] || [extension isEqual:@"mov"] || [extension isEqual:@"3gp"]) {
        return @"vid";
    }
    if ([extension isEqual:@"xls"]) {
        return @"xls";
    }
    if ([extension isEqual:@"vsd"]) {
        return @"vsd";
    }

    if ([extension isEqual:@"zip"]) {
        return @"zip";
    }

    if ([extension isEqual:@"doc"]) {
        return @"doc";
    }

    if ([extension isEqual:@"ppt"]) {
        return @"ppt";
    }

    if ([extension isEqual:@"pdf"]) {
        return @"pdf";
    }
    
    return @"file";
}

@end

