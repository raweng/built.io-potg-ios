//
//  NewTaskViewController.m
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "NewTaskViewController.h"
#import "StepsView.h"
#import "UserListPickerViewController.h"
#import "THContactPickerView.h"
#import "UsersTableViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AppConstants.h"

#define kSupviewGap 5.0f
#define ASSIGNEE_TEXTVIEW_TAG 99
#define STEP_NAME_TEXTVIEW_TAG 50
#define STEP_DESCRIPTION_TEXTVIEW_TAG 60

@interface NewTaskViewController () <UITextViewDelegate, UserListDelegate, THContactPickerDelegate, UserTableViewDelegate>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UITextView *nameText;
@property (nonatomic, strong) UITextView *descriptionText;
@property (nonatomic, strong) UIButton *projectNameButton;

@property (nonatomic, weak) UITextView *currentResponder;

@property (nonatomic, strong) UIButton *tasksButton;
@property (nonatomic, strong) UIButton *addStepsButton;
@property (nonatomic, strong) UILabel *addStepsLabel;
@property (nonatomic, strong) NSMutableArray *stepsArray;
@property (nonatomic, strong) THContactPickerView *assigneePickerView;
@property (nonatomic, strong) NSMutableArray *assignees;
//@property (nonatomic, strong) 
@end
CGFloat topCoordinate;
@implementation NewTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.stepsArray = [NSMutableArray array];
        
    }
    return self;
}

-(UIButton *)addStepsButton{
    if (!_addStepsButton) {
        _addStepsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_addStepsButton addTarget:self action:@selector(addStepView:) forControlEvents:UIControlEventTouchUpInside];
        [_addStepsButton setBackgroundImage:[UIImage imageNamed:@"addButton"] forState:UIControlStateNormal];
    }
    return _addStepsButton;
}

-(UILabel *)addStepsLabel{
    if (!_addStepsLabel) {
        _addStepsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_addStepsLabel setBackgroundColor:[UIColor clearColor]];
        [_addStepsLabel setText:@"Add Steps:"];
        [_addStepsLabel setFont:[UIFont systemFontOfSize:15.0]];
    }
    return _addStepsLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"New Task";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClick)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonClick)];
    [self.navigationItem setLeftBarButtonItem:closeButton];
    
    
    topCoordinate = 10;
    CGFloat left = 10;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, topCoordinate, CGRectGetWidth(self.view.frame), 0)];
    [nameLabel setText:@"Name:"];
    [nameLabel setFont:[UIFont systemFontOfSize:15.0]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel sizeToFit];
    [self.mainScrollView addSubview:nameLabel];
    topCoordinate = CGRectGetMaxY(nameLabel.frame) + kSupviewGap;
    
    [self.nameText setFrame:CGRectMake(left, topCoordinate, CGRectGetWidth(self.view.frame) - (left * 2), 70)];
    topCoordinate = CGRectGetMaxY(self.nameText.frame) + (kSupviewGap * 2);
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, topCoordinate, CGRectGetWidth(self.view.frame), 0)];
    [descriptionLabel setText:@"Description:"];
    [descriptionLabel setFont:[UIFont systemFontOfSize:15.0]];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel sizeToFit];
    [self.mainScrollView addSubview:descriptionLabel];
    topCoordinate = CGRectGetMaxY(descriptionLabel.frame) + kSupviewGap;
    
    [self.descriptionText setFrame:CGRectMake(left, topCoordinate, CGRectGetWidth(self.view.frame) - (left * 2), 70)];
    topCoordinate = CGRectGetMaxY(self.descriptionText.frame) + (kSupviewGap * 2);
    
    UILabel *assignee = [[UILabel alloc] initWithFrame:CGRectMake(left, topCoordinate, CGRectGetWidth(self.view.frame), 0)];
    [assignee setText:@"Assignee:"];
    [assignee setFont:[UIFont systemFontOfSize:15.0]];
    [assignee setBackgroundColor:[UIColor clearColor]];
    [assignee sizeToFit];
    [self.mainScrollView addSubview:assignee];
    topCoordinate = CGRectGetMaxY(assignee.frame) + kSupviewGap;
    
    self.assigneePickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(left, topCoordinate, self.view.frame.size.width - left*2, 100)];
    self.assigneePickerView.delegate = self;
    [self.assigneePickerView setPlaceholderString:@"Add Assignees"];
    [self.assigneePickerView.textView setTag:ASSIGNEE_TEXTVIEW_TAG];
    [self.assigneePickerView.textView setDelegate:self];
    [self.assigneePickerView.textView setReturnKeyType:UIReturnKeyDone];
    [self.mainScrollView addSubview:self.assigneePickerView];
    
    topCoordinate = CGRectGetMaxY(self.assigneePickerView.frame);
    
    [self.addStepsLabel setFrame:CGRectMake(left, topCoordinate + 40, 100, 20)];
    topCoordinate = CGRectGetMaxY(self.addStepsLabel.frame);
    
    [self.addStepsButton setFrame:CGRectMake(left, topCoordinate + 5, 30, 30)];
    
    [self.mainScrollView addSubview:self.addStepsLabel];
    [self.mainScrollView addSubview:self.addStepsButton];

    [self.nameText becomeFirstResponder];
}

