//
//  CommentsViewController.h
//  Projects On The Go
//
//  Created by Samir Bhide on 04/07/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentsDelegate <NSObject>
- (void)commentDone;
@end

@interface CommentsViewController : UIViewController{
    __weak id <CommentsDelegate> delegate;
}
@property (nonatomic, weak) id <CommentsDelegate> delegate;
@property (strong, nonatomic) BuiltObject *builtObject;
@property (strong, nonatomic) BuiltObject *project;
- (void)loadData;
@end
