//
//  EditBugDetailsController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditBugDetailsController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *statusButton;
@property (strong, nonatomic) IBOutlet UIButton *severityButton;
@property (strong, nonatomic) IBOutlet UIButton *reprodubleButton;
@property (strong, nonatomic) BuiltObject *project;
@property (weak, nonatomic) IBOutlet UILabel *bugTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *assigneeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *severityLabel;
@property (weak, nonatomic) IBOutlet UILabel *reproducibleLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;

- (IBAction)dueDateButton:(id)sender;
- (IBAction)statusAction:(id)sender;
- (IBAction)severityAction:(id)sender;
- (IBAction)reproducibleAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *dueDateAction;

typedef enum{
    SEVERITY = 0,
    STATUS,
    DUE_DATE,
    REPRODUCIBLE
}BugDetails;

@property (nonatomic, assign) BugDetails bugDetails;

- (void)prepareViews;
- (void)loadData;

@end
