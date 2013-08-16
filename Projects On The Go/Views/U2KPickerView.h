//
//  U2KPickerView.h
//  U2KPicker
//
//  Created by trainee1 on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class U2KTextField;

@protocol U2KPickerViewDataSource;
@protocol U2KPickerViewDelegate;

@interface U2KPickerView : UIControl <UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate> {
    
    
    id<U2KPickerViewDelegate> pickerDelegate;
    id<U2KPickerViewDataSource> dataSourceDelegate;
    U2KTextField *textField;
    UIView *backingView;
    UIView *tokenContainer;
    NSMutableArray *tokens;
    UIFont *font;
    UITableView *resultsTable;
    NSString *labelText;
    UILabel *label;
    NSUInteger numberOfResults;
    UIView *rightView;
    
}
@property (nonatomic, retain) UIView *backingView;
@property (nonatomic, retain) U2KTextField *textField;
@property (nonatomic, retain) UIView *tokenContainer;
@property (nonatomic, retain) NSMutableArray *tokens;

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, readonly) UITableView *resultsTable;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, assign) id<U2KPickerViewDelegate> pickerDelegate;
@property (nonatomic, assign) id<U2KPickerViewDataSource> dataSourceDelegate;
@end
@protocol U2KPickerViewDataSource <NSObject>

@required
- (NSString*)tokenField:(U2KPickerView*)tokenField titleForObject:(id)anObject;
- (NSUInteger)numberOfResultsInTokenField:(U2KPickerView*)tokenField;
- (id)tokenField:(U2KPickerView*)tokenField objectAtResultsIndex:(NSUInteger)index;
- (void)tokenField:(U2KPickerView*)tokenField searchQuery:(NSString*)query;

@optional

- (UITableViewCell*)tokenField:(U2KPickerView*)tokenField
                     tableView:(UITableView*)tableView
                  cellForIndex:(NSUInteger)index;
- (CGFloat)resultRowsHeightForTokenField:(U2KPickerView*)tokenField;

@end


@protocol U2KPickerViewDelegate <NSObject>

@optional
/* Called when the user adds an object from the results list. */
- (void)tokenField:(U2KPickerView*)tokenField didAddObject:(id)object;
/* Called when the user deletes an object from the token field. */
- (void)tokenField:(U2KPickerView*)tokenField didRemoveObject:(id)object;
- (void)tokenFieldDidEndEditing:(U2KPickerView*)tokenField;
/* Called when the user taps the 'enter'. */
- (void)tokenFieldDidReturn:(U2KPickerView*)tokenField;
- (BOOL)tokenField:(U2KPickerView*)tokenField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string;

@end
