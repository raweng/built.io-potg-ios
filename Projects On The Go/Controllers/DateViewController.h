//
//  DateViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerDelegate <NSObject>

- (void)startDateSelected:(NSDate *)date;
- (void)endDateSelected:(NSDate *)date;

@end

@interface DateViewController : UIViewController{
    __weak id <DatePickerDelegate> datePickerDelegate;
}
@property (nonatomic ,weak) id <DatePickerDelegate> datePickerDelegate;
typedef enum{
    START_DATE = 0,
    END_DATE
}Date;


/**
 @abstract The Cache Policy to be adopted. Defaults to IGNORE_CACHE.
 */
@property (nonatomic, assign) Date date;
@end
