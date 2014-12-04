//
//  AppDelegate.m
//  Projects On The Go
//
//  Created by Akshay Mhatre on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

/* Projects On The Go
 ***************************************************************************************************************************************
    Projects On The Go App is a sample project that helps keep track and manage projects, Create/Update and track Bug Process,
    set Milestones and update them, assign/distribute tasks and update them.
    It works on the scheme pre-created on built.io web ui and contains in all 5 classes : Tasks, Comments, Projects, Milestones and Bugs.
 ***************************************************************************************************************************************
 */

#import "AppDelegate.h"

#import "ViewController.h"
#import "ProjectViewController.h"

@interface AppDelegate ()<BuiltUIGoogleAppSettingDelegate, BuiltUILoginDelegate, BuiltUITwitterAppSettingDelegate>
//@property (nonatomic, strong)UINavigationController *nvc;
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ----------------------------------------------------------------------------
    // Built initialization
    // [Built initializeWithApiKey:@"APPLICATION_API_KEY" andUid:@"APPLICATION_UID"];
    // ----------------------------------------------------------------------------
    
    [Built initializeWithApiKey:@"api_key_here" andUid:@"app_uid_here"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];

    // ----------------------------------------------------------------------------
    // Get BuiltUser Object and check whether user is logged in.
    // [BuiltUser currentUser] returns nil if user is not logged in and called saveUserSession on BuiltUser Object.
    // If User is not logged in take to BuiltUILoginController otherwise load any other ViewController
    // ----------------------------------------------------------------------------
    BuiltUser *user = [BuiltUser currentUser];
    if (user) {
        [self checkForUserRightsAndLoadProjects];
    }else{//if there is no user logged in present the login controller
        BuiltUILoginController *login = [[BuiltUILoginController alloc]initWithNibName:nil bundle:nil];
        
        //set the login delegate to be notified when user logs in
        [login setDelegate:self];
        
        //set google app setting delegate to set the app client id and secret of your google app
        [login setGoogleAppSettingDelegate:self];

        //set twitter app setting delegate to set the consumer key and secret of your twitter app
        [login setTwitterAppSettingDelegate:self];

        //select the login fields that will be displayed to the user
        login.fields = BuiltLoginFieldUsernameAndPassword | BuiltLoginFieldLogin | BuiltLoginFieldGoogle | BuiltLoginFieldSignUp | BuiltLoginFieldTwitter;
        
        //shows HUD when logging in
        login.shouldHandleLoadingHUD = YES;
        
        //initialize the navigation controller with the login controller
        self.nc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self.nc.navigationBar setTintColor:[UIColor darkGrayColor]];
        [self.nc setNavigationBarHidden:YES];
        
        //set the root view controller
        [self.window setRootViewController:self.nc];
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark
#pragma mark GoogleAppSettingDelegate 

- (NSString*)googleAppClientID {
    return @"client_id_here";
}

- (NSString*)googleAppClientSecret {
    return @"secret_here";
}


#pragma mark
#pragma mark TwitterAppSettingDelegate

-(NSString *)consumerKey{
    return @"twitter_consumer_key_here";
}

-(NSString *)consumerSecret{
    return @"twitter_consumer_secret_here";
}


#pragma mark
#pragma mark BuiltUILoginDelegate

-(void)loginSuccessWithUser:(BuiltUser *)user{
    //save the user session
    [user saveSession];
    [self checkForUserRightsAndLoadProjects];
}

/*
    Fetch Roles and from Application Role class.
    From the fetched roles get role named 'admin'
 */
- (void)checkForUserRightsAndLoadProjects{
    BuiltQuery *rolesQuery = [BuiltRole getRolesQuery];
    [rolesQuery whereKey:@"name" equalTo:@"admin"];
    
    [rolesQuery exec:^(QueryResult *result, ResponseType type) {
        if ([result getRoles] && [result getRoles].count) {
            if([[[result getRoles] objectAtIndex:0] hasUser:[[BuiltUser currentUser] uid]]){
                [self loadProjects:YES];
            }else{
                [self loadProjects:NO];
            }
        }
    } onError:^(NSError *error, ResponseType type) {
        //handle errors here
    }];
}

-(void)loginFailedWithError:(NSError *)error{
    NSLog(@"error %@",error.userInfo);
}

/*
    Load Projects from 'project' class.
    ProjectViewController extends built.io's class BuiltUITableViewController.
    Provide class uid of class whose object need to be displayed in UITableView.
    BuiltUITableViewController has in-built BuiltQuery object. One can fire methods on BuiltQuery to get filtered/sorted the BuiltQuery results.
 */
- (void)loadProjects:(BOOL)isAdmin{
    ProjectViewController *project = [[ProjectViewController alloc] initWithStyle:UITableViewStylePlain withClassUID:@"project"];
    project.isAdmin = isAdmin;
    self.nc = [[UINavigationController alloc]initWithRootViewController:project];
    [self.nc.navigationBar setTintColor:[UIColor darkGrayColor]];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        project.edgesForExtendedLayout=UIRectEdgeNone;
    }
    [self.nc setNavigationBarHidden:YES];
    [self.window setRootViewController:self.nc];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(AppDelegate *)sharedAppDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
