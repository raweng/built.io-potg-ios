//
//  CommentsViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 04/07/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "CommentsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface CommentsViewController (){
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) UILabel *bugTitle;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UITextField *commentsTextView;
@property (nonatomic, weak) UITextView *currentResponder;
@end

@implementation CommentsViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
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

-(UILabel *)commentLabel{
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_commentLabel setText:@"Add Comment"];
        [_commentLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_commentLabel setBackgroundColor:[UIColor clearColor]];
        [_commentLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _commentLabel;
}

-(UITextField *)commentsTextView{
    if (!_commentsTextView) {
        _commentsTextView = [[UITextField alloc]initWithFrame:CGRectZero];
        [_commentsTextView setBackgroundColor:[UIColor lightGrayColor]];
        [_commentsTextView setTextColor:[UIColor blackColor]];
        [_commentsTextView setFont:[UIFont systemFontOfSize:15.0]];
        [_commentsTextView setPlaceholder:@"Add Comment"];
        [_commentsTextView setValue:[UIColor darkGrayColor]
                        forKeyPath:@"_placeholderLabel.textColor"];
    }
    return _commentsTextView;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClick:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Add Comment"];
    
    [self prepareViews];
}

- (void)prepareViews{
    CGFloat xPOS = 0;
    CGFloat yPOS = 0;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.bugTitle setFrame:CGRectMake(0, 0, width, 30)];
    yPOS = CGRectGetMaxY(self.bugTitle.frame) + 10;
    
    [self.dividerView setFrame:CGRectMake(0, yPOS - 8, width, 2)];
    yPOS = CGRectGetMaxY(self.dividerView.frame) + 10;
    
    [self.commentLabel setFrame:CGRectMake(10, yPOS, width - 20, 20.0)];
    yPOS = CGRectGetMaxY(self.commentLabel.frame);
    
    [self.commentsTextView setFrame:CGRectMake(10, yPOS + 5, width - 20, 100)];
    
    [self.view addSubview:self.bugTitle];
    [self.view addSubview:self.dividerView];
    [self.view addSubview:self.commentLabel];
    [self.view addSubview:self.commentsTextView];
}

- (void)loadData{
    self.bugTitle.text = [NSString stringWithFormat:@"    %@",[self.builtObject objectForKey:@"name"]];
}

- (void)doneButtonClick:(id)sender{
    progressHUD  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.dimBackground = YES;
    [progressHUD setLabelText:@"Adding Comment"];
        
    //create a comment object and set the values for fields
    BuiltObject *object = [BuiltObject objectWithClassUID:@"comment"];
    [object setObject:self.commentsTextView.text forKey:@"content"];
    
    //set the bug object's uid for the reference field for_bug
    [object setReference:self.builtObject.uid forKey:@"for_bug"];
    
    //set the project object's uid for the reference field project
    [object setReference:self.project.uid forKey:@"project"];
    
    //save the comment object
    [object saveOnSuccess:^{
        [progressHUD setLabelText:@"Success!!"];
        [progressHUD hide:YES afterDelay:3.0];
        [self.delegate commentDone];
        [self dismissViewControllerAnimated:YES completion:nil];
    } onError:^(NSError *error) {
        [progressHUD setLabelText:@"Failure!!"];
        [progressHUD hide:YES afterDelay:3.0];
    }];
}

- (void)dismissSelf:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
