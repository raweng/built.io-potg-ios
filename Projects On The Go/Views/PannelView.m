//
//  PannelView.m
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 24/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "PannelView.h"

@implementation PannelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(UITableView *)pannedlTableView {
    if (!_pannedlTableView) {
        _pannedlTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStylePlain];
        _pannedlTableView.delegate = self;
        _pannedlTableView.dataSource = self;
        [self addSubview:_pannedlTableView];
    }
    return _pannedlTableView;
}

-(void)readjustView {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.pannedlTableView setFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(getNumberOfRows)]) {
        return 1;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getNumberOfRows)]) {
        return [self.delegate getNumberOfRows];
    }
    return 0;
}

#pragma mark
#pragma mark BuiltUITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    BuiltObject *builtObject = [self.delegate getObjectForIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"bullet_black"];
    cell.textLabel.text = [builtObject objectForKey:@"name"];
    return cell;
}

#pragma mark
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(selectedIndexPath:)]) {
        [self.delegate selectedIndexPath:indexPath];
    }
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
