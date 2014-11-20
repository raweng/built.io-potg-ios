//
//  AttachmentViewController.m
//  Projects On The Go
//
//  Created by Akshay Mhatre on 16/07/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "AttachmentViewController.h"

@interface AttachmentViewController ()

@end

@implementation AttachmentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    //load attachment url in webview
    [self.attachmentWebview setScalesPageToFit:YES];
    [self.attachmentWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(close)];
    [self.navigationItem setRightBarButtonItem:close];
}

- (void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