#pragma mark THContactPickerDelegate

-(void)contactPickerDidRemoveContact:(id)contact forPicker:(THContactPickerView *)contactPickerView{
    [self.assignees removeObject:[contact pointerValue]];
}

-(void)contactPickerDidResize:(THContactPickerView *)contactPickerView{

}

-(void)contactPickerTextViewDidChange:(NSString *)textViewText{

}



#pragma mark Decleration

-(StepsView*)stepsView {
    StepsView *stepsView = [[StepsView alloc] initWithDelegate:self];
    [stepsView setFrame:CGRectMake(10, topCoordinate, CGRectGetWidth(self.view.frame) - 30, 0)];
    CGFloat height =  [stepsView readjustViews];
    [stepsView setFrame:CGRectMake(10, topCoordinate, CGRectGetWidth(self.view.frame) - 30, height)];
    [self.mainScrollView addSubview:stepsView];
    topCoordinate = CGRectGetMaxY(stepsView.frame) + kSupviewGap * 2;
    [self.mainScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.mainScrollView.frame), topCoordinate)];
    [self.stepsArray addObject:stepsView];
    return stepsView;
}

-(UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [_mainScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap:)];
        [_mainScrollView addGestureRecognizer:gesture];
        [self.view addSubview:_mainScrollView];
    }
    return _mainScrollView;
}

-(UITextView *)nameText {
    if (!_nameText) {
        _nameText = [[UITextView alloc] init];
        [_nameText setDelegate:self];
        [_nameText setBackgroundColor:[UIColor lightGrayColor]];
        [self.mainScrollView addSubview:_nameText];
    }
    return _nameText;
}

-(UITextView *)descriptionText {
    if (!_descriptionText) {
        _descriptionText = [[UITextView alloc] init];
        [_descriptionText setDelegate:self];
        [_descriptionText setBackgroundColor:[UIColor lightGrayColor]];
        [self.mainScrollView addSubview:_descriptionText];
    }
    return _descriptionText;
}

-(UIButton *)projectNameButton {
    if (!_projectNameButton) {
        _projectNameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.mainScrollView addSubview:_projectNameButton];
    }
    return _projectNameButton;
}


#pragma mark ButtonClicks 

-(void)addButtonClick:(id)selector{
    UserListPickerViewController *viewController = [[UserListPickerViewController alloc] init];
    viewController.delegate = self;
    UINavigationController *navig = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navig.navigationBar setTintColor:[UIColor grayColor]];
    [self.navigationController presentViewController:navig animated:YES completion:^{
        nil;
    }];
}

