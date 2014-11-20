//
//  NewMilestoneViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMilestoneViewController : UIViewController
- (IBAction)showStartTimePicker:(id)sender;
- (IBAction)showEndTimePicker:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *milestoneName;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *projectName;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) BuiltObject *project;
- (IBAction)hadleTap:(id)sender;

@end
