//
//  TaskDetailViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 29/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskDetailViewController : UIViewController
@property (nonatomic, strong) BuiltObject *taskObject;
@property(nonatomic, assign)BOOL canDeleteTask;
-(void)loadTaskDetails;
@end
