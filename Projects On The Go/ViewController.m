//
//  ViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "ViewController.h"
#import "SidebarViewController.h"
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"
#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"
#import "ProjectViewController.h"
#import "TasksViewController.h"
#import "MilestoneViewController.h"
#import "BugsViewController.h"
#import "TasksViewController.h"
#import "AppDelegate.h"
#import "CreateBugViewController.h"
#import "NewMilestoneViewController.h"
#import "NewTaskViewController.h"
#import "PannelView.h"
#import "MBProgressHUD.h"

enum PannelState {
    PannelStateOut,
    PannelStateIn
};

@interface ViewController ()<SidebarViewControllerDelegate, PannelDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong)NSString *projectName;
@property (nonatomic, assign) enum PannelState pannelState;
@property (nonatomic, strong) PannelView *pannelView;
@property (nonatomic, assign) BOOL canDeleteBug;
@property (nonatomic, assign) BOOL canDeleteMilestone;
@property (nonatomic, assign) BOOL canDeleteTasks;
@property (nonatomic, assign) BOOL canCreateTask;
@property (nonatomic, assign) BOOL canCreateMilestone;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation ViewController
@synthesize leftSidebarViewController,leftSelectedIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(PannelView *)pannelView {
    if (!_pannelView) {
        _pannelView = [[PannelView alloc] init];
        _pannelView.delegate = self;
    }
    return _pannelView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canDeleteBug = NO;
    self.canDeleteMilestone = NO;
    self.canDeleteTasks = NO;
    self.canCreateMilestone = NO;
    self.canCreateTask = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];    
    self.navigationItem.revealSidebarDelegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getRoles];
}

-(void)showInitialBugsViewWithProjectName:(BuiltObject *)builtObject{
    self.leftSidebarViewController = nil;
    self.builtObject = builtObject;
    self.leftSelectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    self.projectName = [builtObject objectForKey:@"name"];
    [self showBugs:MY_BUGS andIndexPath:nil];
}

- (void)revealLeftSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateLeft];
}

- (void)revealRightSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateRight];
}

#pragma mark JTRevealSidebarDelegate

-(UIView *)viewForLeftSidebar{
    // Use applicationViewFrame to get the correctly calculated view's frame
    // for use as a reference to our sidebar's view
    CGRect viewFrame = self.navigationController.applicationViewFrame;
    UITableViewController *controller = self.leftSidebarViewController;
    if (!controller) {
        self.leftSidebarViewController = [[SidebarViewController alloc] initWithProject:[NSMutableArray arrayWithObjects:self.projectName, MY_BUGS, MY_TASKS, MY_MILESTONE,nil]];
        self.leftSelectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        self.leftSidebarViewController.sidebarDelegate = self;
        controller = self.leftSidebarViewController;
        controller.title = @"Projects on the go";
    }

    controller.view.frame = CGRectMake(0, viewFrame.origin.y, 270, viewFrame.size.height);
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    return controller.view;
}

-(void)didChangeRevealedStateForViewController:(UIViewController *)viewController{
    // Example to disable userInteraction on content view while sidebar is revealing
    if (viewController.revealedState == JTRevealedStateNo) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

-(void) removeGesture {
    for (UIGestureRecognizer *recognizer in self.navigationController.navigationBar.gestureRecognizers) {
        [self.navigationController.navigationBar removeGestureRecognizer:recognizer];
    }
}

-(void) addGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
}

#pragma mark SidebarViewControllerDelegate

