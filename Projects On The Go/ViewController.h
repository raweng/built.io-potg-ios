//
//  ViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarViewController.h"
#import "JTRevealSidebarV2Delegate.h"
@class ProjectViewController;

@interface ViewController : UIViewController<JTRevealSidebarV2Delegate, UITableViewDelegate>{
    CGPoint _containerOrigin;
}
@property (nonatomic, strong) SidebarViewController *leftSidebarViewController;
@property (nonatomic, strong) NSIndexPath *leftSelectedIndexPath;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) BuiltObject *builtObject;
@property (nonatomic, weak) ProjectViewController *projectViewController;
-(void)showInitialBugsViewWithProjectName:(BuiltObject *)builtObject;

@end
