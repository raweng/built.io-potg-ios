//
//  NewMilestoneViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "NewMilestoneViewController.h"
#import "DateViewController.h"
#import "MBProgressHUD.h"
#import "THContactPickerView.h"
#import "UsersTableViewController.h"

#define MODERATOR_TEXTVIEW_TAG 1
#define BUG_TITLE_TAG 2
#define BUG_DESCRIPTION_TAG 3
#define TH_CONTACT_PICKER_TEXTVIEW_TAG_IMAGE 4

#define CONTACT_PICKER 500
#define IMAGE_PICKER 501


@interface NewMilestoneViewController ()<DatePickerDelegate,UITextViewDelegate, THContactPickerDelegate, UserTableViewDelegate> {
    UITextView *currentTextView;
}
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) UILabel *assigneeLabel;
@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) NSMutableArray *assignees;
@end

@implementation NewMilestoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UILabel *)assigneeLabel{
    if (!_assigneeLabel) {
        _assigneeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_assigneeLabel setText:@"Assignee:"];
        [_assigneeLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_assigneeLabel setBackgroundColor:[UIColor clearColor]];
        [_assigneeLabel setTextColor:[UIColor blackColor]];
    }
    return _assigneeLabel;
}

-(THContactPickerView *)contactPickerView{
    if (!_contactPickerView) {
        _contactPickerView = [[THContactPickerView alloc]initWithFrame:CGRectZero];
        _contactPickerView.tag = CONTACT_PICKER;
        _contactPickerView.delegate = self;
        _contactPickerView.textView.delegate = self;
        [_contactPickerView setPlaceholderString:@"Add Moderators"];
        _contactPickerView.textView.tag = MODERATOR_TEXTVIEW_TAG;
        [_contactPickerView setBackgroundColor:[UIColor lightGrayColor]];
        
    }
    return _contactPickerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.title = @"New Milestone";
    
    self.startDate = nil;
    self.endDate = nil;
    
    [self prepareViews];
    
    [self.milestoneName becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSelf)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(newMileStone)];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareViews{
    CGFloat yPOS = 0.0;
    yPOS = CGRectGetMaxY(self.startTimeLabel.frame) + 10;
    
    [self.assigneeLabel setFrame:CGRectMake(20, yPOS, 0, 18)];
    [self.assigneeLabel sizeToFit];
    [self.mainScrollView addSubview:self.assigneeLabel];
    
    yPOS = CGRectGetMaxY(self.assigneeLabel.frame) + 2;
    [self addContactsView:yPOS];
}

