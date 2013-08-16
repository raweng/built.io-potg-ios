//
//  AttachmentViewController.h
//  Projects On The Go
//
//  Created by Akshay Mhatre on 16/07/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachmentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *attachmentWebview;
@property (nonatomic, strong) NSString *url;
@end
