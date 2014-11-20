//
//  BugTableViewCell.h
//  Projects On The Go
//
//  Created by Samir Bhide on 18/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *severityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *reproducableLabel;
@property (weak, nonatomic) IBOutlet UILabel *bugTitleLabel;
@end
