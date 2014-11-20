//
//  BugCommentsCell.h
//  Projects On The Go
//
//  Created by Samir Bhide on 21/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugCommentsCell : UITableViewCell
@property (nonatomic, strong) UILabel *commentContentLabel;
@property (nonatomic, strong) UILabel *createdDateLabel;

- (void)loadCommentData:(BuiltObject *)builtObject;
@end