-(void) doneButtonClick {
    //create a task object
    BuiltClass *taskClass = [[AppDelegate sharedAppDelegate].builtApplication classWithUID:CLASSUID_TASKS];
    BuiltObject *task = [taskClass object];
    NSMutableArray *taskSteps;
    if (self.stepsArray.count > 0) {
        taskSteps = [NSMutableArray array];
        
        [self.stepsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *stepsDictionary = [NSMutableDictionary dictionary];
            StepsView *stepsView = [self.stepsArray objectAtIndex:idx];
            [stepsDictionary setObject:stepsView.nameTextView.text forKey:@"name"];
            [stepsDictionary setObject:stepsView.descriptionTextView.text forKey:@"description"];
            [stepsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"complete"];
            
            [taskSteps addObject:stepsDictionary];
        }];
    }
    [task setObject:taskSteps forKey:@"steps"];
    [task setObject:self.nameText.text forKey:@"name"];
    [task setObject:self.descriptionText.text forKey:@"description"];
    [task setReference:self.project.uid forKey:@"project"];
    
    [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
           [task setReference:[user uid] forKey:@"assignees"];
    }];
    
    BuiltACL *taskACL = [[AppDelegate sharedAppDelegate].builtApplication acl];
    
    //members have read access for a task
    [[self.project objectForKey:@"members"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [taskACL setRoleReadAccess:YES forRoleUID:obj];
    }];
    
    //moderators have read, update, delete access for a task
    [[self.project objectForKey:@"moderators"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [taskACL setRoleReadAccess:YES forRoleUID:obj];
        [taskACL setRoleWriteAccess:YES forRoleUID:obj];
        [taskACL setRoleDeleteAccess:YES forRoleUID:obj];
    }];
    
    [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
        [taskACL setWriteAccess:YES forUserId:user.uid];
        [taskACL setReadAccess:YES forUserId:user.uid];
    }];
    
    //set ACL for the task object
    [task setACL:taskACL];
    
    MBProgressHUD *creatingTaskHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [creatingTaskHUD setLabelText:@"Creating task..."];
    
    //save the task object
    
    [task saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
        if (error == nil) {
            [creatingTaskHUD setLabelText:@"Task Created!"];
            [creatingTaskHUD hide:YES afterDelay:0.5];
            [self performSelector:@selector(dismissAfterCreating) withObject:nil afterDelay:1.0];
        }else {
            [creatingTaskHUD setLabelText:@"Error Creating Task!"];
            [creatingTaskHUD hide:YES afterDelay:0.5];
        }
    }];
    
}

