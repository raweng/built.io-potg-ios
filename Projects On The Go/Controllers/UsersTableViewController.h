//
//  UsersTableViewController.h
//  Projects On The Go
//
//  Created by Akshay Mhatre on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <BuiltIO/BuiltIO.h>

@protocol UserTableViewDelegate <NSObject>
- (void)didSelectUsers:(NSArray *)users;
@end


@interface UsersTableViewController : BuiltUITableViewController

@property (nonatomic, strong) id <UserTableViewDelegate> delegate;

@end

