//
//  EditBugDetailsController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "EditBugDetailsController.h"
#import "UserListPickerViewController.h"
#import "MBProgressHUD.h"
#import "THContactPickerView.h"
#import "UsersTableViewController.h"
#import "AppUtils.h"
#import "NSDate+Addition.h"
#import "AppDelegate.h"

#define ASSIGNEE_TEXTVIEW 999
#define ASSIGNEE_PICKER 500

@interface EditBugDetailsController ()<UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UserListDelegate, THContactPickerDelegate, UITextViewDelegate,UserTableViewDelegate>
@property (nonatomic, strong)UITextView *currentResponder;
@property (nonatomic, strong) THContactPickerView *assigneePickerView;
@property (nonatomic, strong)UIPickerView *pickerView;
@property (nonatomic, strong)UIDatePicker *datePicker;
@property (nonatomic, strong)NSArray *statuses;
@property (nonatomic, strong)NSArray *severity;
@property (nonatomic, strong)NSArray *milestones;
@property (nonatomic, strong)NSArray *reproducible;
@property (nonatomic, strong)NSMutableArray *datasource;
@property (nonatomic, strong)UIActionSheet *actionSheet;
@property (nonatomic, strong)UIToolbar *pickerDateToolbar;
@property (nonatomic, assign)NSInteger selectedIndex;
@property (nonatomic, strong)NSString *selectedItem;

@property (nonatomic, strong) NSMutableArray *assignees;

@property (nonatomic, strong)NSDate *bugDate;
@property (nonatomic, strong)NSString *severityLevel;
@property (nonatomic, strong)NSString *statusLevel;
@property (nonatomic, strong)NSString *isReproducible;

@property (nonatomic, strong)UIScrollView *scrollView;
@end
@interface EditBugDetailsController(){
    MBProgressHUD *creatingBugHUD;
}

@end
@implementation EditBugDetailsController
@synthesize bugDetails;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewGesture:)];
        [_scrollView addGestureRecognizer:gesture];
    }
    return _scrollView;
}

-(THContactPickerView *)assigneePickerView{
    if (!_assigneePickerView) {
        _assigneePickerView = [[THContactPickerView alloc]initWithFrame:CGRectZero];
        _assigneePickerView.tag = ASSIGNEE_PICKER;
        _assigneePickerView.delegate = self;
        _assigneePickerView.textView.delegate = self;
        [_assigneePickerView setPlaceholderString:@"Add Moderators"];
        _assigneePickerView.textView.tag = ASSIGNEE_TEXTVIEW;
        [_assigneePickerView setBackgroundColor:[UIColor lightGrayColor]];
        
    }
    return _assigneePickerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    self.bugTitleLabel.text = [NSString stringWithFormat:@"    %@",[self.project objectForKey:@"name"]];
    
    self.datasource = [NSMutableArray array];
    self.selectedIndex = 0;
    self.statuses = [NSArray arrayWithObjects:@"Open",@"In Progress",@"Closed",@"To Be Tested", nil];
    self.severity = [NSArray arrayWithObjects:@"Show Stopper",@"Critical",@"Major",@"Minor", nil];
    self.reproducible = [NSArray arrayWithObjects:@"Always",@"Sometimes",@"Rarely",@"Unable", nil];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"How many?"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker addTarget:self
                        action:@selector(changeDateInLabel:)
              forControlEvents:UIControlEventValueChanged];
    
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];

    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.delegate = self;
    
    self.pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
    [self.pickerDateToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DatePickerDoneClick)];
    [barItems addObject:doneBtn];
    
    [self.pickerDateToolbar setItems:barItems animated:YES];
}

- (void)prepareViews{
    [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.assigneePickerView setFrame:CGRectMake(20, CGRectGetMaxY(self.assigneeLabel.frame) + 5, self.view.frame.size.width - 40, 200)];
    
    [self.scrollView addSubview:self.bugTitleLabel];
    [self.scrollView addSubview:self.dividerView];
    [self.scrollView addSubview:self.statusLabel];
    [self.scrollView addSubview:self.statusButton];
    [self.scrollView addSubview:self.severityLabel];
    [self.scrollView addSubview:self.severityButton];
    [self.scrollView addSubview:self.reproducibleLabel];
    [self.scrollView addSubview:self.reprodubleButton];
    [self.scrollView addSubview:self.dueDateLabel];
    [self.scrollView addSubview:self.dueDateAction];
    [self.scrollView addSubview:self.assigneeLabel];
    [self.scrollView addSubview:self.assigneePickerView];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.assigneePickerView.frame) + 50)];
    [self.view addSubview:self.scrollView];
}

