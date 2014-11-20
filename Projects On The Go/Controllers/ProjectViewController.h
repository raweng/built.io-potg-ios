//
//  ProjectViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarViewController.h"
#import "JTRevealSidebarV2Delegate.h"

@interface ProjectViewController : BuiltUITableViewController{
    CGPoint _containerOrigin;
}
@property (nonatomic, assign) BOOL isAdmin;
@end
