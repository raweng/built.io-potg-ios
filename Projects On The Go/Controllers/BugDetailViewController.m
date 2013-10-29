//
//  BugDetailViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 19/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "BugDetailViewController.h"
#import "EditBugDetailsController.h"
#import "BugCommentsCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppUtils.h"
#import "NSDate+Addition.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "CommentsViewController.h"
#import "SVPullToRefresh.h"
#import "AttachmentViewController.h"

const CGFloat kScrollObjHeight	= 64.0;
const CGFloat kScrollObjWidth	= 52.0;

@interface BugDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,CommentsDelegate>{
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *attachmentsView;
@property (nonatomic, strong) UILabel *bugTitle;
@property (nonatomic, strong) UILabel *dueDate;
@property (nonatomic, strong) UILabel *dueDateContent;
@property (nonatomic, strong) UIButton *deleteBugButton;
@property (nonatomic, strong) UILabel *createdByLabel;
@property (nonatomic, strong) UILabel *createdByValueLabel;
@property (nonatomic, strong) UILabel *bugDetailLabel;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UITableView *commentsTableView;
@property (nonatomic, strong) UILabel *bugDetails;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UIView *frameView;
@property (nonatomic, strong) UILabel *attachmentLabel;
@property (nonatomic, strong) UIButton *addCommentButton;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign)BOOL areCommentsEmpty;
@property (nonatomic, strong)BuiltObject *builtObject;
@property (nonatomic, strong)NSMutableArray *attachments;
@property (nonatomic, strong)UILabel *noAttachmentLabel;
@end

@implementation BugDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.canDeleteBug = NO;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.comments = [NSMutableArray array];
}