-(void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController setRevealedState:JTRevealedStateNo];
    if ([object isEqual:MY_PROJECTS]) {
        [self showProjects:object andIndexPath:indexPath];
        
    }else if ([object isEqual:MY_TASKS]){
        [self showTasks:object andIndexPath:indexPath];

    }else if ([object isEqual:MY_BUGS]){
        [self showBugs:object andIndexPath:indexPath];
        
    }else if ([object isEqual:MY_MILESTONE]){
        [self showMilestones:object andIndexPath:indexPath];
    }else {
        [self removeGesture];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

-(NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController{
    return self.leftSelectedIndexPath;
}

#pragma mark - Roles
- (void)getRoles{
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.dimBackground = YES;
    
    NSString *projectModerator = [NSString stringWithFormat:@"%@_moderators",[self.builtObject objectForKey:@"name"]];
    
    BuiltQuery *rolesQuery = [[[AppDelegate sharedAppDelegate].builtApplication roleWithName:@"admin"] query];

    [rolesQuery execInBackground:^(ResponseType type, QueryResult *result, NSError *error) {
        if (error == nil) {
            [[result getRoles] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BuiltRole *role = (BuiltRole *)obj;
                if ([role.roleName isEqualToString:projectModerator]) {
                    if ([role hasUser:[[[AppDelegate sharedAppDelegate].builtApplication currentUser] uid]]) {
                        //user is moderator
                        self.canCreateTask = YES;
                        self.canCreateMilestone = YES;
                        self.canDeleteBug = YES;
                        self.canDeleteMilestone = YES;
                        self.canDeleteTasks = YES;
                    }
                }
                if ([role.roleName isEqualToString:@"admin"]) {
                    if ([role hasUser:[[[AppDelegate sharedAppDelegate].builtApplication currentUser] uid]]) {
                        //user is admin
                        self.canCreateTask = YES;
                        self.canCreateMilestone = YES;
                        self.canDeleteBug = YES;
                        self.canDeleteMilestone = YES;
                        self.canDeleteTasks = YES;
                    }
                }
            }];
            [self.progressHUD hide:YES afterDelay:3.0];
            [self showInitialBugsViewWithProjectName:self.builtObject];
        }else {
            [self.progressHUD hide:YES afterDelay:3.0];
            [self showInitialBugsViewWithProjectName:self.builtObject];
        }
    }];
}

//load projects
-(void)showProjects:(NSObject *)object andIndexPath:(NSIndexPath *)indexpath{
    //'project' is the uid of the class
    ProjectViewController *projectVC = [[ProjectViewController alloc]initWithStyle:UITableViewStylePlain withBuiltClass:[[AppDelegate sharedAppDelegate].builtApplication classWithUID:@"project"]];
    projectVC.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    projectVC.title = (NSString *)object;
    self.mainViewController = projectVC;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:self.mainViewController animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(revealRightSidebar:)];
    self.mainViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu"] style:UIBarButtonItemStyleDone target:self action:@selector(revealLeftSidebar:)];
    self.mainViewController.navigationItem.revealSidebarDelegate = self;
}

//load tasks
-(void)showTasks:(NSObject *)object andIndexPath:(NSIndexPath *)indexpath{
    if ([self.mainViewController isKindOfClass:[NSNull class]] || ![self.mainViewController isKindOfClass:[TasksViewController class]]) {
        TasksViewController *tasksVC = [[TasksViewController alloc]init];
        tasksVC.canDeleteTask = self.canDeleteTasks;
        tasksVC.title = (NSString *)object;
        [tasksVC.view setBackgroundColor:[UIColor whiteColor]];
        self.leftSelectedIndexPath = indexpath;
        [tasksVC loadTasks:self.builtObject];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            tasksVC.edgesForExtendedLayout=UIRectEdgeNone;
        }
        self.mainViewController = tasksVC;
        
        [self.navigationController pushViewController:self.mainViewController animated:NO];
        self.mainViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu"] style:UIBarButtonItemStyleDone target:self action:@selector(revealLeftSidebar:)];
        
        if (self.canCreateTask) {
            self.mainViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create Task" style:UIBarButtonItemStylePlain target:self action:@selector(createTask)];
        }
        
        self.mainViewController.navigationItem.revealSidebarDelegate = self;
    }else{
        if ([self.mainViewController isKindOfClass:[TasksViewController class]]) {
            [self.navigationController setRevealedState:JTRevealedStateNo];
        }
    }
}

//load bugs
-(void)showBugs:(NSObject *)object andIndexPath:(NSIndexPath *)indexpath{
    if ([self.mainViewController isKindOfClass:[NSNull class]] || ![self.mainViewController isKindOfClass:[BugsViewController class]]) {
        BugsViewController *bugsVC = [[BugsViewController alloc]initWithNibName:nil bundle:nil];
        bugsVC.canDeleteBug = self.canDeleteBug;
        bugsVC.title = (NSString *)object;
        [bugsVC.view setBackgroundColor:[UIColor whiteColor]];
        self.leftSelectedIndexPath = indexpath;
        [bugsVC loadBugsListWithObject:self.builtObject];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            bugsVC.edgesForExtendedLayout=UIRectEdgeNone;
        }
        self.mainViewController = bugsVC;
        
        [self.navigationController pushViewController:self.mainViewController animated:NO];
        self.mainViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu"] style:UIBarButtonItemStyleDone target:self action:@selector(revealLeftSidebar:)];
                
        self.mainViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create Bug" style:UIBarButtonItemStyleDone target:self action:@selector(createBug)];
        
        self.mainViewController.navigationItem.revealSidebarDelegate = self;
    }else{
        if ([self.mainViewController isKindOfClass:[BugsViewController class]]) {
            [self.navigationController setRevealedState:JTRevealedStateNo];
        }
    }
}

