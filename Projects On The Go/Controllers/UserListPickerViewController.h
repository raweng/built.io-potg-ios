//
//  UserListPickerViewController.h
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 22/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "U2KPickerView.h"
#import "U2KPickerDataSource.h"

@protocol UserListDelegate <NSObject>

-(void)selectedUserList:(NSArray*)usersArray;

@end

@interface UserListPickerViewController : UIViewController {
    U2KPickerView *pickerView;
    U2KPickerDataSource *dataSource;
    UIView *containerView;
}
@property (nonatomic, assign) BOOL singleUser;
@property (nonatomic, assign) id<UserListDelegate>delegate;
@end
