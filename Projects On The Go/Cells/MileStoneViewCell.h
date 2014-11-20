//
//  MileStoneViewCell.h
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MileStoneViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *milestoneTitle;
@property (weak, nonatomic) IBOutlet UILabel *milestoneDescription;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;

@end
