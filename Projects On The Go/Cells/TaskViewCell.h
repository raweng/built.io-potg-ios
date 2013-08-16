//
//  TaskViewCell.h
//  Projects On The Go
//
//  Created by Samir Bhide on 21/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskDescriptionLabel;

- (void)loadCellData:(BuiltObject *)taskObject;
+ (CGFloat)calculateDescHeight:(BuiltObject *)taskObject;
@end
