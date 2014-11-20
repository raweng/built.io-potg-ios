//
//  AmericanStatesDataSource.h
//  APTokenField
//
//  Created by Arash Payan on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "U2KPickerView.h"
#import <Foundation/Foundation.h>

@interface U2KPickerDataSource : NSObject <U2KPickerViewDataSource> {
    NSMutableArray *states;
    NSMutableArray *results;
}

@end
