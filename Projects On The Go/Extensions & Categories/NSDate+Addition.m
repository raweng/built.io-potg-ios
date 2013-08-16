//
//  NSDate+Addition.m
//  tibbr4
//
//  Created by Reefaq on 31/08/12.
//  Copyright (c) 2012 raweng. All rights reserved.
//

#import "NSDate+Addition.h"

#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)


@implementation NSDate (Addition)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate*)dateWithToday {
    return [[NSDate date] dateAtMidnight];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate*)dateAtMidnight {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:
                               (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                           fromDate:[NSDate date]];
	NSDate *midnight = [gregorian dateFromComponents:comps];
	return midnight;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatTime {
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"h:mm a";
//        formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_h_mm_a.title", @"Date format: 1:05 pm");
        formatter.locale = [NSLocale currentLocale];
    }
    return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDate {
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE, LLLL d, YYYY";
//        tibbrLocalizedString(@"my_wall_view.date_format_EEEE_LLLL_YYYY.title", @"Date format: Monday, July 27, 2009");
        formatter.locale = [NSLocale currentLocale];
    }
    return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortTime {
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
    
    if (diff < TT_DAY) {
        return [self formatTime];
        
    } else if (diff < TT_5_DAYS) {
        static NSDateFormatter* formatter = nil;
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"EEEE";
//            formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_EEEE.title", @"Date format: Monday");
            formatter.locale = [NSLocale currentLocale];
        }
        return [formatter stringFromDate:self];
        
    } else {
        static NSDateFormatter* formatter = nil;
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"M/d/yy";
//            formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_M_d_yy.title", @"Date format: 7/27/09");
            formatter.locale = [NSLocale currentLocale];
        }
        return [formatter stringFromDate:self];
    }
}