-(UIView *)frameView{
    if (!_frameView) {
        _frameView = [[UIView alloc]initWithFrame:CGRectZero];
        _frameView.layer.cornerRadius = 5;
        _frameView.layer.masksToBounds = YES;
    }
    return _frameView;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
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

-(UILabel *)createdByLabel{
    if (!_createdByLabel) {
        _createdByLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_createdByLabel setText:@"Created By:"];
        [_createdByLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_createdByLabel setBackgroundColor:[UIColor clearColor]];
        [_createdByLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _createdByLabel;
}

-(UILabel *)createdByValueLabel{
    if (!_createdByValueLabel) {
        _createdByValueLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_createdByValueLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_createdByValueLabel setBackgroundColor:[UIColor clearColor]];
        [_createdByValueLabel setTextColor:[UIColor blackColor]];
    }
    return _createdByValueLabel;
}

-(UILabel *)dueDate{
    if (!_dueDate) {
        _dueDate = [[UILabel alloc]initWithFrame:CGRectZero];
        [_dueDate setText:@"Due Date:"];
        [_dueDate setFont:[UIFont systemFontOfSize:17.0]];
        [_dueDate setBackgroundColor:[UIColor clearColor]];
        [_dueDate setTextColor:[UIColor darkGrayColor]];
    }
    return _dueDate;
}

-(UILabel *)dueDateContent{
    if (!_dueDateContent) {
        _dueDateContent = [[UILabel alloc]initWithFrame:CGRectZero];
        [_dueDateContent setFont:[UIFont systemFontOfSize:15.0]];
        [_dueDateContent setBackgroundColor:[UIColor clearColor]];
        [_dueDateContent setTextColor:[UIColor blackColor]];
    }
    return _dueDateContent;
}

-(UILabel *)bugDetailLabel{
    if (!_bugDetailLabel) {
        _bugDetailLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_bugDetailLabel setText:@"Bug Details:"];
        [_bugDetailLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_bugDetailLabel setBackgroundColor:[UIColor clearColor]];
        [_bugDetailLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _bugDetailLabel;
}

-(UILabel *)bugDetails{
    if (!_bugDetails) {
        _bugDetails = [[UILabel alloc]initWithFrame:CGRectZero];
        [_bugDetails setBackgroundColor:[UIColor clearColor]];
        _bugDetails.numberOfLines = 0;
        _bugDetails.lineBreakMode = NSLineBreakByWordWrapping;
        [_bugDetails setFont:[UIFont systemFontOfSize:15.0]];
    }
    return _bugDetails;
}

-(UILabel *)attachmentLabel{
    if (!_attachmentLabel) {
        _attachmentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_attachmentLabel setBackgroundColor:[UIColor clearColor]];
        [_attachmentLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_attachmentLabel setText:@"Attachments:"];
        [_attachmentLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _attachmentLabel;
}

-(UIScrollView *)attachmentsView{
    if (!_attachmentsView) {
        _attachmentsView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        [_attachmentsView setBackgroundColor:[UIColor clearColor]];
        _attachmentsView.showsHorizontalScrollIndicator = NO;
        _attachmentsView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
        _attachmentsView.scrollEnabled = YES;
        _attachmentsView.pagingEnabled = YES;
    }
    return _attachmentsView;
}

-(UILabel *)commentsLabel{
    if (!_commentsLabel) {
        _commentsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_commentsLabel setBackgroundColor:[UIColor clearColor]];
        [_commentsLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_commentsLabel setText:@"Comments:"];
        [_commentsLabel setTextColor:[UIColor darkGrayColor]];
    }
    return _commentsLabel;
}

-(UITableView *)commentsTableView{
    if (!_commentsTableView) {
        _commentsTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_commentsTableView setBackgroundColor:[UIColor clearColor]];
        _commentsTableView.delegate = self;
        _commentsTableView.dataSource = self;
        _commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _commentsTableView;
}

-(UIButton *)addCommentButton{
    if (!_addCommentButton) {
        _addCommentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage *buttonImage = [[UIImage imageNamed:@"spin"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        [_addCommentButton setTitle:@"Add Comment" forState:UIControlStateNormal];
        [_addCommentButton addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
        [_addCommentButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    return _addCommentButton;
}

-(UIButton *)deleteBugButton{
    if (!_deleteBugButton) {
        _deleteBugButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage *buttonBckg = [[UIImage imageNamed:@"spin"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        [_deleteBugButton setTitle:@"Delete" forState:UIControlStateNormal];
        [_deleteBugButton setBackgroundImage:buttonBckg forState:UIControlStateNormal];
        [_deleteBugButton addTarget:self action:@selector(deleteBug:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBugButton;
}

-(UILabel *)noAttachmentLabel{
    if (!_noAttachmentLabel) {
        _noAttachmentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_noAttachmentLabel setBackgroundColor:[UIColor clearColor]];
        [_noAttachmentLabel setFont:[UIFont systemFontOfSize:15.0]];
        _noAttachmentLabel.textAlignment = NSTextAlignmentCenter;
        [_noAttachmentLabel setText:@"No Attachments"];
        [_noAttachmentLabel setTextColor:[UIColor lightGrayColor]];
    }
    return _noAttachmentLabel;
}

-(void)viewWillAppear:(BOOL)animated{
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBugAction)];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
}

- (void)loadData:(BuiltObject *)bObject{
    BuiltUser *user = [BuiltUser currentUser];
    NSMutableArray *assigneeUIDs = [NSMutableArray array];
    NSMutableArray *assignees = [bObject objectForKey:@"assignees"];
    if (assignees && assignees.count > 0) {
        [assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *assignDict = (NSMutableDictionary *)obj;
            [assigneeUIDs addObject:[assignDict objectForKey:@"uid"]];
        }];
        
        [assigneeUIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[assigneeUIDs objectAtIndex:idx] isEqual:user.uid]) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBugAction)];
                *stop = YES;
            }
        }];
    }

    self.builtObject = bObject;
    self.areCommentsEmpty = YES;
    self.bugTitle.text = [NSString stringWithFormat:@"    %@",[bObject objectForKey:@"name"]];
    self.bugDetails.text = [NSString stringWithFormat:@"%@",[bObject objectForKey:@"description"]];
    self.dueDateContent.text = [AppUtils gmtStringWildFireFromUtc:[bObject objectForKey:@"due_date"]];
    NSDate *date = [AppUtils convertGMTtoLocal:[bObject objectForKey:@"due_date"]];

    self.dueDateContent.text = [NSString stringWithFormat:@"%@",[date formatDate]];
    
    if ([bObject hasOwner]) {
        if ([[bObject objectForKey:@"_owner"] objectForKey:@"first_name"] != nil && [[bObject objectForKey:@"_owner"] objectForKey:@"last_name"]) {
            [self.createdByValueLabel setText:[NSString stringWithFormat:@"%@ %@",[[bObject objectForKey:@"_owner"] objectForKey:@"first_name"],[[bObject objectForKey:@"_owner"] objectForKey:@"last_name"]]];
        }
    }
    if ([bObject objectForKey:@"attachments"]) {
        self.attachments = [NSMutableArray array];
        [[bObject objectForKey:@"attachments"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [self.attachments addObject:obj];
            }
        }];
        
        if ([self.attachments count] > 0) {
            [self.noAttachmentLabel setHidden:YES];
            [self.attachmentsView setHidden:NO];
            NSUInteger i;
            for (i = 0; i < self.attachments.count; i++)
            {
                NSString *filename = [[self.attachments objectAtIndex:i] objectForKey:@"filename"];
                UIImage *image = [UIImage imageNamed:[AppUtils fileTypeFromFilename:filename]];
                
                
                UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [thumbnailButton setImage:image forState:UIControlStateNormal];
                [thumbnailButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
                CGRect rect = thumbnailButton.frame;
                rect.size.height = kScrollObjHeight;
                rect.size.width = kScrollObjWidth;
                thumbnailButton.frame = rect;
                thumbnailButton.tag = i;	// tag our images for later use when we place them in serial fashion
                [self.attachmentsView addSubview:thumbnailButton];
            }
        }else{
            [self.noAttachmentLabel setHidden:NO];
            [self.attachmentsView setHidden:YES];
        }
    }
    
    [self layoutScrollImages];
    [self prepareViews];
    
    [self configurePullToRefresh];
    [self.commentsTableView triggerPullToRefresh];
}

- (void)thumbnailTapped:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    AttachmentViewController *attachmentView = [[AttachmentViewController alloc]init];
    attachmentView.url = [[self.attachments objectAtIndex:button.tag] objectForKey:@"url"];
    
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:attachmentView];
    
    [self presentViewController:nvc animated:YES completion:^{
        
    }];
}

- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [self.attachmentsView subviews];
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (kScrollObjWidth);
		}
	}
	
	// set the content size so it can be scrollable
	[self.attachmentsView setContentSize:CGSizeMake((self.attachments.count * kScrollObjWidth), [self.attachmentsView bounds].size.height)];
}

- (void)prepareViews{
    CGFloat xPOS = 0;
    CGFloat yPOS = 0;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.bugTitle setFrame:CGRectMake(0, 0, width, 30)];
    yPOS = CGRectGetMaxY(self.bugTitle.frame) + 10;
    
    [self.dividerView setFrame:CGRectMake(0, yPOS - 8, width, 2)];
    yPOS = CGRectGetMaxY(self.dividerView.frame) + 10;
    
    if (self.canDeleteBug) {
        [self.deleteBugButton setFrame:CGRectMake(10, yPOS + 25, 100, 40)];
        yPOS = CGRectGetMaxY(self.deleteBugButton.frame) + 10;
    }
    
    [self.createdByLabel setFrame:CGRectMake(10, yPOS + 25, 100, 20)];
    yPOS = CGRectGetMaxY(self.createdByLabel.frame) + 10;
    
    [self.createdByValueLabel setFrame:CGRectMake(CGRectGetMaxX(self.createdByLabel.frame) + 10, self.createdByLabel.frame.origin.y, width - (CGRectGetMaxX(self.createdByLabel.frame) + 10) - 20, 20)];
    
    [self.dueDate setFrame:CGRectMake(10, yPOS + 10, 100, 20)];
    
    [self.dueDateContent setFrame:CGRectMake(CGRectGetMaxX(self.dueDate.frame) + 10, yPOS + 10, width - (CGRectGetMaxX(self.dueDate.frame) + 10) - 20, 20)];
    yPOS = CGRectGetMaxY(self.dueDate.frame) + 10;

    
    [self.bugDetailLabel setFrame:CGRectMake(10, yPOS + 10, width - 20, 20)];
    yPOS = CGRectGetMaxY(self.bugDetailLabel.frame) + 10;
    
    [self.bugDetails setFrame:CGRectMake(20, yPOS, width - 40, 0)];
    [self.bugDetails sizeToFit];
    yPOS = CGRectGetMaxY(self.bugDetails.frame) + 10;
    
    [self.attachmentLabel setFrame:CGRectMake(10, yPOS + 10, width - 20, 20)];
    yPOS = CGRectGetMaxY(self.attachmentLabel.frame) + 10;
    
    [self.attachmentsView setFrame:CGRectMake(10, CGRectGetMaxY(self.attachmentLabel.frame) + 10, width - 20, 80)];
    yPOS = CGRectGetMaxY(self.attachmentsView.frame) + 10;
    
    [self.noAttachmentLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.attachmentLabel.frame) + 10, width - 20, 50)];
    yPOS = CGRectGetMaxY(self.noAttachmentLabel.frame) + 10;
    
    [self.commentsLabel setFrame:CGRectMake(10, yPOS + 10, width - 20, 20)];
    yPOS = CGRectGetMaxY(self.commentsLabel.frame) + 10;

    if (self.comments.count < 1) {
        [self.commentsTableView setFrame:CGRectMake(10, yPOS, width - 20, 30)];
    }else{
        if (self.comments.count < 7) {
            [self.commentsTableView setFrame:CGRectMake(10, yPOS, width - 20, self.comments.count * 50)];
        }else{
            [self.commentsTableView setFrame:CGRectMake(10, yPOS, width - 20, 300)];
        }
    }
    
    yPOS = CGRectGetMaxY(self.commentsTableView.frame) + 10;
    
    [self.addCommentButton setFrame:CGRectMake(20, yPOS + 15, 150, 40)];
    yPOS = CGRectGetMaxY(self.addCommentButton.frame) + 10;
    
    [self.scrollView addSubview:self.bugTitle];
    [self.scrollView addSubview:self.dividerView];
    [self.scrollView addSubview:self.deleteBugButton];
    [self.scrollView addSubview:self.createdByLabel];
    [self.scrollView addSubview:self.createdByValueLabel];
    [self.scrollView addSubview:self.dueDate];
    [self.scrollView addSubview:self.dueDateContent];
    [self.scrollView addSubview:self.bugDetailLabel];
    [self.scrollView addSubview:self.bugDetails];
    [self.scrollView addSubview:self.attachmentLabel];
    [self.scrollView addSubview:self.attachmentsView];
    [self.scrollView addSubview:self.noAttachmentLabel];
    [self.scrollView addSubview:self.commentsLabel];
    [self.scrollView addSubview:self.commentsTableView];
    [self.scrollView addSubview:self.addCommentButton];
    [self.scrollView setContentSize:CGSizeMake(width, yPOS + 60)];
    [self.view addSubview:self.scrollView];
}

