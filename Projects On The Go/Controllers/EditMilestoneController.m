//
//  EditMilestoneController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 08/07/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "EditMilestoneController.h"
#import "AppUtils.h"
#import "NSDate+Addition.h"
#import "THContactPickerView.h"
#import "UsersTableViewController.h"
#import "MBProgressHUD.h"

#define ASSIGNEE_PICKER_TEXTVIEW 1
#define DESCRIPTION_TEXTVIEW 1

@interface EditMilestoneController ()<UITextViewDelegate, THContactPickerDelegate, UserTableViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *bugTitle;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UIButton *deleteMilestoneButton;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UITextView *descriptionArea;
@property (nonatomic, strong) UILabel *startDateLabel;
@property (nonatomic, strong) UILabel *startDateValueLabel;
@property (nonatomic, strong) UILabel *endDateLabel;
@property (nonatomic, strong) UILabel *endDateValueLabel;
@property (nonatomic, strong) UILabel *assigneeLabel;
@property (nonatomic, strong) THContactPickerView *assigneePicker;
@property (nonatomic, strong) NSMutableArray *assignees;
@property (nonatomic, strong) UITextView *currentResponder;
@end

@implementation EditMilestoneController

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

-(UILabel *)bugTitle{
    if (!_bugTitle) {
        _bugTitle = [[UILabel alloc]initWithFrame:CGRectZero];
        [_bugTitle setFont:[UIFont systemFontOfSize:17.0]];
        [_bugTitle setBackgroundColor:[UIColor grayColor]];
    }
    return _bugTitle;
}

-(UIView *)dividerView{
    if (!_dividerView) {
        _dividerView = [[UIView alloc]initWithFrame:CGRectZero];
        [_dividerView setBackgroundColor:[UIColor grayColor]];
    }
    return _dividerView;
}

