//
//  BugDetailViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 19/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugDetailViewController : UIViewController
@property (nonatomic, strong) BuiltObject *project;
@property (nonatomic, assign) BOOL canDeleteBug;
- (void)loadData:(BuiltObject *)bObject;
- (void)prepareViews;
@end
