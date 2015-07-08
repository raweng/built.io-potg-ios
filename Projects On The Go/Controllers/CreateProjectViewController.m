//
//  CreateProjectViewController.m
//  Projects On The Go
//
//  Created by Akshay Mhatre on 19/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#define MODERATOR_TEXTVIEW_TAG 99
#define MEMBER_TEXTVIEW_TAG 100

#import "CreateProjectViewController.h"
#import "THContactPickerView.h"
#import "UsersTableViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface CreateProjectViewController ()<THContactPickerDelegate, UITextViewDelegate, UserTableViewDelegate>

@property (nonatomic, strong) THContactPickerView *moderatorPickerView;
@property (nonatomic, strong) THContactPickerView *memberPickerView;
@property (nonatomic, assign) BOOL isModerator;
@property (nonatomic, assign) BOOL isMember;
@property (nonatomic, strong) NSMutableArray *moderators;
@property (nonatomic, strong) NSMutableArray *members;
@end

@implementation CreateProjectViewController

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
    
    self.isMember = NO;
    self.isModerator = NO;
    
    //the project description text view
    [self.descriptionTextView setTag:1];
    [self.descriptionTextView setDelegate:self];
    [self.descriptionTextView setReturnKeyType:UIReturnKeyDone];
    
    //picker to add moderators to a project
    self.moderatorPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moderatorLabel.frame), self.view.frame.size.width, 100)];
    self.moderatorPickerView.delegate = self;
    [self.moderatorPickerView setPlaceholderString:@"Add Moderators"];
    [self.moderatorPickerView.textView setTag:MODERATOR_TEXTVIEW_TAG];
    [self.moderatorPickerView.textView setDelegate:self];

    [self.moderatorPickerView.textView setReturnKeyType:UIReturnKeyDone];
    [self.scrollView addSubview:self.moderatorPickerView];
    
    [self.memberLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.moderatorPickerView.frame), self.view.frame.size.width, 27)];

    //picker to add members to a project
    self.memberPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.memberLabel.frame), self.view.frame.size.width, 100)];
    self.memberPickerView.delegate = self;
    [self.memberPickerView setPlaceholderString:@"Add Members"];
    [self.memberPickerView.textView setTag:MEMBER_TEXTVIEW_TAG];
    [self.memberPickerView.textView setDelegate:self];
    [self.memberPickerView.textView setReturnKeyType:UIReturnKeyDone];
    [self.scrollView addSubview:self.memberPickerView];
    
    [self.descriptionTextView becomeFirstResponder];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(done:)];
    [self.navigationItem setRightBarButtonItem:done];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(cancel:)];
    [self.navigationItem setLeftBarButtonItem:cancel];

}


- (void)done:(id)sender{
    NSMutableArray *moderatorsUIDs = [NSMutableArray array];
    NSMutableArray *membersUIDs = [NSMutableArray array];
    
    [self.moderators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
        [moderatorsUIDs addObject:[user uid]];
    }];
    
    [self.members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
        [membersUIDs addObject:[user uid]];
    }];
    
    BuiltRole *moderatorsRole = [[AppDelegate sharedAppDelegate].builtApplication roleWithName:[NSString stringWithFormat:@"%@_moderators",self.title]];
    [moderatorsRole setObject:moderatorsUIDs forKey:@"users"];
    
    BuiltRole *membersRole = [[AppDelegate sharedAppDelegate].builtApplication roleWithName:[NSString stringWithFormat:@"%@_members",self.title]];
    [membersRole setObject:membersUIDs forKey:@"users"];
    
    BuiltClass *projectClass = [[AppDelegate sharedAppDelegate].builtApplication classWithUID:@"project"];

    BuiltObject *newProject = [projectClass object];
    [newProject setObject:self.title forKey:@"name"];
    [newProject setObject:self.descriptionTextView.text forKey:@"description"];
    [newProject setReference:moderatorsRole forKey:@"moderators"];
    [newProject setReference:membersRole forKey:@"members"];
    
    MBProgressHUD *creatingProjectHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [creatingProjectHUD setLabelText:@"Creating Project..."];
    
    
    [newProject saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
        if (error == nil) {
            [creatingProjectHUD setLabelText:@"Project Created!"];
            [creatingProjectHUD hide:YES afterDelay:0.5];
            
            //moderator(s) should have read,update rights for project
            BuiltACL *projectACL = [[AppDelegate sharedAppDelegate].builtApplication acl];
            
            [[newProject objectForKey:@"moderators"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [projectACL setRoleReadAccess:YES forRoleUID:obj];
                [projectACL setRoleWriteAccess:YES forRoleUID:obj];
            }];
            //member(s) should have read right for project
            [[newProject objectForKey:@"members"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [projectACL setRoleReadAccess:YES forRoleUID:obj];
            }];
            
            [newProject setACL:projectACL];
            
            [newProject saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
                //
            }];
            
            //update member role ACL with update permission for moderators role
            [[newProject objectForKey:@"members"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                BuiltRole *memberRole = [[AppDelegate sharedAppDelegate].builtApplication roleWithUID:obj];
                [[newProject objectForKey:@"moderators"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [memberRole setObject:@{@"roles": @[@{@"update": @"true",@"read": @"true",@"uid": obj}]}
                                   forKey:@"ACL"];
                }];
                [memberRole saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
                    //
                }];
                
            }];
            
            [self performSelector:@selector(dismissAfterCreating) withObject:nil afterDelay:1.0];
        }else {
            [creatingProjectHUD setLabelText:@"Error Creating Project!"];
            [creatingProjectHUD hide:YES afterDelay:0.5];
        }
    }];
    
}

