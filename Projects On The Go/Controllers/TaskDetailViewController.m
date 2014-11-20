//
//  TaskDetailViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 29/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "StepsView.h"
#import "MBProgressHUD.h"

#define DESCRIPTION_AREA 1

@interface TaskDetailViewController ()<UITextViewDelegate, UIAlertViewDelegate>{
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UILabel *taskTitle;
@property (nonatomic, strong) UILabel *taskDescription;
@property (nonatomic, strong) UITextView *taskDescriptionArea;
@property (nonatomic, weak) UITextView *currentResponder;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UILabel *stepsViewLabel;
@property (nonatomic, strong) UIButton *deleteTask;
@property (nonatomic, strong) StepsView *stepsView;
@property (nonatomic, strong) NSMutableArray *stepsObjectsArray;
@end

@implementation TaskDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonSystemItemDone target:self action:@selector(dismissController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(editTaskAction)];
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_mainScrollView addGestureRecognizer:gesture];
    }
    return _mainScrollView;
}

-(UILabel *)taskTitle{
    if (!_taskTitle) {
        _taskTitle = [[UILabel alloc]initWithFrame:CGRectZero];
        [_taskTitle setText:@"Task Title"];
        [_taskTitle setFont:[UIFont systemFontOfSize:17.0]];
        [_taskTitle setBackgroundColor:[UIColor grayColor]];
    }
    return _taskTitle;
}

-(UIView *)dividerView{
    if (!_dividerView) {
        _dividerView = [[UIView alloc]initWithFrame:CGRectZero];
        [_dividerView setBackgroundColor:[UIColor grayColor]];
    }
    return _dividerView;
}