//load milestones
-(void)showMilestones:(NSObject *)object andIndexPath:(NSIndexPath *)indexpath{
    if ([self.mainViewController isKindOfClass:[NSNull class]] || ![self.mainViewController isKindOfClass:[MilestoneViewController class]]){
        MilestoneViewController *milestoneVC = [[MilestoneViewController alloc]init];
        milestoneVC.canDeleteMilestone = self.canDeleteMilestone;
        [milestoneVC loadMilestones:self.builtObject];
        milestoneVC.title = (NSString *)object;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            milestoneVC.edgesForExtendedLayout=UIRectEdgeNone;
        }
        self.leftSelectedIndexPath = indexpath;
        self.mainViewController = milestoneVC;
        
        [self.navigationController pushViewController:self.mainViewController animated:NO];
        self.mainViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu"] style:UIBarButtonItemStyleDone target:self action:@selector(revealLeftSidebar:)];
        
        if (self.canCreateMilestone) {
            self.mainViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newMilestone)];
        }
                
        self.mainViewController.navigationItem.revealSidebarDelegate = self;
    }else{
        if ([self.mainViewController isKindOfClass:[MilestoneViewController class]]) {
            [self.navigationController setRevealedState:JTRevealedStateNo];
        }
    }

}

- (void)createBug {
    CreateBugViewController *createBugViewController = [[CreateBugViewController alloc]initWithNibName:@"CreateBugViewController" bundle:nil];
    createBugViewController.project = self.builtObject;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:createBugViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)newMilestone{
    NewMilestoneViewController *newMilestoneViewController = [[NewMilestoneViewController alloc]initWithNibName:@"NewMilestoneViewController" bundle:nil];
    newMilestoneViewController.project = self.builtObject;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:newMilestoneViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)createTask{
    NewTaskViewController *newTaskViewController = [[NewTaskViewController alloc]init];
    newTaskViewController.project = self.builtObject;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:newTaskViewController];
    [navController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark UIGestureRecognizer

-(void)handleTap:(UIGestureRecognizer*)recognizer {
    if (self.pannelState == PannelStateOut) {
        if (self.navigationController.viewControllers.count <= 3) {
            self.mainViewController.view.userInteractionEnabled = NO;

            [self.pannelView setFrame:CGRectMake(0, -250, CGRectGetWidth(self.navigationController.navigationBar.frame), 200)];
            [self.pannelView readjustView];
            [self.navigationController.view insertSubview:self.pannelView  belowSubview:self.navigationController.navigationBar];
            [UIView animateWithDuration:0.5 animations:^{
                [self.pannelView setFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.pannelView.frame), CGRectGetHeight(self.pannelView.frame))];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [self.pannelView setFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) - 20, CGRectGetWidth(self.pannelView.frame), CGRectGetHeight(self.pannelView.frame))];
                }];
            }];
            self.pannelState = PannelStateIn;
        }
    }else if (self.pannelState == PannelStateIn) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.pannelView setFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.pannelView.frame), CGRectGetHeight(self.pannelView.frame))];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [self.pannelView setFrame:CGRectMake(0, -250, CGRectGetWidth(self.pannelView.frame), CGRectGetHeight(self.pannelView.frame))];
            } completion:^(BOOL finished) {
                [self.pannelView removeFromSuperview];
            }];
            self.mainViewController.view.userInteractionEnabled = YES;
        }];
        self.pannelState = PannelStateOut;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (![[[touch view] class] isSubclassOfClass:[UIControl class]]);
}

#pragma mark PannelDelegate
-(BuiltObject *)getObjectForIndexPath:(NSIndexPath *)indexPath {
    return [self.projectViewController builtObjectAtIndexPath:indexPath];
}

-(NSInteger)getNumberOfRows {
    return self.projectViewController.numberOfRows;
}

-(void)selectedIndexPath:(NSIndexPath *)indexPath {
    [self showInitialBugsViewWithProjectName:[self.projectViewController builtObjectAtIndexPath:indexPath]];
    [self handleTap:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
