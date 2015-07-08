//
//  ProjectViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "ProjectViewController.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "AppConstants.h"
#import "CreateProjectViewController.h"

/* ProjectViewController
    Lists all the projects from 'project' class.
 
 */


@interface ProjectViewController ()<UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate, CreateProjectDelegate>

@end

@implementation ProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Projects";

    [self refresh];
    [self.navigationController setNavigationBarHidden:NO];

    if (self.isAdmin) {//if user is admin show create project button
        UIBarButtonItem *addProject = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addProject:)];
        [self.navigationItem setRightBarButtonItem:addProject];
    }
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg.png"]]];
}

//UIAlertView with textfield to input the name of the project
- (void)addProject:(id)sender{
    UIAlertView *projectNameAlert = [[UIAlertView alloc]initWithTitle:@"Enter Project Name"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"OK", nil];
    [projectNameAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [projectNameAlert setTag:1];
    [projectNameAlert setDelegate:self];
    [projectNameAlert show];
}

#pragma mark
#pragma mark CreateProjectDelegate

//refresh after project is created so that the newly created project appears in the table
-(void)didCreateProject{
    [self refresh];
}

#pragma mark
#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            CreateProjectViewController *createProject = [[CreateProjectViewController alloc]init];
            [createProject setDelegate:self];
            UINavigationController *createProjectNavigationController = [[UINavigationController alloc]initWithRootViewController:createProject];
            [createProjectNavigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
            createProject.title = [alertView textFieldAtIndex:0].text;
            [self presentViewController:createProjectNavigationController animated:YES completion:nil];
        }
    }
}

#pragma mark
#pragma mark BuiltUITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath builtObject:(BuiltObject *)builtObject{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"bullet_black"];
    cell.textLabel.text = [builtObject objectForKey:@"name"];
    
    return cell;
}

#pragma mark
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewController *viewController = [[ViewController alloc]init];
    viewController.builtObject = [self builtObjectAtIndexPath:indexPath];
    viewController.projectViewController = self;
    [[AppDelegate sharedAppDelegate].nc pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