-(UIButton *)deleteMilestoneButton{
    if (!_deleteMilestoneButton) {
        _deleteMilestoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_deleteMilestoneButton setTitle:@"Delete" forState:UIControlStateNormal];
        UIImage *buttonBckg = [[UIImage imageNamed:@"spin"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        [_deleteMilestoneButton setBackgroundImage:buttonBckg forState:UIControlStateNormal];
        [_deleteMilestoneButton addTarget:self action:@selector(deleteMilestone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteMilestoneButton;
}

-(UILabel *)descriptionLabel{
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_descriptionLabel setText:@"Description:"];
        [_descriptionLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [_descriptionLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _descriptionLabel;
}

-(UITextView *)descriptionArea{
    if (!_descriptionArea) {
        _descriptionArea = [[UITextView alloc]initWithFrame:CGRectZero];
        [_descriptionArea setBackgroundColor:[UIColor lightGrayColor]];
        [_descriptionArea setFont:[UIFont systemFontOfSize:15.0]];
        _descriptionArea.tag = DESCRIPTION_TEXTVIEW;
        _descriptionArea.delegate = self;
    }
    return _descriptionArea;
}

-(UILabel *)startDateLabel{
    if (!_startDateLabel) {
        _startDateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_startDateLabel setText:@"Start Date:"];
        [_startDateLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_startDateLabel setBackgroundColor:[UIColor clearColor]];
        [_startDateLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _startDateLabel;
}

-(UILabel *)startDateValueLabel{
    if (!_startDateValueLabel) {
        _startDateValueLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_startDateValueLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
        [_startDateValueLabel setBackgroundColor:[UIColor clearColor]];
        [_startDateValueLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _startDateValueLabel;
}

-(UILabel *)endDateLabel{
    if (!_endDateLabel) {
        _endDateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_endDateLabel setText:@"End Date:"];
        [_endDateLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_endDateLabel setBackgroundColor:[UIColor clearColor]];
        [_endDateLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _endDateLabel;
}

-(UILabel *)endDateValueLabel{
    if (!_endDateValueLabel) {
        _endDateValueLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_endDateValueLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
        [_endDateValueLabel setBackgroundColor:[UIColor clearColor]];
        [_endDateValueLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _endDateValueLabel;
}

-(UILabel *)assigneeLabel{
    if (!_assigneeLabel) {
        _assigneeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_assigneeLabel setText:@"Assignees:"];
        [_assigneeLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_assigneeLabel setBackgroundColor:[UIColor clearColor]];
        [_assigneeLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _assigneeLabel;
}

-(THContactPickerView *)assigneePicker{
    if (!_assigneePicker) {
        _assigneePicker = [[THContactPickerView alloc]initWithFrame:CGRectZero];
        _assigneePicker.delegate = self;
        _assigneePicker.textView.delegate = self;
        [_assigneePicker setPlaceholderString:@"Add Assignees"];
        _assigneePicker.textView.tag = ASSIGNEE_PICKER_TEXTVIEW;
        [_assigneePicker.textView setReturnKeyType:UIReturnKeyDone];
        [_assigneePicker setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _assigneePicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    
    [self prepareViews];

    [self.assigneePicker.textView resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.descriptionArea becomeFirstResponder];
    [self.assigneePicker.textView resignFirstResponder];
}

- (void)prepareViews{
    CGFloat yPOS = 0;
    CGFloat width = self.view.frame.size.width;
    
    [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.bugTitle setFrame:CGRectMake(0, 0, width, 30)];
    yPOS = CGRectGetMaxY(self.bugTitle.frame) + 10;
    
    [self.dividerView setFrame:CGRectMake(0, yPOS - 8, width, 2)];
    yPOS = CGRectGetMaxY(self.dividerView.frame) + 10;
    
    if (self.canDeleteMilestone) {
        [self.deleteMilestoneButton setFrame:CGRectMake(10, yPOS + 25, 100, 40)];
        yPOS = CGRectGetMaxY(self.deleteMilestoneButton.frame) + 10;
    }
    
    [self.descriptionLabel setFrame:CGRectMake(20, yPOS + 20, width - 40, 20)];
    yPOS = CGRectGetMaxY(self.descriptionLabel.frame) + 10;
    
    NSString *content = [self.milestone objectForKey:@"description"];
    CGSize actualSize = [content sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(300, width - 20)lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = actualSize.height + 15;
    
    [self.descriptionArea setFrame:CGRectMake(10, yPOS + 2, width - 20, height)];
    yPOS = CGRectGetMaxY(self.descriptionArea.frame) + 10;
    
    [self.startDateLabel setFrame:CGRectMake(20, yPOS, width - 40, 20)];
    yPOS = CGRectGetMaxY(self.startDateLabel.frame) + 10;
    
    [self.startDateValueLabel setFrame:CGRectMake(40, yPOS + 2, width - 80, 20)];
    yPOS = CGRectGetMaxY(self.startDateValueLabel.frame) + 10;
    
    [self.endDateLabel setFrame:CGRectMake(20, yPOS, width - 40, 20)];
    yPOS = CGRectGetMaxY(self.endDateLabel.frame) + 10;
    
    [self.endDateValueLabel setFrame:CGRectMake(40, yPOS + 2, width - 80, 20)];
    yPOS = CGRectGetMaxY(self.endDateValueLabel.frame) + 10;
    
    [self.assigneeLabel setFrame:CGRectMake(20, yPOS, width - 40, 20)];
    yPOS = CGRectGetMaxY(self.assigneeLabel.frame) + 10;
    
    [self.assigneePicker setFrame:CGRectMake(10, yPOS + 2, width - 20, 150)];
    yPOS = CGRectGetMaxY(self.assigneePicker.frame) + 10;
    
    [self.scrollView addSubview:self.bugTitle];
    [self.scrollView addSubview:self.dividerView];
    [self.scrollView addSubview:self.deleteMilestoneButton];
    [self.scrollView addSubview:self.descriptionLabel];
    [self.scrollView addSubview:self.descriptionArea];
    [self.scrollView addSubview:self.startDateLabel];
    [self.scrollView addSubview:self.startDateValueLabel];
    [self.scrollView addSubview:self.endDateLabel];
    [self.scrollView addSubview:self.endDateValueLabel];
    [self.scrollView addSubview:self.assigneeLabel];
    [self.scrollView addSubview:self.assigneePicker];
    [self.scrollView setContentSize:CGSizeMake(width, yPOS + 50)];
    [self.view addSubview:self.scrollView];
}

- (void)loadData{
    [self.bugTitle setText:[NSString stringWithFormat:@"    %@",[self.milestone objectForKey:@"name"]]];
    [self.descriptionArea setText:[NSString stringWithFormat:@"%@",[self.milestone objectForKey:@"description"]]];
    NSDate *startDate = [AppUtils convertGMTtoLocal:[self.milestone objectForKey:@"start_date"]];
    NSDate *endDate = [AppUtils convertGMTtoLocal:[self.milestone objectForKey:@"end_date"]];
    self.startDateValueLabel.text = [startDate formatDate];
    self.endDateValueLabel.text = [endDate formatDate];
    
    NSMutableArray *assigneeArray =  [self.milestone objectForKey:@"assignees"];
    if (assigneeArray.count > 0) {
        if (!self.assignees) {
            self.assignees = [NSMutableArray array];
        }else{
            [self.assignees removeAllObjects];
        }
        [assigneeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *assigneeDictionary = (NSMutableDictionary *)obj;
            [self.assignees addObject:[assigneeDictionary objectForKey:@"email"]];
        }];
        
        if (self.assignees.count > 0) {
            [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.assigneePicker addContact:obj withName:obj];
            }];
        }
    }
    
}

- (void)deleteMilestone:(id)sender{
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.dimBackground = YES;
    [progressHUD setLabelText:@"Deleting..."];
    [self.milestone destroyOnSuccess:^{
        [progressHUD setLabelText:@"Milestone Deleted!"];
        [progressHUD hide:YES afterDelay:2.0];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.0];
    } onError:^(NSError *error) {
        [progressHUD setLabelText:@"Deletion Failed!"];
        [progressHUD hide:YES afterDelay:2.0];
    }];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewGesture:(UITapGestureRecognizer *)recognizer{
    if (self.currentResponder) {
        [self.currentResponder resignFirstResponder];
    }
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.currentResponder = textView;
    
    if (textView.tag == ASSIGNEE_PICKER_TEXTVIEW) {
        [self openUserList];
        [self.scrollView setContentOffset:CGPointMake(0, self.assigneePicker.frame.origin.y - 40) animated:YES];
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

#pragma  mark - THContactPickerDelegate
- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    
}

- (void)contactPickerDidRemoveContact:(id)contact {
    
}

-(void)contactPickerDidRemoveContact:(id)contact forPicker:(THContactPickerView *)contactPickerView{
    [self.assignees removeObject:[contact pointerValue]];    
}

#pragma mark - UserTableViewDelegate
-(void)didSelectUsers:(NSArray *)users{
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.assigneePicker addContact:obj withName:[obj objectForKey:@"email"]];
        if (!self.assignees) {
            self.assignees = [NSMutableArray array];
        }
        [self.assignees addObject:obj];
    }];
}

@end