- (void)addContactsView:(CGFloat)yPOS{    
    [self.contactPickerView setFrame:CGRectMake(20, yPOS, self.view.frame.size.width - 40, 150)];
    [self.mainScrollView addSubview:self.contactPickerView];
    [self.mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.contactPickerView.frame) + 25)];
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newMileStone{
    if (self.startDate != nil && self.endDate != nil) {
        
        //create a milestone object
        BuiltObject *milestone = [BuiltObject objectWithClassUID:CLASSUID_MILESTONES];
        [milestone setObject:self.milestoneName.text forKey:@"name"];
        [milestone setObject:self.descriptionText.text forKey:@"description"];
        [milestone setObject:self.startDate forKey:@"start_date"];
        [milestone setObject:self.endDate forKey:@"end_date"];
        [milestone setReference:self.project.uid forKey:@"project"];
        
        if (self.assignees.count > 0) {
            NSMutableArray *useridsArray = [NSMutableArray array];
            [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BuiltObject *user = (BuiltObject *)obj;
                [useridsArray addObject:[user uid]];
            }];
            //add user uids to assignees reference field
            [milestone setReference:useridsArray forKey:@"assignees"];
        }
        
        
        BuiltACL *milestoneACL = [BuiltACL ACL];
        
        //members have read access for a milestone
        [[self.project objectForKey:@"members"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [milestoneACL setRoleReadAccess:YES forRoleUID:obj];
        }];
        
        //moderators have read, update, delete access for a milestone
        [[self.project objectForKey:@"moderators"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [milestoneACL setRoleReadAccess:YES forRoleUID:obj];
            [milestoneACL setRoleWriteAccess:YES forRoleUID:obj];
            [milestoneACL setRoleDeleteAccess:YES forRoleUID:obj];
        }];
        
        //set ACL to the object
        [milestone setACL:milestoneACL];
        
        MBProgressHUD *creatingMilestoneHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [creatingMilestoneHUD setLabelText:@"Creating Milestone..."];
        
        //save milestone object
        [milestone saveOnSuccess:^{
            [creatingMilestoneHUD setLabelText:@"Milestone Created!"];
            [creatingMilestoneHUD hide:YES afterDelay:0.5];
            [self dismissViewControllerAnimated:YES completion:nil];
        } onError:^(NSError *error) {
            [creatingMilestoneHUD setLabelText:@"Error Creating Milestone!"];
            [creatingMilestoneHUD hide:YES afterDelay:0.5];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)showStartTimePicker:(id)sender {
    DateViewController *dateViewController = [[DateViewController alloc]init];
    dateViewController.datePickerDelegate = self;
    [dateViewController setDate:START_DATE];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:dateViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction)showEndTimePicker:(id)sender {
    DateViewController *dateViewController = [[DateViewController alloc]init];
    dateViewController.datePickerDelegate = self;
    [dateViewController setDate:END_DATE];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:dateViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

-(void)startDateSelected:(NSDate *)date{
    self.startDate = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
    NSString *selDate = [NSString stringWithFormat:@"%@",
                         [df stringFromDate:date]];
    self.startTimeLabel.text = selDate;
}

-(void)endDateSelected:(NSDate *)date{
    self.endDate = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
    NSString *selDate = [NSString stringWithFormat:@"%@",
                         [df stringFromDate:date]];
    self.endTimeLabel.text = selDate;
}

#pragma mark UITextViewDelegate 
-(void)textViewDidBeginEditing:(UITextView *)textView {
    currentTextView = textView;
    if (textView.tag == MODERATOR_TEXTVIEW_TAG) {
        [self openUserList];
        [self.mainScrollView setContentOffset:CGPointMake(0, self.contactPickerView.frame.origin.y - 44) animated:YES];
    }
}

#pragma mark
//open up the users table to select users from
- (void)openUserList{
    UsersTableViewController *usersTable = [[UsersTableViewController alloc]initWithStyle:UITableViewStylePlain withClassUID:@"built_io_application_user"];
    usersTable.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:usersTable];
    [nc.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

#pragma mark KeyBoard NotificationHandler
-(void)keyboardShow:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainScrollView.frame), CGRectGetHeight(self.view.frame) - kKeyBoardShowHeight)];
    }];
    
}

-(void)keyboardHide:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainScrollView.frame), CGRectGetHeight(self.view.frame))];
    }];

}

#pragma mark UITapGestureSelector

- (IBAction)hadleTap:(id)sender {
    [currentTextView resignFirstResponder];
    
}

#pragma mark - THContactPickerDelegate
- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    
}

- (void)contactPickerDidRemoveContact:(id)contact {
    
}

-(void)contactPickerDidRemoveContact:(id)contact forPicker:(THContactPickerView *)contactPickerView{
    if (contactPickerView.tag == CONTACT_PICKER) {
        [self.assignees removeObject:[contact pointerValue]];
    }
}

#pragma mark - UserTableViewDelegate
-(void)didSelectUsers:(NSArray *)users{
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.contactPickerView addContact:obj withName:[obj objectForKey:@"email"]];
        if (!self.assignees) {
            self.assignees = [NSMutableArray array];
        }
        [self.assignees addObject:obj];
    }];
}
@end
