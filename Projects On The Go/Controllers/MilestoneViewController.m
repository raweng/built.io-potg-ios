//
//  MilestoneViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "MilestoneViewController.h"
#import "MileStoneViewCell.h"
#import "AppUtils.h"
#import "NSDate+Addition.h"
#import "SVPullToRefresh.h"
#import "EditMilestoneController.h"
#import "AppDelegate.h"

@interface MilestoneViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *milestoneTableView;
@property (nonatomic, strong)NSMutableArray *milestones;
@property (nonatomic, strong) BuiltObject *builtObject;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation MilestoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.milestones = [NSMutableArray array];
    
    self.milestoneTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self.milestoneTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    self.milestoneTableView.delegate = self;
    self.milestoneTableView.dataSource = self;
    
    self.milestoneTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    [self.view addSubview:self.milestoneTableView];
    
    self.view.tag = 9999;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg.png"]]];
    
    [self configurePullToRefresh];
    [self.milestoneTableView triggerPullToRefresh];
}

- (void)loadMilestones:(BuiltObject *)builtObject{
    self.builtObject = builtObject;
    [self configurePullToRefresh];
    [self.milestoneTableView triggerPullToRefresh];
}

- (void)configurePullToRefresh{
    __unsafe_unretained typeof(self) bself = self;
    
    [bself.milestoneTableView addPullToRefreshWithActionHandler:^{
        
        //create a query to fetch bugs
        BuiltQuery *query = [BuiltQuery queryWithClassUID:@"milestone"];
        
        //fetch milestones for current project
        [query whereKey:@"project" containedIn:[NSArray arrayWithObject:self.builtObject.uid]];
        
        //include assignees' objects in the response
        [query includeRefFieldWithKey:[NSArray arrayWithObject:@"assignees"]];
        
        //fire the query
        [query exec:^(QueryResult *result) {
            [bself.milestones removeAllObjects];
            NSMutableArray *milestone = [result getResult];
            [milestone enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BuiltObject *object = (BuiltObject *)obj;
                [bself.milestones addObject:object];
            }];
            [bself.milestoneTableView.pullToRefreshView stopAnimating];
            [bself.milestoneTableView reloadData];
        } onError:^(NSError *error) {
            [bself.milestoneTableView.pullToRefreshView stopAnimating];
        }];
    }];
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    MileStoneViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MileStoneViewCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (MileStoneViewCell *)currentObject;
                break;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    BuiltObject *object = [self.milestones objectAtIndex:indexPath.row];
    cell.milestoneTitle.text = [NSString stringWithFormat:@"    %@",[object objectForKey:@"name"]];
    cell.milestoneDescription.text = [object objectForKey:@"description"];
    NSString *startDate = [object objectForKey:@"start_date"];
    NSString *endDate = [object objectForKey:@"end_date"];
    
    if (![startDate isKindOfClass:[NSNull class]] && ![endDate isKindOfClass:[NSNull class]]) {
        cell.startDate.text = [NSString stringWithFormat:@"Start Date: %@",[[AppUtils stringToDate:startDate] formatDate]];
        cell.dueDate.text = [NSString stringWithFormat:@"End Date: %@",[[AppUtils stringToDate:endDate] formatDate]];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 40;
    BuiltObject *object = [self.milestones objectAtIndex:indexPath.row];
    if ([object objectForKey:@"name"]) {
        CGSize size = [[object objectForKey:@"name"] sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(320, 999)];
        height += size.height;
    }
    
    if ([object objectForKey:@"description"]) {
        CGSize size = [[object objectForKey:@"description"] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(320, 999)];
        height += size.height;
    }
    if ([object objectForKey:@"name"]) {
        CGSize size = [[object objectForKey:@"name"] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(320, 999)];
        height += size.height;
    }
    return 120;
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BuiltObject *object = [self.milestones objectAtIndex:indexPath.row];
    EditMilestoneController *editMilestoneController = [[EditMilestoneController alloc]init];
    editMilestoneController.canDeleteMilestone = self.canDeleteMilestone;
    editMilestoneController.milestone = object;
    editMilestoneController.title = @"Milestone Details";
    [[AppDelegate sharedAppDelegate].nc pushViewController:editMilestoneController animated:YES];
    [editMilestoneController loadData];
    self.selectedIndexPath = indexPath;
}

-(BOOL)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.milestones.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
