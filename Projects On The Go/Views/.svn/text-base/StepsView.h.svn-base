//
//  StepsView.h
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TASKNAME @"TaskName"
#define TASKDESCRIPTION @"TaskDescription"
#define TASKBUG @"TaskBugIndex"
@interface StepsView : UIView
@property (nonatomic, strong) UITextView *nameTextView;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIButton *taskButton;
@property (nonatomic, strong) id textViewDelegate;

- (id)initWithDelegate:(id)delegate;
-(CGFloat) readjustViews;
-(NSDictionary*) getValues;
@end
