//
//  BugCommentsCell.m
//  Projects On The Go
//
//  Created by Samir Bhide on 21/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "BugCommentsCell.h"
#import "AppUtils.h"

@interface BugCommentsCell()
@property (nonatomic, strong) UILabel *noCommentsLabel;
@end

@implementation BugCommentsCell
@synthesize commentContentLabel,createdDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        // Initialization code
    }
    return self;
}

-(UILabel *)noCommentsLabel{
    if (!_noCommentsLabel) {
        _noCommentsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_noCommentsLabel setBackgroundColor:[UIColor clearColor]];
        [_noCommentsLabel setFont:[UIFont systemFontOfSize:15.0]];
        _noCommentsLabel.textAlignment = NSTextAlignmentCenter;
        [_noCommentsLabel setText:@"No Comments"];
        [_noCommentsLabel setTextColor:[UIColor lightGrayColor]];
        [self addSubview:_noCommentsLabel];
    }
    return _noCommentsLabel;
}

-(UILabel *)commentContentLabel{
    if (!commentContentLabel) {
        commentContentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        commentContentLabel.numberOfLines = 0;
        [commentContentLabel setFont:[UIFont systemFontOfSize:13.0]];
        [commentContentLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:commentContentLabel];
    }
    return commentContentLabel;
}

-(UILabel *)createdDateLabel{
    if (!createdDateLabel) {
        createdDateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        createdDateLabel.numberOfLines = 1;
        [createdDateLabel setFont:[UIFont systemFontOfSize:11.0]];
        [createdDateLabel setTextColor:[UIColor blueColor]];
        [createdDateLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:createdDateLabel];
    }
    return createdDateLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadCommentData:(BuiltObject *)builtObject{
    if (builtObject == nil) {
        [self.commentContentLabel setHidden:YES];
        [self.createdDateLabel setHidden:YES];
        [self.noCommentsLabel setHidden:NO];
    }else{
        [self.commentContentLabel setHidden:NO];
        [self.createdDateLabel setHidden:NO];
        [self.noCommentsLabel setHidden:YES];

        self.commentContentLabel.text = [builtObject objectForKey:@"content"];
        self.createdDateLabel.text = [NSString stringWithFormat:@"Created At: %@",[AppUtils convertGMTtoLocal:[builtObject objectForKey:@"created_at"]]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat yPOS = 0.0;
    
    [self.noCommentsLabel setFrame:CGRectMake(0, 0, self.frame.size.width, 18)];
    
    [self.commentContentLabel setFrame:CGRectMake(5, 5, self.frame.size.width, 0)];
    [self.commentContentLabel sizeToFit];
    [self.commentContentLabel setFrame:CGRectMake(5, 5, self.frame.size.width, self.commentContentLabel.frame.size.height)];
    yPOS = CGRectGetMaxY(self.commentContentLabel.frame);
    
    [self.createdDateLabel setFrame:CGRectMake(15, yPOS + 5, self.frame.size.width - 30, 15)];
    
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    
    self.commentContentLabel.text = nil;
}

@end