- (void)loadData{
    
    NSDate *date = [AppUtils convertGMTtoLocal:[self.project objectForKey:@"due_date"]];
    self.bugDate = date;
    NSString *dateString = [NSString stringWithFormat:@"%@ %@, %@",[date formatMonth],[date formatDay],[date formatYear]];
    
    [self.statusButton setTitle:[self.project objectForKey:@"status"] forState:UIControlStateNormal];
    [self.severityButton setTitle:[self.project objectForKey:@"severity"] forState:UIControlStateNormal];
    [self.dueDateAction setTitle:dateString forState:UIControlStateNormal];
    [self.reprodubleButton setTitle:[self.project objectForKey:@"reproducible"] forState:UIControlStateNormal];
    
    if (!self.assignees) {
        self.assignees = [NSMutableArray array];
    }
    NSMutableArray *assigneeArray =  [self.project objectForKey:@"assignees"];

    if (assigneeArray.count > 0) {
    if (!self.assignees) {
        self.assignees = [NSMutableArray array];
    }else{
        [self.assignees removeAllObjects];
    }
    [assigneeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *assigneeDictionary = (NSMutableDictionary *)obj;
        [self.assignees addObject:assigneeDictionary];
    }];
    
    if (self.assignees.count > 0) {
        [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.assigneePickerView addContact:obj withName:[obj objectForKey:@"email"]];
        }];
    }
}
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSelf)];
    [self.assigneePickerView.textView resignFirstResponder];
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)save{
    creatingBugHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [creatingBugHUD setLabelText:@"Updating Bug Details..."];

    BuiltObject *object = self.project;
    
    NSMutableArray *useridsArray = [NSMutableArray array];
    
    [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
        [useridsArray addObject:[user objectForKey:@"uid"]];
    }];

    //set all the user ids to assignees field
    [object setReference:useridsArray forKey:@"assignees"];
    [object setObject:self.statusButton.titleLabel.text forKey:@"status"];
    [object setObject:self.severityButton.titleLabel.text forKey:@"severity"];
    [object setObject:self.reprodubleButton.titleLabel.text forKey:@"reproducible"];
    [object setObject:self.bugDate forKey:@"due_date"];
    
    [object saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
        if (error == nil) {
            [creatingBugHUD setLabelText:@"Bug Updated Successfully!"];
            [creatingBugHUD hide:YES afterDelay:0.5];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            [creatingBugHUD setLabelText:@"Error Updating Bug!"];
            [creatingBugHUD hide:YES afterDelay:0.5];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)dueDateButton:(id)sender {
    [self setBugDetails:DUE_DATE];
    
    if ([[self.actionSheet subviews]containsObject:self.datePicker] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.reproducible];
    
    //    [self.datePicker reloadAllComponents];
    
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.datePicker];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
}

- (IBAction)statusAction:(id)sender {

    [self setBugDetails:STATUS];
    if ([[self.actionSheet subviews]containsObject:self.pickerView] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
    }
    
    
    if ([[self.actionSheet subviews] containsObject:self.pickerView]) {
        [self.pickerView removeFromSuperview];
    }
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.statuses];
    
    [self.pickerView reloadAllComponents];
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.pickerView];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
}

- (IBAction)severityAction:(id)sender {
    [self setBugDetails:SEVERITY];
    if ([[self.actionSheet subviews]containsObject:self.pickerView] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }
    
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.severity];
    
    [self.pickerView reloadAllComponents];
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.pickerView];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
}

- (IBAction)reproducibleAction:(id)sender {
    [self setBugDetails:REPRODUCIBLE];
    if ([[self.actionSheet subviews]containsObject:self.pickerView] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.reproducible];
    
    [self.pickerView reloadAllComponents];
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.pickerView];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
}

- (void)DatePickerDoneClick{
    if (self.bugDetails == SEVERITY) {
        [self.severityButton setTitle:[self.severity objectAtIndex:self.selectedIndex] forState:UIControlStateNormal];
    }else if (self.bugDetails == STATUS){
        [self.statusButton setTitle:[self.statuses objectAtIndex:self.selectedIndex] forState:UIControlStateNormal];
    }else if (self.bugDetails == REPRODUCIBLE){
        [self.reprodubleButton setTitle:[self.reproducible objectAtIndex:self.selectedIndex]  forState:UIControlStateNormal];
    }else if (self.bugDetails == DUE_DATE){
        [self.dueDateAction setTitle:self.selectedItem forState:UIControlStateNormal];
    }
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)changeDateInLabel:(id)sender{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	NSString *selDate = [NSString stringWithFormat:@"%@",
                         [df stringFromDate:self.datePicker.date]];
    self.bugDate = self.datePicker.date;
    self.selectedItem = selDate;
}

#pragma mark - UITapGestureRecognizer
-(void)scrollViewGesture:(id)sender{
    if (self.currentResponder) {
        [self.currentResponder resignFirstResponder];
    }
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedIndex = row;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.datasource.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.datasource objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 300;
}

#pragma mark - UserTableViewDelegate
-(void)didSelectUsers:(NSArray *)users{
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *object = (BuiltObject *)obj;
        [self.assigneePickerView addContact:obj withName:[obj objectForKey:@"email"]];
        if (!self.assignees) {
            self.assignees = [NSMutableArray array];
        }
        [self.assignees addObject:object];
    }];
}

#pragma mark Button Click
-(void)addButtonClick:(id)selector{
    UserListPickerViewController *viewController = [[UserListPickerViewController alloc] init];
    viewController.delegate = self;
    viewController.singleUser = YES;
    UINavigationController *navig = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navig.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navig animated:YES completion:^{
        nil;
    }];
}

#pragma mark UserListDelegaet

-(void)selectedUserList:(NSArray *)usersArray {
    //nothing to do here
}

#pragma mark - THContactPickerDelegate
- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    
}

- (void)contactPickerDidRemoveContact:(id)contact {
    
}

-(void)contactPickerDidRemoveContact:(id)contact forPicker:(THContactPickerView *)contactPickerView{
    if (contactPickerView.tag == ASSIGNEE_PICKER) {
        [self.assignees removeObject:[contact pointerValue]];
    }
    
}

#pragma mark UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    self.currentResponder = textView;
    if (textView.tag == ASSIGNEE_TEXTVIEW) {
        [self performSelector:@selector(openUserList) withObject:nil afterDelay:1.0];
        [self.scrollView setContentOffset:CGPointMake(0, self.assigneePickerView.frame.origin.y - 44) animated:YES];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark
//open up the users table to select users from
- (void)openUserList{
    UsersTableViewController *usersTable = [[UsersTableViewController alloc]initWithStyle:UITableViewStylePlain withBuiltClass:[[AppDelegate sharedAppDelegate].builtApplication classWithUID:@"built_io_application_user"]];
    [usersTable setTitle:@"Add Assignees"];
    usersTable.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:usersTable];
    [nc.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

@end