-(UIButton *)deleteTask{
    if (!_deleteTask) {
        _deleteTask = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_deleteTask setTitle:@"Delete" forState:UIControlStateNormal];
        UIImage *buttonBckg = [[UIImage imageNamed:@"spin"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        [_deleteTask setBackgroundImage:buttonBckg forState:UIControlStateNormal];
        [_deleteTask addTarget:self action:@selector(deleteTaskAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteTask;
}

-(UILabel *)taskDescription{
    if (!_taskDescription) {
        _taskDescription = [[UILabel alloc]initWithFrame:CGRectZero];
        [_taskDescription setText:@"Description:"];
        [_taskDescription setFont:[UIFont systemFontOfSize:17.0]];
        [_taskDescription setBackgroundColor:[UIColor clearColor]];
        [_taskDescription setTextColor:[UIColor darkGrayColor]];
    }
    return _taskDescription;
}

-(UITextView *)taskDescriptionArea{
    if (!_taskDescriptionArea) {
        _taskDescriptionArea = [[UITextView alloc]initWithFrame:CGRectZero];
        [_taskDescriptionArea setBackgroundColor:[UIColor lightGrayColor]];
        _taskDescriptionArea.delegate = self;
    }
    return _taskDescriptionArea;
}

-(UILabel *)stepsViewLabel{
    if (!_stepsViewLabel) {
        _stepsViewLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_stepsViewLabel setText:@"Steps:"];
        [_stepsViewLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_stepsViewLabel setBackgroundColor:[UIColor clearColor]];
        [_stepsViewLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _stepsViewLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Task Details";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    
    [self prepareViews];
}

- (void)editTaskAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteTaskAction:(id)sender{
    UIAlertView *deleteAlert = [[UIAlertView alloc]initWithTitle:@"Delete Task" message:@"Are you sure you want to delete the task?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [deleteAlert show];
}

-(void)dismissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareViews{
    __block CGFloat yPOS = 0.0;
    CGFloat width = self.view.frame.size.width;
    
    [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.taskTitle setFrame:CGRectMake(0, 0, self.mainScrollView.frame.size.width, 30)];
    yPOS = CGRectGetMaxY(self.taskTitle.frame) + 10;
    
    [self.dividerView setFrame:CGRectMake(0, yPOS - 8, width, 2)];
    yPOS = CGRectGetMaxY(self.dividerView.frame) + 10;

    if (self.canDeleteTask) {
        [self.deleteTask setFrame:CGRectMake(10, yPOS + 25, 100, 40)];
        yPOS = CGRectGetMaxY(self.deleteTask.frame) + 10;
    }
    
    [self.taskDescription setFrame:CGRectMake(10, yPOS + 10, width - 20, 20)];
    yPOS = CGRectGetMaxY(self.taskDescription.frame) + 10;
    
    [self.taskDescriptionArea setFrame:CGRectMake(10, yPOS + 2, width - 20, 150)];
    yPOS = CGRectGetMaxY(self.taskDescriptionArea.frame) + 10;
    
    
    self.stepsObjectsArray = [NSMutableArray array];
    [self.stepsObjectsArray removeAllObjects];
    self.stepsObjectsArray = [self.taskObject objectForKey:@"steps"];
    if (self.stepsObjectsArray.count > 0) {
        [self.stepsViewLabel setFrame:CGRectMake(10, yPOS + 10, width - 20, 20)];
        yPOS = CGRectGetMaxY(self.stepsViewLabel.frame) + 10;
        [self.mainScrollView addSubview:self.stepsViewLabel];
        NSMutableArray *stepViewArray = [NSMutableArray array];
        [self.stepsObjectsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILabel *stepCountlabel = [[UILabel alloc]initWithFrame:CGRectMake(2, yPOS + 2, 20, 20)];
            stepCountlabel.textAlignment = NSTextAlignmentCenter;
            stepCountlabel.backgroundColor = [UIColor redColor];
            stepCountlabel.text = [NSString stringWithFormat:@"%d",(idx + 1)];
            stepCountlabel.font = [UIFont boldSystemFontOfSize:15.0];
            stepCountlabel.layer.cornerRadius = 8.0;
            StepsView *stepsView = [[StepsView alloc]initWithFrame:CGRectMake(25, yPOS + 2, width - 25, 0)];
            CGFloat height =  [stepsView readjustViews];
            [stepsView setFrame:CGRectMake(25, yPOS + 2, CGRectGetWidth(self.view.frame) - 50, height)];
            yPOS = CGRectGetMaxY(stepsView.frame) + 10;
            [self.mainScrollView addSubview:stepCountlabel];
            [self.mainScrollView addSubview:stepsView];
            [stepViewArray addObject:stepsView];
        }];
        
        [self loadStepsData:stepViewArray];
    }else{
        [self.stepsViewLabel setFrame:CGRectMake(10, yPOS + 10, width - 20, 20)];
        yPOS = CGRectGetMaxY(self.stepsViewLabel.frame) + 10;
        [self.mainScrollView addSubview:self.stepsViewLabel];
    }
    
    [self.mainScrollView addSubview:self.taskTitle];
    [self.mainScrollView addSubview:self.dividerView];
    [self.mainScrollView addSubview:self.deleteTask];
    [self.mainScrollView addSubview:self.taskDescription];
    [self.mainScrollView addSubview:self.taskDescriptionArea];
    
    [self.mainScrollView setContentSize:CGSizeMake(width, yPOS + 50)];
    [self.view addSubview:self.mainScrollView];
}

-(void)loadTaskDetails{
    self.taskTitle.text = [NSString stringWithFormat:@"    %@",[self.taskObject objectForKey:@"name"]];
    self.taskDescriptionArea.text = [self.taskObject objectForKey:@"description"];

    NSMutableArray *steps = [self.taskObject objectForKey:@"steps"];
    
    if ([steps count] < 1) {
        [self.stepsViewLabel removeFromSuperview];
        [self.stepsView removeFromSuperview];
    }
}

- (void)loadStepsData:(NSMutableArray *)steps{
    [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StepsView *stepsView = (StepsView *)obj;
        stepsView.nameTextView.text = [[self.stepsObjectsArray objectAtIndex:idx] objectForKey:@"name"];
        stepsView.descriptionTextView.text = [[self.stepsObjectsArray objectAtIndex:idx] objectForKey:@"description"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIGestureRecognizer
-(void)handleTap:(UIGestureRecognizer*)recog {
    if (self.currentResponder) {
        [self.currentResponder resignFirstResponder];
    }
    
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    //    [UIView animateWithDuration:0.3 animations:^{
    //        [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    //    }];
}

#pragma mark UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.currentResponder = textView;
    [self.mainScrollView setContentOffset:CGPointMake(0, self.taskDescriptionArea.frame.origin.y - 75) animated:YES];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self delete];
    }
}

#pragma mark delete task
- (void)delete{
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.dimBackground = YES;
    [progressHUD setLabelText:@"Deleting Task..."];
    
    [self.taskObject destroyOnSuccess:^{
        [progressHUD setLabelText:@"Task Deleted!"];
        [progressHUD hide:YES afterDelay:2.0];
    } onError:^(NSError *error) {
        [progressHUD setLabelText:@"Unable to Delete!"];
        [progressHUD hide:YES afterDelay:2.0];
    }];
}
@end
