//
//  DateViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "DateViewController.h"

@interface DateViewController ()
@property(nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation DateViewController
@synthesize date;
@synthesize datePickerDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.datePicker = [[UIDatePicker alloc]init];
    [self.datePicker setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.width / 2)];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker addTarget:self
                   action:@selector(changeDateInLabel:)
         forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSelf)];
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeDateInLabel:(id)sender{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
    if (date == START_DATE) {
        [self.datePickerDelegate startDateSelected:self.datePicker.date];
    }else if (date == END_DATE){
        [self.datePickerDelegate endDateSelected:self.datePicker.date];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
