//
//  UserListPickerViewController.m
//  Projects On The Go
//
//  Created by Uttam Ukkoji on 22/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "UserListPickerViewController.h"

@interface UserListPickerViewController () <U2KPickerViewDelegate>
@property (nonatomic, strong) NSMutableArray *usersArray;
@end

@implementation UserListPickerViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.usersArray = [NSMutableArray array];
        dataSource = [[U2KPickerDataSource alloc] init];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        
    }    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark Button Click 
-(void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)doneButtonClick {
    if ([self.delegate respondsToSelector:@selector(selectedUserList:)]) {
        [self.delegate selectedUserList:self.usersArray];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark U2KPickerDelegate
-(void)tokenField:(U2KPickerView *)tokenField didAddObject:(id)object {
    [self.usersArray addObject:object];
    if (self.singleUser) {
        [self doneButtonClick];
    }
}

-(void)tokenField:(U2KPickerView *)tokenField didRemoveObject:(id)object {
    [self.usersArray removeObject:object];
}

#pragma mark - View lifecycle

- (void)loadView
{   [super loadView];
    pickerView = [[U2KPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [pickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    pickerView.dataSourceDelegate = dataSource;
    pickerView.pickerDelegate = self;
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    pickerView.labelText = @"States:";
    if (!self.singleUser) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClick)];

    }
    self.view = pickerView;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
