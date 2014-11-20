//
//  TasksViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "TasksViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TaskViewCell.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "TaskDetailViewController.h"

@interface TasksViewController (){
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) UITableView *tasksTableView;
@property (nonatomic, strong) NSMutableArray *tasksArray;
@property (nonatomic, strong) UIView *noTasksView;
@property (nonatomic, strong) UIImageView *noTasksImageView;
@property (nonatomic, strong) UILabel *noTasksLabel;
@property (nonatomic, strong) BuiltObject *builtObject;
@end

@implementation TasksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tasksArray = [NSMutableArray array];

    self.view.tag = 9999;
    self.tasksTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.tasksTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    self.tasksTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tasksTableView.delegate = self;
    self.tasksTableView.dataSource = self;
    self.tasksTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self.view addSubview:self.tasksTableView];
}

- (void)loadTasks:(BuiltObject *)builtObject{
    self.builtObject = builtObject;
    [self configurePullToRefresh];
    [self.tasksTableView triggerPullToRefresh];
}

- (void)configurePullToRefresh{
    __unsafe_unretained typeof(self) bself = self;
    
    [bself.tasksTableView addPullToRefreshWithActionHandler:^{
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.dimBackground = YES;
        [progressHUD setLabelText:@"Loading Tasks List..."];
        
        //form a query for retrieveing tasks
        BuiltQuery *query = [BuiltQuery queryWithClassUID:@"task"];
        
        //fetch tasks for current project
        [query whereKey:@"project" containedIn:[NSArray arrayWithObject:self.builtObject.uid]];
        
        //fire the query
        [query exec:^(QueryResult *result, ResponseType type) {
            [bself.tasksArray removeAllObjects];
            NSMutableArray *tasks = [result getResult];
            [tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BuiltObject *object = (BuiltObject *)obj;
                [self.tasksArray addObject:object];
            }];
            if (self.tasksArray.count > 0) {
                [self.tasksTableView reloadData];
            }else{
                [self.tasksTableView setHidden:YES];
                [self noTasksViewLayout];
            }
            [bself.tasksTableView.pullToRefreshView stopAnimating];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        } onError:^(NSError *error, ResponseType type) {
            [bself.tasksTableView.pullToRefreshView stopAnimating];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        }];
    }];
}

- (void)noTasksViewLayout{
    CGFloat yPOS = 0.0;
    self.noTasksView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.noTasksImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 128, 128)];
    [self.noTasksImageView setCenter:CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) / 2 - 50)];
    [self.noTasksImageView setImage:[UIImage imageNamed:@"no_bugs"]];
    yPOS = CGRectGetMaxY(self.noTasksImageView.frame);
    
    self.noTasksLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yPOS + 10, self.view.frame.size.width, 18)];
    self.noTasksLabel.text = @"No Tasks";
    [self.noTasksLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.noTasksLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.noTasksView addSubview:self.noTasksImageView];
    [self.noTasksView addSubview:self.noTasksLabel];
    [self.view addSubview:self.noTasksView];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _containerOrigin = self.navigationController.view.frame.origin;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.navigationController.view.layer.bounds       = (CGRect){-_containerOrigin.x, _containerOrigin.y, self.navigationController.view.frame.size};
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.navigationController.view.layer.bounds       = (CGRect){CGPointZero, self.navigationController.view.frame.size};
    self.navigationController.view.frame              = (CGRect){_containerOrigin, self.navigationController.view.frame.size};
}

#pragma mark UITableViewDataSourceDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    TaskViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"TaskViewCell" owner:self options:nil];
        for(id currentObjects in topLevelObjects){
            if ([currentObjects isKindOfClass:[UITableViewCell class]]) {
                cell = (TaskViewCell *)currentObjects;
                break;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BuiltObject *object = [self.tasksArray objectAtIndex:indexPath.row];
    [cell loadCellData:object];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tasksArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskDetailViewController *taskDetailViewController = [[TaskDetailViewController alloc]initWithNibName:nil bundle:nil];
    taskDetailViewController.canDeleteTask = self.canDeleteTask;
    taskDetailViewController.taskObject = [self.tasksArray objectAtIndex:indexPath.row];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:taskDetailViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    [taskDetailViewController loadTaskDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
