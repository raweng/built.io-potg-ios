//
//  PannelView.h
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 24/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PannelDelegate <NSObject>

-(BuiltObject*)getObjectForIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)getNumberOfRows;
-(void)selectedIndexPath:(NSIndexPath*)indexPath;

@end

@interface PannelView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *pannedlTableView;
@property (nonatomic, weak) id<PannelDelegate>delegate;
-(void)readjustView;
@end
