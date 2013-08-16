//
//  UsersTableViewController.m
//  Projects On The Go
//
//  Created by Akshay Mhatre on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "UsersTableViewController.h"

@interface UsersTableViewController ()

@property (nonatomic, strong) NSMutableArray *selectedUsers;
@end

@implementation UsersTableViewController

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Users";
        self.enablePullToRefresh = YES;
        self.fetchLimit = 99;
        [self.builtQuery setCachePolicy:CACHE_ELSE_NETWORK];
    }
    return self;
}

-(void)viewDidLoad{
    [self refresh];
    
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
    [self.delegate didSelectUsers:self.selectedUsers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath builtObject:(BuiltObject *)builtObject{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@",[builtObject objectForKey:@"email"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    BuiltObject *user = [self builtObjectAtIndexPath:indexPath];
    if (!self.selectedUsers) {
        self.selectedUsers = [NSMutableArray array];
    }
    if ([self.selectedUsers containsObject:user]){ 
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedUsers removeObject:user];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedUsers addObject:user];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
