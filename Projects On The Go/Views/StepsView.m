//
//  StepsView.m
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "StepsView.h"
#define kSupviewGap 5.0f

@implementation StepsView

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        // Initialization code
        self.textViewDelegate = delegate;
        [self.layer setBorderWidth:1.0];
        self.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return self;
}

-(CGFloat) readjustViews {
    CGFloat top = 10;
    CGFloat left = 10;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, CGRectGetWidth(self.frame), 0)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setText:@"Name"];
    [nameLabel sizeToFit];
    [self addSubview:nameLabel];
    top = CGRectGetMaxY(nameLabel.frame) + kSupviewGap;
    
    [self.nameTextView setFrame:CGRectMake(left, top, CGRectGetWidth(self.frame) - (left * 2), 40)];
    top = CGRectGetMaxY(self.nameTextView.frame) + kSupviewGap * 2;
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, CGRectGetWidth(self.frame), 0)];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel setText:@"Description"];
    [descriptionLabel sizeToFit];
    [self addSubview:descriptionLabel];
    top = CGRectGetMaxY(descriptionLabel.frame) + kSupviewGap;
    
    [self.descriptionTextView setFrame:CGRectMake(left, top, CGRectGetWidth(self.frame) - (left * 2), 90)];
    top = CGRectGetMaxY(self.descriptionTextView.frame) + kSupviewGap * 2;
    
//    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, CGRectGetWidth(self.frame), 0)];
//    [taskLabel setText:@"Bug"];
//    [taskLabel sizeToFit];
//    [self addSubview:taskLabel];
//    top = CGRectGetMaxY(taskLabel.frame) + kSupviewGap;
//    
//    [self.taskButton setFrame:CGRectMake(left, top, CGRectGetWidth(self.frame) - (left * 2), 30)];
//    top = CGRectGetMaxY(self.taskButton.frame) + kSupviewGap;
    
    return top;
    
}

-(UITextView *)nameTextView {
    if (!_nameTextView) {
        _nameTextView = [[UITextView alloc] init];
        [_nameTextView setDelegate:self.textViewDelegate];
        [_nameTextView setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:_nameTextView];
    }
    return _nameTextView;
}

-(UITextView *)descriptionTextView {
    if (!_descriptionTextView) {
        _descriptionTextView = [[UITextView alloc] init];
        [_descriptionTextView setDelegate:self.textViewDelegate];
        [_descriptionTextView setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:_descriptionTextView];
    }
    return _descriptionTextView;
}

-(UIButton *)taskButton {
    if (!_taskButton) {
        _taskButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_taskButton addTarget:self.textViewDelegate action:@selector(taskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_taskButton setTag:1];
//        [self addSubview:_taskButton];
    }
    return _taskButton;
}


#pragma mark SetDictionaryValue 
-(NSDictionary*) getValues {
    NSMutableDictionary *valuesDictionary = [NSMutableDictionary dictionary];
    if ([self.nameTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        [valuesDictionary setValue:self.nameTextView.text forKey:TASKNAME];
    }else {
        [valuesDictionary setValue:@"" forKey:TASKNAME];
    }
    if ([self.nameTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
        [valuesDictionary setValue:self.nameTextView.text forKey:TASKDESCRIPTION];
    }else {
        [valuesDictionary setValue:@"" forKey:TASKDESCRIPTION];
    }
    [valuesDictionary setValue:[NSNumber numberWithInt:self.taskButton.tag] forKey:TASKBUG];
    return valuesDictionary;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
