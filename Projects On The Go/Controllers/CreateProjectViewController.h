//
//  CreateProjectViewController.h
//  Projects On The Go
//
//  Created by Akshay Mhatre on 19/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CreateProjectDelegate <NSObject>

- (void)didCreateProject;

@end

@interface CreateProjectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *moderatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberLabel;
@property (nonatomic, strong) id <CreateProjectDelegate> delegate;
@end
