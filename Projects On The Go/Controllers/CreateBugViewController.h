//
//  CreateBugViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateBugViewController : UIViewController
- (IBAction)hadleTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIButton *dueDateButton;
@property (weak, nonatomic) IBOutlet UIButton *severityButton;
@property (weak, nonatomic) IBOutlet UIButton *reproducibleButton;
@property (weak, nonatomic) IBOutlet UIButton *attachButton;
@property (weak, nonatomic) BuiltObject *project;
@property (weak, nonatomic) IBOutlet UILabel *attachmentLabel;
- (IBAction)attachAction:(id)sender;

- (IBAction)severityAction:(id)sender;
- (IBAction)reproducibleAction:(id)sender;
- (IBAction)dueDateAction:(id)sender;
typedef enum{
    SEVERITY = 0,
    DUE_DATE,
    REPRODUCIBLE
}BugProperties;

@property (nonatomic, assign) BugProperties bugProperties;

@end