- (NSString*)formatDateTimeForCalendar{
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE h:mm a";
//        formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_EEEE_h_mm_a.title", @"Date format: Mon 1:05 pm");
        formatter.locale = [NSLocale currentLocale];
    }
    return [formatter stringFromDate:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*)formatDateTimeForTimmer {
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
    if (diff < TT_DAY) {
        return [self formatTime];
        
    } else if (diff < TT_5_DAYS) {
        static NSDateFormatter* formatter = nil;
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"EEE h:mm a";
//            formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_EEE_h_mm_a.title", @"Date format: Mon 1:05 pm");
            formatter.locale = [NSLocale currentLocale];
        }
        return [formatter stringFromDate:self];
        
    } else {
        static NSDateFormatter* formatter = nil;
        if (nil == formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MMM d, h:mm a";
//            formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_MMM_D_mm_a.title", @"Date format: Jul 27 1:05 pm");
            formatter.locale = [NSLocale currentLocale];
        }
        return [formatter stringFromDate:self];
    }

}
- (NSString*)formatDateTime {
//    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
//    if (diff < TT_DAY) {
//        return [self formatTime];
//        
//    } else if (diff < TT_5_DAYS) {
//        static NSDateFormatter* formatter = nil;
//        if (nil == formatter) {
//            formatter = [[NSDateFormatter alloc] init];
//            formatter.dateFormat = tibbrLocalizedString(@"EEE h:mm a", @"Date format: Mon 1:05 pm");
//            formatter.locale = [NSLocale currentLocale];
//        }
//        return [formatter stringFromDate:self];
//        
//    } else {
//        static NSDateFormatter* formatter = nil;
//        if (nil == formatter) {
//            formatter = [[NSDateFormatter alloc] init];
//            formatter.dateFormat = tibbrLocalizedString(@"MMM d h:mm a", @"Date format: Jul 27 1:05 pm");
//            formatter.locale = [NSLocale currentLocale];
//        }
//        return [formatter stringFromDate:self];
//    }
    
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM d, yyyy";
//        formatter.dateFormat = tibbrLocalizedString(@"my_wall_view.date_format_MMMM_d_yyyy.title", @"Date format: Jul 27 1:05 pm");
        formatter.locale = [NSLocale currentLocale];
    }
    NSString *dateString = [formatter stringFromDate:self];
        
    NSString* dateInString = [formatter stringFromDate:[NSDate date]];
        
    if ([dateInString isEqualToString:dateString]) {
        dateString = @"Today";
    }
    NSString *timeString = [self formatTime];
    
    return [NSString stringWithFormat:@"%@ at %@",dateString,timeString];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatRelativeTime {
    NSTimeInterval elapsed = [self timeIntervalSinceNow];
    if (elapsed > 0) {
        if (elapsed <= 1) {
            return @"in just a moment";
//            return tibbrLocalizedString(@"my_wall_view.just_moment.title", @"");
        }
        else if (elapsed < TT_MINUTE) {
            int seconds = (int)(elapsed);
            return [NSString stringWithFormat:@"in %d seconds", seconds];
            
        }
        else if (elapsed < 2*TT_MINUTE) {
            return @"in about a minute";
        }
        else if (elapsed < TT_HOUR) {
            int mins = (int)(elapsed/TT_MINUTE);
            return [NSString stringWithFormat:@"in %d minutes", mins];
        }
        else if (elapsed < TT_HOUR*1.5) {
            return @"in about an hour";
//            return tibbrLocalizedString(@"my_wall_view.in_hr.title", @"");
        }
        else if (elapsed < TT_DAY) {
            int hours = (int)((elapsed+TT_HOUR/2)/TT_HOUR);
            return [NSString stringWithFormat:@"in %d hours", hours];
        }
        else {
            return [self formatDateTime];
        }
    }
    else {
        elapsed = -elapsed;
        
        if (elapsed <= 1) {
            return @"just a moment ago";
            
        } else if (elapsed < TT_MINUTE) {
            int seconds = (int)(elapsed);
            return [NSString stringWithFormat:@"%d seconds ago", seconds];
            
        } else if (elapsed < 2*TT_MINUTE) {
            return @"about a minute ago";
            
        } else if (elapsed < TT_HOUR) {
            int mins = (int)(elapsed/TT_MINUTE);
            return [NSString stringWithFormat:@"%d minutes ago", mins];
            
        } else if (elapsed < TT_HOUR*1.5) {
            return @"about an hour ago";
            
        } else if (elapsed < TT_DAY) {
            int hours = (int)((elapsed+TT_HOUR/2)/TT_HOUR);
            return [NSString stringWithFormat:@"%d hours ago", hours];
            
        } else {
            return [self formatDateTime];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortRelativeTime {
    NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
    
    if (elapsed < TT_MINUTE) {
        return @"<1m";
        
    } else if (elapsed < TT_HOUR) {
        int mins = (int)(elapsed / TT_MINUTE);
        return [NSString stringWithFormat:@"%dm", mins];
        
    } else if (elapsed < TT_DAY) {
        int hours = (int)((elapsed + TT_HOUR / 2) / TT_HOUR);
        return [NSString stringWithFormat:@"%dh", hours];
        
    } else if (elapsed < TT_WEEK) {
        int day = (int)((elapsed + TT_DAY / 2) / TT_DAY);
        return [NSString stringWithFormat:@"%dd", day];
        
    } else {
        return [self formatShortTime];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday {
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM d";
        formatter.locale = [NSLocale currentLocale];
    }
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* day = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                   fromDate:self];
    
    if (day.day == today.day && day.month == today.month && day.year == today.year) {
        return @"Today";
        
    } else if (day.day == yesterday.day && day.month == yesterday.month
               && day.year == yesterday.year) {
        return @"Yesterday";
        
    } else {
        return [formatter stringFromDate:self];
    }
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatMonth {
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM";
        formatter.locale = [NSLocale currentLocale];
    }
    return [formatter stringFromDate:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDay {
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM";
        formatter.locale = [NSLocale currentLocale];
    }
    return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatYear {
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy";
        formatter.locale = [NSLocale currentLocale];
    }
    return [formatter stringFromDate:self];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

//-(NSString *)timeAgo {
//    NSDate *now = [NSDate date];
//    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
//    double deltaMinutes = deltaSeconds / 60.0f;
//    
//    if(deltaSeconds < 5) {
//        return tibbrLocalizedString(@"my_wall_view.just_now.title",@"Just now" );
//    } else if(deltaSeconds < 60) {
//        return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.seconds.title", @""), (int)deltaSeconds];
//    } else if(deltaSeconds < 120) {
//        return tibbrLocalizedString(@"my_wall_view.A_minute_ago.title",@"A minute ago" );
//    } else if (deltaMinutes < 60) {
//        return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.minutes_ago.title", @""), (int)deltaMinutes];
//    } else if (deltaMinutes < 120) {
//        return tibbrLocalizedString(@"my_wall_view.An_hour_ago.title",@"An hour ago" );
//    } else if (deltaMinutes < (24 * 60)) {
//        return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.hours_ago.title", @""), (int)floor(deltaMinutes/60)];
//    } else if (deltaMinutes < (24 * 60 * 2)) {
//        return tibbrLocalizedString(@"my_wall_view.yesterday.title",@"Yesterday" );
//    } else if (deltaMinutes < (24 * 60 * 7)) {
//        return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.days_ago.title", @" days ago"), (int)floor(deltaMinutes/(60 * 24))];
//    } else if (deltaMinutes < (24 * 60 * 14)) {
//        return tibbrLocalizedString(@"my_wall_view.last_week.title",@"Last week" );
//    } else if (deltaMinutes < (24 * 60 * 31)) {
//        return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.weeks_ago.title", @" weeks ago"), (int)floor(deltaMinutes/(60 * 24 * 7))];
//    } else if (deltaMinutes < (24 * 60 * 61)) {
//        return tibbrLocalizedString(@"my_wall_view.last_month.title",@"Last month" );
//    } else if (deltaMinutes < (24 * 60 * 365.25)) {
//        return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.months_ago.title", @" months ago"), (int)floor(deltaMinutes/(60 * 24 * 30))];
//    } else if (deltaMinutes < (24 * 60 * 731)) {
//        return tibbrLocalizedString(@"my_wall_view.last_year.title",@"Last year" );
//    }
//    
//    return [NSString stringWithFormat:tibbrLocalizedString(@"my_wall_view.years_ago.title", @" years ago"), (int)floor(deltaMinutes/(60 * 24 * 365))];
//}

@end