- (void)configurePullToRefresh{
    
    __unsafe_unretained typeof(self) bself = self;
    
    [bself.commentsTableView addPullToRefreshWithActionHandler:^{
        
        //create a query to fetch comments
        BuiltQuery *query = [BuiltQuery queryWithClassUID:@"comment"];
        
        //fetch comments for current bug
        [query whereKey:@"for_bug" containedIn:[NSArray arrayWithObjects:bself.builtObject.uid, nil]];
        
        //fire query
        [query exec:^(QueryResult *result, ResponseType type) {
            NSMutableArray *results = [NSMutableArray arrayWithArray:[result getResult]];
            [self.comments removeAllObjects];
            [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BuiltObject *object = (BuiltObject *)obj;
                [self.comments addObject:object];
            }];
            self.areCommentsEmpty = self.comments.count > 0 == true ? false : true;
            [bself.commentsTableView.pullToRefreshView stopAnimating];
            [self.commentsTableView reloadData];
            [self prepareViews];
        } onError:^(NSError *error, ResponseType type) {
            [bself.commentsTableView.pullToRefreshView stopAnimating];
            [self prepareViews];
        }];
    }];
}

-(void)editBugAction{
    EditBugDetailsController *editBugDetailsController = [[EditBugDetailsController alloc]initWithNibName:@"EditBugDetailsController" bundle:nil];
    editBugDetailsController.project = self.builtObject;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:editBugDetailsController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    [editBugDetailsController prepareViews];
    [editBugDetailsController loadData];
}

-(void)deleteBug:(id)sender{
    UIAlertView *deleteAlert = [[UIAlertView alloc]initWithTitle:@"Delete Bug" message:@"Are you sure you want to delete the bug?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [deleteAlert show];
}

-(void)addComment:sender{
    CommentsViewController *commentsViewController = [[CommentsViewController alloc]init];
    commentsViewController.builtObject = self.builtObject;
    commentsViewController.project = self.project;
    commentsViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:commentsViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    [commentsViewController loadData];
}

/*
    Delete Bug.
    Created Bug can be deleted using BuiltObject's destroyOnSuccess:onError: method.
    An ACL is set on the Bug class objects so that only users that are of Role 'moderators' can delete the bug.
 */
-(void)delete{
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.dimBackground = YES;
    [progressHUD setLabelText:@"Deleting Bug..."];
    [self.builtObject destroyOnSuccess:^{
        [progressHUD setLabelText:@"Bug Deleted!"];
        [progressHUD hide:YES afterDelay:2.0];
        [self performSelector:@selector(dismissAfterCreating) withObject:nil afterDelay:1.0];
    } onError:^(NSError *error) {
        NSLog(@"error %@",error.userInfo);
        [progressHUD setLabelText:@"Deletion Failed!"];
        [progressHUD hide:YES afterDelay:2.0];
    }];
}

-(void)dismissAfterCreating{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    BugCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BugCommentsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.comments.count > 0) {
        BuiltObject *object = [self.comments objectAtIndex:indexPath.row];
        [cell loadCommentData:object];
    }else{
        [cell loadCommentData:nil];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.comments.count > 0) {
        NSString *content = [[self.comments objectAtIndex:indexPath.row] objectForKey:@"content"];
        CGSize actualSize = [content sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = actualSize.height + 15;
        if (height < 50) {
            return 50;
        }
        return height;
    }
    return 20;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.comments.count < 1) {
        return 1;
    }
    return self.comments.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self delete];
    }
}

#pragma mark CommentsDelegate
-(void)commentDone{
    [self loadData:self.builtObject];
}

@end