- (void)dismissAfterCreating{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didCreateProject];
    }];
}

- (void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark THContactPickerDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText{

}

-(void)contactPickerDidResize:(THContactPickerView *)contactPickerView{
    if ([contactPickerView isEqual:self.moderatorPickerView]) {
        [self.memberLabel removeFromSuperview];
        [self.memberPickerView removeFromSuperview];
        
        [self.memberLabel setFrame:CGRectMake(0, CGRectGetMaxY(contactPickerView.frame), self.view.frame.size.width, 27)];
        [self.scrollView addSubview:self.memberLabel];
        
        [self.memberPickerView setFrame:CGRectMake(0, CGRectGetMaxY(self.memberLabel.frame), self.view.frame.size.width, 100)];
        [self.scrollView addSubview:self.memberPickerView];        
    }
}

-(void)contactPickerDidRemoveContact:(id)contact forPicker:(THContactPickerView *)contactPickerView{
    if ([contactPickerView isEqual:self.moderatorPickerView]) {
        [self.moderators removeObject:[contact pointerValue]];
    }else if ([contactPickerView isEqual:self.memberPickerView]) {
        [self.members removeObject:[contact pointerValue]];
    }
}


#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return NO;
    }
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == MODERATOR_TEXTVIEW_TAG) {
        [self openUserList];
        self.isModerator = YES;
        self.isMember = NO;
        [self.scrollView setContentOffset:CGPointMake(0, self.moderatorLabel.frame.origin.y - 44) animated:YES];
    }else if (textView.tag == MEMBER_TEXTVIEW_TAG){
        [self openUserList];
        self.isMember = YES;
        self.isModerator = NO;
        [self.scrollView setContentOffset:CGPointMake(0, self.memberLabel.frame.origin.y - 44) animated:YES];
    }else if (textView.tag == 1){
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark
#pragma mark UserTableViewDelegate

-(void)didSelectUsers:(NSArray *)users{
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (self.isModerator) {
            [self.moderatorPickerView addContact:obj withName:[obj objectForKey:@"email"]];
            if (!self.moderators) {
                self.moderators = [NSMutableArray array];
            }
            [self.moderators addObject:obj];
        }else if (self.isMember){
            [self.memberPickerView addContact:obj withName:[obj objectForKey:@"email"]];
            if (!self.members) {
                self.members = [NSMutableArray array];
            }
            [self.members addObject:obj];
        }
    }];
    self.isMember = NO;
    self.isModerator = NO;
}

//open up the users table to select users from
- (void)openUserList{
    UsersTableViewController *usersTable = [[UsersTableViewController alloc]initWithStyle:UITableViewStylePlain withBuiltClass:[[AppDelegate sharedAppDelegate].builtApplication classWithUID:@"built_io_application_user"]];
    [usersTable setDelegate:self];
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:usersTable];
    [nc.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
