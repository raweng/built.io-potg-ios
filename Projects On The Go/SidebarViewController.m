//
//  LeftSidebarViewController.m
//  JTRevealSidebarDemo
//
//  Created by James Apple Tang on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SidebarViewController.h"
#import "AppConstants.h"


@implementation SidebarViewController
@synthesize sidebarDelegate,sideBarMenuItems;

- (id)initWithProject:(NSMutableArray *)menu{
    self = [super init];
    if (self) {
        self.sideBarMenuItems = [NSMutableArray arrayWithArray:menu];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.sidebarDelegate respondsToSelector:@selector(lastSelectedIndexPathForSidebarViewController:)]) {
        NSIndexPath *indexPath = [self.sidebarDelegate lastSelectedIndexPathForSidebarViewController:self];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sideBarMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [self.sideBarMenuItems objectAtIndex:0];
        cell.imageView.image = [UIImage imageNamed:@"ButtonMenu"];
    }else{
        cell.textLabel.text = [self.sideBarMenuItems objectAtIndex:indexPath.row];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sidebarDelegate) {
        NSObject *object;
        
        if (indexPath != 0) {
            object = [self.sideBarMenuItems objectAtIndex:indexPath.row];
            [self.sidebarDelegate sidebarViewController:self didSelectObject:object atIndexPath:indexPath];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}

@end
