//
//  AmericanStatesDataSource.m
//  U2KPickerView
//
//  Created by Arash Payan on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "U2KPickerDataSource.h"

@implementation U2KPickerDataSource

- (id)init {
    self = [super init];
    if (self) {
        states = [[NSMutableArray alloc] initWithObjects:@"Nishant 0001",
                  @"Kunal, 0002",
                  @"Kunal, 0010",
                  @"Bhuvan, 0017",
                  @"Sobin, 0013",
                  @"Sachindra Mani, 0029",
                  @"Priya, 0054",
                  @"Hemlata, 0023",
                  @"Pritesh, 0026",
                  @"Aamod, 0027",
                  @"Suvish, 0042",
                  @"Ashish, 0051",
                  @"Gaurav, 0053",
                  @"Bharat, 0004",
                  @"Nikhil, 0003",
                  @"Anoop, 0006",
                  @"Imran, 0011",
                  @"Nikhil, 0009",
                  @"Ashwini, 0016",
                  @"Nasreen, 0024",
                  @"Pranjal, 0036",
                  @"Nidin, 0038",
                  @"Swapneel, 0039",
                  @"Gautam, 0021",
                  @"Nishant, 0018",
                  @"Mayank, 0008",
                  @"Ninad, 0028",
                  @"Abhijit, 0055",
                  @"Rohit, 0005",
                  @"Harshal, 0014",
                  @"Dhaval, 0020",
                  @"Srushti, 0022",
                  @"Rohit, 0025",
                  @"Prathamesh, 0043",
                  @"Riddhi, 0044",
                  @"Reefaq, 0019",
                  @"Akshay, 0032",
                  @"Sunil, 0034",
                  @"Bostan, 0035",
                  @"Prachi, 0037",
                  @"Uttam, 0045",
                  @"Nikhil, 0046",
                  @"Rahul, 0047",
                  @"Samir, 0049",
                  @"Pramod, 0052",
                  @"Nilesh, 0031",
                  @"Angat, 0057",
                  nil];
        
        results = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [states release];
    [results release];
    
    [super dealloc];
}

#pragma mark - U2KPickerViewDataSource

- (NSString*)tokenField:(U2KPickerView *)tokenField titleForObject:(id)anObject {
    /* Because the object representing each label is itself a string, we just return
     the object itself. */
    return (NSString*)anObject;
}

- (NSUInteger)numberOfResultsInTokenField:(U2KPickerView *)tokenField {
    return [results count];
}

- (id)tokenField:(U2KPickerView *)tokenField objectAtResultsIndex:(NSUInteger)index {
    return [results objectAtIndex:index];
}

- (void)tokenField:(U2KPickerView *)tokenField searchQuery:(NSString *)query {
    [results removeAllObjects];
    
    for (NSString *state in states)
    {
        // check each state to see if the query string is anywhere to be found in there
        if ([state rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            // it's in there, so add this state to our results set
            [results addObject:state];
        }
    }
}

@end
