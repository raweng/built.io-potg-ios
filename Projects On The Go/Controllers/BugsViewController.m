//
//  BugsViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "BugsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BugTableViewCell.h"
#import "AppDelegate.h"
#import "TasksViewController.h"
#import "MBProgressHUD.h"
#import "BugDetailViewController.h"
#import "SVPullToRefresh.h"
#import "AppUtils.h"
#import "NSDate+Addition.h"
#import "CreateBugViewController.h"

/*
    BugsViewController class lists all the bugs that are related to a particular project.
 
 */


@interface BugsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) UITableView *bugsTableView;
@property (nonatomic, strong) NSMutableArray *bugsList;
@property (nonatomic, strong) UIView *noBugsView;
@property (nonatomic, strong) UIImageView *noBugsImageView;
@property (nonatomic, strong) UILabel *noBugsLabel;
@property (nonatomic, strong) BuiltObject *builtObject;
@end

@implementation BugsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.view.tag = 9999;

        self.bugsList = [NSMutableArray array];
        
    }
    return self;
}

-(UIView *)noBugsView{
    if (!_noBugsView) {
        _noBugsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_noBugsView];
    }
    return _noBugsView;
}

-(UILabel *)noBugsLabel{
    if (!_noBugsLabel) {
        _noBugsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.noBugsView.frame) + 10, self.view.frame.size.width, 18)];
        [_noBugsLabel setText:@"No Bugs"];
        [_noBugsLabel setFont:[UIFont systemFontOfSize:13.0]];
        [_noBugsLabel setTextAlignment:NSTextAlignmentCenter];
        [self.noBugsView addSubview:_noBugsLabel];
    }
    return _noBugsLabel;
}

-(UIImageView *)noBugsImageView{
    if (!_noBugsImageView) {
        _noBugsImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 128, 128)];
        [_noBugsImageView setImage:[UIImage imageNamed:@"no_bugs"]];
        [self.noBugsView addSubview:_noBugsImageView];
    }
    return _noBugsImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    self.bugsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.bugsTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    self.bugsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bugsTableView.delegate = self;
    self.bugsTableView.dataSource = self;
    self.bugsTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    [self.view addSubview:self.bugsTableView];
    
    
}

- (void)loadBugsListWithObject:(BuiltObject *)object{
    self.builtObject = object;
    [self configurePullToRefresh];
    [self.bugsTableView triggerPullToRefresh];
}

- (void)configurePullToRefresh{
    __unsafe_unretained typeof (self) bself = self;
    [bself.bugsTableView addPullToRefreshWithActionHandler:^{
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.dimBackground = YES;
        [progressHUD setLabelText:@"Loading Bugs List..."];
        
        /*---------------------------------------------------------------------------
            BuiltQuery to fetch Bugs class objects sorted in descending order of creation date.
            Here we are retrieving only the Bugs objects that have reference to a particular Project using `(void)whereKey:(NSString *)key containedIn:(NSArray *)array`. We pass the project_uid as parameter to containedIn.
            Also we are querying about the Bug Object's owner through BuiltQuery's `(void)includeOwner:(BOOL)user` method.
            So in all BuiltQuery's exec method returns all the Bugs class objects of provided project uid sorted in descending order of creation datetime and includes object's owner details.
         ---------------------------------------------------------------------------
         */
        
        //create a query to fetch bugs
        BuiltQuery *bugsQuery = [BuiltQuery queryWithClassUID:@"bugs"];
        
        //fetch bugs for current project
        [bugsQuery whereKey:@"project" containedIn:@[bself.builtObject.uid]];
        
        //include assignees' objects in the response
        [bugsQuery includeRefFieldWithKey:[NSArray arrayWithObject:@"assignees"]];
        
        //order the response by latest first
        [bugsQuery orderByDescending:@"created_at"];
        
        //include the owner object in the response
        [bugsQuery includeOwner];
        
        //fire the query
        [bugsQuery exec:^(QueryResult *result, ResponseType type) {
            [bself.bugsList removeAllObjects];
            NSMutableArray *results = [result getResult];
            [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [bself.bugsList addObject:(BuiltObject *)obj];
            }];
            if (bself.bugsList.count > 0) {
                [bself.bugsTableView reloadData];
            }else{
                [bself.bugsTableView setHidden:YES];
                [bself noBugsViewLayout];
            }
            [bself.bugsTableView.pullToRefreshView stopAnimating];
            bself.bugsTableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
            [MBProgressHUD hideHUDForView:bself.view animated:NO];
        } onError:^(NSError *error, ResponseType type) {
            [bself.bugsTableView.pullToRefreshView stopAnimating];
            [MBProgressHUD hideHUDForView:bself.view animated:NO];
        }];
    }];
}

- (void)noBugsViewLayout{
    CGFloat yPOS = 0.0;
    [self.noBugsView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.noBugsImageView setCenter:CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) / 2 - 50)];
    [self.noBugsImageView setImage:[UIImage imageNamed:@"no_bugs"]];
    yPOS = CGRectGetMaxY(self.noBugsImageView.frame);
    [self.noBugsLabel setFrame:CGRectMake(0, yPOS + 10, self.view.frame.size.width, 18)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"BugTableViewCell";
    
    BugTableViewCell *cell = (BugTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BugTableViewCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (BugTableViewCell *)currentObject;
                break;
            }
        }
    }
    BuiltObject *object = [self.bugsList objectAtIndex:indexPath.row];
    cell.bugTitleLabel.text = [NSString stringWithFormat:@"    %@",[object objectForKey:@"name"]];
    cell.statusLabel.text = [object objectForKey:@"status"];
    cell.severityLabel.text = [object objectForKey:@"severity"];
     NSDate *date = [AppUtils convertGMTtoLocal:[object objectForKey:@"due_date"]];
    cell.dueDateLabel.text = [date formatDate];
    cell.reproducableLabel.text = [object objectForKey:@"reproducible"];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bugsList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BuiltObject *object = [self.bugsList objectAtIndex:indexPath.row];
    BugDetailViewController *bugDetailViewController = [[BugDetailViewController alloc]init];
    bugDetailViewController.canDeleteBug = self.canDeleteBug;
    bugDetailViewController.project = self.builtObject;
    bugDetailViewController.title = @"Bug Details";
    [[AppDelegate sharedAppDelegate].nc pushViewController:bugDetailViewController animated:YES];
    [bugDetailViewController loadData:object];
}

@end