- (void)addStepView:(id)sender{
    CGFloat yPOS = CGRectGetMaxY(self.addStepsButton.frame);
    CGFloat width = self.view.frame.size.width;
    if (self.stepsArray.count < 1) {
        UILabel *stepCountlabel = [[UILabel alloc]initWithFrame:CGRectMake(2, yPOS + 10, 20, 20)];
        stepCountlabel.textAlignment = NSTextAlignmentCenter;
        stepCountlabel.backgroundColor = [UIColor redColor];
        stepCountlabel.text = [NSString stringWithFormat:@"%d",1];
        stepCountlabel.font = [UIFont boldSystemFontOfSize:15.0];
        stepCountlabel.layer.cornerRadius = 8.0;
        
        StepsView *stepsView = [[StepsView alloc]initWithFrame:CGRectMake(25, yPOS + 10, width - 25, 0)];
        stepsView.nameTextView.delegate = self;
        stepsView.descriptionTextView.delegate = self;
        stepsView.nameTextView.tag = [[NSString stringWithFormat:@"%d%d",STEP_NAME_TEXTVIEW_TAG,1] integerValue];
        stepsView.descriptionTextView.tag = [[NSString stringWithFormat:@"%d%d",STEP_DESCRIPTION_TEXTVIEW_TAG,1] integerValue];
        CGFloat height =  [stepsView readjustViews];
        [stepsView setFrame:CGRectMake(25, yPOS + 2, CGRectGetWidth(self.view.frame) - 50, height)];
        yPOS = CGRectGetMaxY(stepsView.frame) + 10;
        [self.mainScrollView addSubview:stepCountlabel];
        [self.mainScrollView addSubview:stepsView];
        [self.mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(stepsView.frame) + 5)];
        [self.stepsArray addObject:stepsView];
    }else{
        StepsView *prevStepView = [self.stepsArray lastObject];
        yPOS = CGRectGetMaxY(prevStepView.frame) + 10;
        
        UILabel *stepCountlabel = [[UILabel alloc]initWithFrame:CGRectMake(2, yPOS + 2, 20, 20)];
        stepCountlabel.textAlignment = NSTextAlignmentCenter;
        stepCountlabel.backgroundColor = [UIColor redColor];
        stepCountlabel.text = [NSString stringWithFormat:@"%d",self.stepsArray.count + 1];
        stepCountlabel.font = [UIFont boldSystemFontOfSize:15.0];
        stepCountlabel.layer.cornerRadius = 8.0;
        
        
        StepsView *stepsView = [[StepsView alloc]initWithFrame:CGRectMake(25, yPOS + 2, width - 25, 0)];
        stepsView.nameTextView.delegate = self;
        stepsView.descriptionTextView.delegate = self;
        stepsView.nameTextView.tag = [[NSString stringWithFormat:@"%d%d",STEP_NAME_TEXTVIEW_TAG,self.stepsArray.count + 1] integerValue];
        stepsView.descriptionTextView.tag = [[NSString stringWithFormat:@"%d%d",STEP_DESCRIPTION_TEXTVIEW_TAG,self.stepsArray.count + 1] integerValue];
        CGFloat height =  [stepsView readjustViews];
        [stepsView setFrame:CGRectMake(25, yPOS + 2, CGRectGetWidth(self.view.frame) - 50, height)];
        yPOS = CGRectGetMaxY(stepsView.frame) + 10;
        [self.mainScrollView addSubview:stepCountlabel];
        [self.mainScrollView addSubview:stepsView];
        [self.mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(stepsView.frame) + 5)];
        [self.stepsArray addObject:stepsView];
    }
}

- (void)dismissAfterCreating{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


-(void)cancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIGestureRecognizer 
-(void)handelTap:(UIGestureRecognizer*)recog {
    if (self.currentResponder) {
        [self.currentResponder resignFirstResponder];
    }
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag == ASSIGNEE_TEXTVIEW_TAG) {
        [self openUserList];
        [self.mainScrollView setContentOffset:CGPointMake(0, self.assigneePickerView.frame.origin.y - 44) animated:YES];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        } completion:^(BOOL finished) {
            if (self.currentResponder) {
                if (![textView.superview isEqual:self.view]) {
                    [UIView animateWithDuration:0.3 animations:^{
                        [self.mainScrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textView.superview.frame))];
                    }];
                }
            }
        }];
    }
    self.currentResponder = textView;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark StepsTaskButtonClick

-(void)taskButtonClick:(UIButton*)taskButton {
    self.tasksButton = taskButton;
    [self handelTap:nil];
}


#pragma mark UserListDelegate
-(void)selectedUserList:(NSArray *)usersArray {
    for (int i=0; i<usersArray.count; i++) {
        [self stepsView];
    }
}

#pragma mark UIGestureRecognizer
-(void)handleTap:(UIGestureRecognizer*)recog {
    if (self.currentResponder) {
        [self.currentResponder resignFirstResponder];
    }
    
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    }];
}

#pragma mark UserTableViewDelegate

-(void)didSelectUsers:(NSArray *)users{
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.assigneePickerView addContact:obj withName:[obj objectForKey:@"email"]];
        if (!self.assignees) {
            self.assignees = [NSMutableArray array];
        }
        [self.assignees addObject:obj];
    }];
}

//open up the users table to select users from
- (void)openUserList{
    UsersTableViewController *usersTable = [[UsersTableViewController alloc]initWithStyle:UITableViewStylePlain withBuiltClass:[[AppDelegate sharedAppDelegate].builtApplication classWithUID:@"built_io_application_user"]];
    [usersTable setDelegate:self];
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:usersTable];
    [nc.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
