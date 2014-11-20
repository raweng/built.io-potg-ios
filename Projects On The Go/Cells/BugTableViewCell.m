//
//  BugTableViewCell.m
//  Projects On The Go
//
//  Created by Samir Bhide on 18/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "BugTableViewCell.h"

@implementation BugTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)drawRect:(CGRect)rect{
    
}

@end
