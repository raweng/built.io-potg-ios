//
//  TasksViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    CGPoint _containerOrigin;
}
@property(nonatomic, assign)BOOL canDeleteTask;
- (void)loadTasks:(BuiltObject *)builtObject;
@end
