//
//  AppDelegate.h
//  Projects On The Go
//
//  Created by Akshay Mhatre on 17/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController *nc;

@property (strong, nonatomic) BuiltApplication * builtApplication;

+(AppDelegate *)sharedAppDelegate;

@end
