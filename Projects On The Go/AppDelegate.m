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

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Built initialization
   #error Enter Built.io application APIKEY
   self.builtApplication = [Built applicationWithAPIKey:@"APIKEY"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];

    // ----------------------------------------------------------------------------
    // Get BuiltUser Object and check whether user is logged in.
    // If User is not logged in take to BuiltUILoginController otherwise load any other ViewController
    // ----------------------------------------------------------------------------
    BuiltUser *user = [self.builtApplication currentUser];
    
    if (user) {
        [self checkForUserRightsAndLoadProjects];
    }else{//if there is no user logged in present the login controller
        BuiltUILoginController *login = [[BuiltUILoginController alloc]initWithNibName:nil bundle:nil];
        login.builtApplication =self.builtApplication;
        
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
    #warning enter client id
    return @"google_client_id_here";
}

- (NSString*)googleAppClientSecret {
    #warning enter client secret
    return @"google_secret_here";
}


#pragma mark
#pragma mark TwitterAppSettingDelegate

-(NSString *)consumerKey{
    #warning enter consumer key
    return @"twitter_consumer_key_here";
}

-(NSString *)consumerSecret{
    #warning enter consumer secret
    return @"twitter_consumer_secret_here";
}


#pragma mark
#pragma mark BuiltUILoginDelegate

-(void)loginSuccessWithUser:(BuiltUser *)user{
    //save the user session
    [user setAsCurrentUser];
    [self checkForUserRightsAndLoadProjects];
}

/*
    Fetch Roles and get role named 'admin'
 */
- (void)checkForUserRightsAndLoadProjects{
    BuiltQuery *rolesQuery = [[self.builtApplication roleWithName:@"admin"] query];
    [rolesQuery whereKey:@"name" equalTo:@"admin"];
    
    [rolesQuery execInBackground:^(ResponseType type, QueryResult *result, NSError *error) {
        if (error == nil) {
            if ([result getRoles] && [result getRoles].count) {
                if([[[result getRoles] objectAtIndex:0] hasUser:[[self.builtApplication currentUser] uid]]){
                    [self loadProjects:YES];
                }else{
                    [self loadProjects:NO];
                }
            }
        }else {
            //error info
        }
    }];

}

-(void)loginFailedWithError:(NSError *)error{
    NSLog(@"error %@",error.userInfo);
}

/*
    Load Projects from 'project' class.
    ProjectViewController extends built.io's class BuiltUITableViewController.
    Provide class uid of class whose object need to be displayed.
    BuiltUITableViewController has in-built BuiltQuery object. One can fire methods on BuiltQuery to get filtered/sorted the BuiltQuery results.
 */
- (void)loadProjects:(BOOL)isAdmin{
    ProjectViewController *project = [[ProjectViewController alloc] initWithStyle:UITableViewStylePlain withBuiltClass:[self.builtApplication classWithUID:@"project"]];
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
