//
//  CreateBugViewController.m
//  Projects On The Go
//
//  Created by Samir Bhide on 20/06/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import "CreateBugViewController.h"
#import "MBProgressHUD.h"
#import "UsersTableViewController.h"
#import "THContactPickerView.h"
#import "FilesViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "AppConstants.h"

#define MODERATOR_TEXTVIEW_TAG 1
#define BUG_TITLE_TAG 2
#define BUG_DESCRIPTION_TAG 3
#define TH_CONTACT_PICKER_TEXTVIEW_TAG_IMAGE 4

#define CONTACT_PICKER 500
#define IMAGE_PICKER 501

@interface CreateBugViewController () <UITextViewDelegate,UIPickerViewDelegate, UIActionSheetDelegate, UserTableViewDelegate, THContactPickerDelegate, FileViewerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UITextView *currentTextView;
    MBProgressHUD *creatingBugHUD;
}
@property (nonatomic, strong)NSArray *severity;
@property (nonatomic, strong)NSArray *reproducible;
@property (nonatomic, strong)UIPickerView *pickerView;
@property (nonatomic, strong)UIDatePicker *datePicker;
@property (nonatomic, strong)UIActionSheet *actionSheet;
@property (nonatomic, strong)UIToolbar *pickerDateToolbar;
@property (nonatomic, strong)NSString *selectedItem;
@property (nonatomic, strong)NSMutableArray *datasource;
@property (weak, nonatomic) IBOutlet UITextView *bugTitle;
@property (weak, nonatomic) IBOutlet UITextView *bugDescription;
@property (nonatomic, strong)NSDate *bugDate;
@property (nonatomic, strong)NSString *bugSeverity;
@property (nonatomic, strong)NSString *bugReproducible;
@property (nonatomic, strong)UILabel *assigneeLabel;
@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) THContactPickerView *imagePickerView;
@property (nonatomic, strong) NSMutableArray *assignees;
@property (nonatomic, strong) NSMutableArray *imageAttachments;
@property (nonatomic, strong) NSMutableArray *imagesNameList;

@property (nonatomic, strong) UIScrollView *attachmentsView;

@property (nonatomic, strong) UIActionSheet *pickImageActionSheet;
@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) BuiltUpload *file;
@property (nonatomic, assign) BOOL isFileUpload;
@end

@implementation CreateBugViewController
@synthesize bugProperties;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UILabel *)assigneeLabel{
    if (!_assigneeLabel) {
        _assigneeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_assigneeLabel setText:@"Assignee:"];
        [_assigneeLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_assigneeLabel setBackgroundColor:[UIColor clearColor]];
        [_assigneeLabel setTextColor:[UIColor blackColor]];
    }
    return _assigneeLabel;
}

-(THContactPickerView *)contactPickerView{
    if (!_contactPickerView) {
        _contactPickerView = [[THContactPickerView alloc]initWithFrame:CGRectZero];
        _contactPickerView.tag = CONTACT_PICKER;
        _contactPickerView.delegate = self;
        _contactPickerView.textView.delegate = self;
        [_contactPickerView setPlaceholderString:@"Add Moderators"];
        _contactPickerView.textView.tag = MODERATOR_TEXTVIEW_TAG;
        [_contactPickerView setBackgroundColor:[UIColor lightGrayColor]];
        
    }
    return _contactPickerView;
}
-(THContactPickerView *)imagePickerView{
    if (!_imagePickerView) {
        _imagePickerView = [[THContactPickerView alloc]initWithFrame:CGRectZero];
        _imagePickerView.tag = IMAGE_PICKER;
        _imagePickerView.delegate = self;
        _imagePickerView.textView.delegate = self;
//        [_imagePickerView setPlaceholderString:@"Add Moderators"];
        _imagePickerView.textView.tag = TH_CONTACT_PICKER_TEXTVIEW_TAG_IMAGE;
        [_imagePickerView setBackgroundColor:[UIColor lightGrayColor]];
        
    }
    return _imagePickerView;
}

-(UIScrollView *)attachmentsView{
    if (!_attachmentsView) {
        _attachmentsView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        [_attachmentsView setBackgroundColor:[UIColor clearColor]];
        _attachmentsView.showsHorizontalScrollIndicator = NO;
        _attachmentsView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
        _attachmentsView.scrollEnabled = YES;
        _attachmentsView.pagingEnabled = YES;
    }
    return _attachmentsView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClick)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSelf)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.file = [[AppDelegate sharedAppDelegate].builtApplication upload];
    self.isFileUpload = NO;
    
    self.bugTitle.tag = BUG_TITLE_TAG;
    self.bugDescription.tag = BUG_DESCRIPTION_TAG;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body_bg"]]];
    
    self.datasource = [NSMutableArray array];
    
    self.severity = [NSArray arrayWithObjects:@"Show Stopper",@"Critical",@"Major",@"Minor", nil];
    self.reproducible = [NSArray arrayWithObjects:@"Always",@"Sometimes",@"Rarely",@"Unable", nil];
    
    self.title = @"Create a Bug";
    
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"How many?"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.delegate = self;
    
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
//    [self.datePicker setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.width / 2)];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker addTarget:self
                        action:@selector(changeDateInLabel:)
              forControlEvents:UIControlEventValueChanged];
    
    self.pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
    [self.pickerDateToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DatePickerDoneClick)];
    [barItems addObject:doneBtn];
    
    [self.pickerDateToolbar setItems:barItems animated:YES];
    
    [self addSelImageList];
    
    [self addContactsView];
    
    [self.mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.contactPickerView.frame) + 5)];
    
    [self.bugTitle becomeFirstResponder];
}

- (void)addSelImageList{
    [self.imagePickerView setFrame:CGRectMake(20, CGRectGetMaxY(self.attachmentLabel.frame)+ 5, self.view.frame.size.width - 40, 100)];
    [self.attachButton setFrame:CGRectMake(20, CGRectGetMaxY(self.imagePickerView.frame) + 5, 75, 30)];
    [self.mainScrollView addSubview:self.imagePickerView];
}

- (void)addContactsView{
    
    [self.assigneeLabel setFrame:CGRectMake(20, CGRectGetMaxY(self.attachButton.frame) + 10, self.view.frame.size.width - 40, 18)];
    [self.contactPickerView setFrame:CGRectMake(20, CGRectGetMaxY(self.assigneeLabel.frame) + 5, self.view.frame.size.width - 40, 150)];                                                
    [self.mainScrollView addSubview:self.assigneeLabel];
    [self.mainScrollView addSubview:self.contactPickerView];
}

- (void)loadAttachmentsThumbnails{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 ************************************************************************************************************************************
    Bug creation.
    A Bug is created by creating object of Bugs class.
    An ACL (Access Control List) is set through BuiltACL to BuiltObject so that users under role 'members' have read-only access while 
        users under role 'moderators' have read/write/delete access.
 ************************************************************************************************************************************
 */

#pragma mark Button Clicks
-(void) doneButtonClick {
    //create bug object
    BuiltObject *bug = [[[AppDelegate sharedAppDelegate].builtApplication classWithUID:CLASSUID_BUGS] object];
    
    creatingBugHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [creatingBugHUD setLabelText:@"Creating Bug..."];
    
    if (self.imageAttachments.count > 0 && self.imagesNameList.count > 0) {
        NSMutableArray *UIDs = [NSMutableArray array];
        [self.imageAttachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //add image
//            FileObject *fileObject = [FileObject fileObject];
//            [fileObject setImage:obj forKey:[self.imagesNameList objectAtIndex:idx]];
//            
//            [self.file addFile:fileObject forKey:[self.imagesNameList objectAtIndex:idx]];
            
            BuiltUpload *image = [[AppDelegate sharedAppDelegate].builtApplication upload];
            [image setImage:obj forKey:[self.imagesNameList objectAtIndex:idx]];
            [image saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
                if (error == nil) {
                    [UIDs addObject:image.uid];
                    if (idx == (self.imageAttachments.count - 1)) {
                        if (UIDs.count > 0) {
                            [bug setObject:UIDs forKey:@"attachments"];
                        }
                        [self createObject:bug];
                    }
                }else {
                    [self createObject:bug];
                }
            }];
        }];
        
        //upload attachments if any
//        [self.file saveOnSuccess:^(NSDictionary *fileUploadDictionary) {
//            NSMutableArray *UIDs = [NSMutableArray array];
//            
//            [fileUploadDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                FileObject *fileObj = (FileObject *)obj;
//                [UIDs addObject:[fileObj uid]];
//            }];
//            if (UIDs.count > 0) {
//                [bug setObject:UIDs forKey:@"attachments"];
//            }
//            [self createObject:bug];
//        } onError:^(NSError *error) {
//            [self createObject:bug];
//        }];        
    }else{
        [self createObject:bug];
    }    
}

- (void)createObject:(BuiltObject *)bug{
    //set values for fields
    [bug setObject:self.bugTitle.text forKey:@"name"];
    [bug setObject:self.bugDescription.text forKey:@"description"];
    [bug setObject:self.bugReproducible forKey:@"reproducible"];
    [bug setObject:self.bugDate forKey:@"due_date"];
    [bug setObject:self.bugSeverity forKey:@"severity"];
    [bug setObject:@"Open" forKey:@"status"];
    [bug setReference:self.project.uid forKey:@"project"];
    
    NSMutableArray *useridsArray = [NSMutableArray array];
    
    [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
        [useridsArray addObject:[user uid]];
    }];
    
    //set all the user ids to assignees field
    [bug setReference:useridsArray forKey:@"assignees"];
    
    /*
        BuiltACL object is created and ACL are set for Roles and users.
        Here Read access is assigned to users under role 'members' with BuiltACL's `setRoleReadAccess` method.
        Read/Write/Delete access is assigned to users under role 'moderators' with `setRoleReadAccess` `setRoleWriteAccess` and `setRoleDeleteAccess` respectively.
        Always make sure that we set proper ACL's when creating objects.
     */
    
    BuiltACL *bugACL = [[AppDelegate sharedAppDelegate].builtApplication acl];
    
    //members have read access for a bug
    [[self.project objectForKey:@"members"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [bugACL setRoleReadAccess:YES forRoleUID:obj];
    }];
    
    //moderators have read, update, delete access for a bug
    [[self.project objectForKey:@"moderators"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [bugACL setRoleReadAccess:YES forRoleUID:obj];
        [bugACL setRoleWriteAccess:YES forRoleUID:obj];
        [bugACL setRoleDeleteAccess:YES forRoleUID:obj];
    }];
    
    //assignees have update(write) access for the bug
    [self.assignees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BuiltObject *user = (BuiltObject *)obj;
        [bugACL setWriteAccess:YES forUserId:user.uid];
        [bugACL setReadAccess:YES forUserId:user.uid];
    }];
    
    //set ACL
    [bug setACL:bugACL];
    
    //save bug
    
    [bug saveInBackgroundWithCompletion:^(ResponseType responseType, NSError *error) {
        if (error == nil) {
            [creatingBugHUD setLabelText:@"Bug Created!"];
            [creatingBugHUD hide:YES afterDelay:0.5];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.imagesNameList removeAllObjects];
            [self.imageAttachments removeAllObjects];
        }else {
            [creatingBugHUD setLabelText:@"Error Creating Bug!"];
            [creatingBugHUD hide:YES afterDelay:0.5];
        }
    }];
    
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    currentTextView = textView;
    if (textView.tag == MODERATOR_TEXTVIEW_TAG) {
        [self openUserList];
        [self.mainScrollView setContentOffset:CGPointMake(0, self.contactPickerView.frame.origin.y - 44) animated:YES];
    }else if (textView.tag == BUG_TITLE_TAG){
        [self.mainScrollView setContentOffset:CGPointMake(0, self.bugTitle.frame.origin.y - 44) animated:YES];
    }else if (textView.tag == BUG_DESCRIPTION_TAG){
        [self.mainScrollView setContentOffset:CGPointMake(0, self.bugDescription.frame.origin.y - 44) animated:YES];
    }else if (textView.tag == TH_CONTACT_PICKER_TEXTVIEW_TAG_IMAGE){
        [self.mainScrollView setContentOffset:CGPointMake(0, self.attachmentsView.frame.origin.y - 44) animated:YES];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return NO;
    }    
    return YES;
}

#pragma mark KeyBoard NotificationHandler

-(void)keyboardShow:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainScrollView.frame), CGRectGetHeight(self.view.frame) - kKeyBoardShowHeight)];
    }];
    
}

-(void)keyboardHide:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainScrollView.frame), CGRectGetHeight(self.view.frame))];
    }];
    
}

#pragma mark UITapGestureSelector

- (IBAction)hadleTap:(id)sender {
    [currentTextView resignFirstResponder];
    
}

- (void)changeDateInLabel:(id)sender{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	NSString *selDate = [NSString stringWithFormat:@"%@",
                         [df stringFromDate:self.datePicker.date]];
    self.selectedItem = selDate;
}

#pragma mark UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedItem = [self.datasource objectAtIndex:row];
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.datasource.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.datasource objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 300;
}

- (IBAction)attachAction:(id)sender {
    self.pickImageActionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    self.pickImageActionSheet.title = @"Attach Photo";
    [self.pickImageActionSheet showInView:self.view];
}

- (IBAction)severityAction:(id)sender {
    [self setBugProperties:SEVERITY];
    
    if ([[self.actionSheet subviews]containsObject:self.pickerView] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }
    
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.severity];
    
    [self.pickerView reloadAllComponents];
    
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.pickerView];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
    
    self.selectedItem = [self.datasource objectAtIndex:[self.pickerView selectedRowInComponent:0]];
}

- (IBAction)reproducibleAction:(id)sender {
    [self setBugProperties:REPRODUCIBLE];
    
    if ([[self.actionSheet subviews]containsObject:self.pickerView] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.reproducible];
    
    [self.pickerView reloadAllComponents];
    
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.pickerView];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
    
    self.selectedItem = [self.datasource objectAtIndex:[self.pickerView selectedRowInComponent:0]];
}

- (IBAction)dueDateAction:(id)sender {
    [self setBugProperties:DUE_DATE];
    
    if ([[self.actionSheet subviews]containsObject:self.datePicker] && [[self.actionSheet subviews]containsObject:self.pickerDateToolbar]) {
        [self.pickerDateToolbar removeFromSuperview];
        [self.pickerView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:self.reproducible];
    
    [self.actionSheet addSubview:self.pickerDateToolbar];
    [self.actionSheet addSubview:self.datePicker];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 475)];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	NSString *selDate = [NSString stringWithFormat:@"%@",
                         [df stringFromDate:self.datePicker.date]];
    self.selectedItem = selDate;
}

- (void)DatePickerDoneClick{
    if (self.bugProperties == SEVERITY) {
        [self.severityButton setTitle:self.selectedItem forState:UIControlStateNormal];

        self.bugSeverity = self.selectedItem;
    }else if (self.bugProperties == REPRODUCIBLE){
        [self.reproducibleButton setTitle:self.selectedItem forState:UIControlStateNormal];
        
        self.bugReproducible = self.selectedItem;
    }else if (self.bugProperties == DUE_DATE){
        [self.dueDateButton setTitle:self.selectedItem forState:UIControlStateNormal];
        
        self.bugDate = self.datePicker.date;
    }
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {

}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    
}

- (void)contactPickerDidRemoveContact:(id)contact {
    
}

-(void)contactPickerDidRemoveContact:(id)contact forPicker:(THContactPickerView *)contactPickerView{
    if (contactPickerView.tag == CONTACT_PICKER) {
        [self.assignees removeObject:[contact pointerValue]];
    }else if (contactPickerView.tag == IMAGE_PICKER){
        [self.imageAttachments removeObject:[contact pointerValue]];
        [self.imagesNameList removeObject:[contact pointerValue]];
    }
    
}

#pragma mark
#pragma mark UserTableViewDelegate

-(void)didSelectUsers:(NSArray *)users{

    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.contactPickerView addContact:obj withName:[obj objectForKey:@"email"]];
            if (!self.assignees) {
                self.assignees = [NSMutableArray array];
            }
            [self.assignees addObject:obj];
    }];
}

#pragma mark
//open up the users table to select users from
- (void)openUserList{
    UsersTableViewController *usersTable = [[UsersTableViewController alloc]initWithStyle:UITableViewStylePlain withBuiltClass:[[AppDelegate sharedAppDelegate].builtApplication classWithUID:@"built_io_application_user"]];
    usersTable.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:usersTable];
    [nc.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self showImagePicker:0];
    }else if (buttonIndex == 1){
        [self showImagePicker:1];
    }
}

#pragma mark
- (void)showImagePicker:(NSInteger)index{
    self.picker = [[UIImagePickerController alloc] init];
    
    self.picker.delegate = self;
    
    if (index == 1) {
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if (index == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No camera found!" message:@"Are you sure you have a camera?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil];
            [alert show];
        }
    }
    [self presentViewController:self.picker animated:YES completion:^{
        
    }];
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *imageClicked = [info objectForKey:UIImagePickerControllerOriginalImage];
		
        if (imageClicked) {
            
            NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
            
            // define the block to call when we get the asset based on the url (below)
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
            {
                ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
                if (!self.imagesNameList) {
                    self.imagesNameList = [NSMutableArray array];
                }
                [self.imagesNameList addObject:[imageRep filename]];
                [self.imagePickerView addContact:imageClicked withName:[imageRep filename]];
                if (!self.imageAttachments) {
                    self.imageAttachments = [NSMutableArray array];
                }
                [self.imageAttachments addObject:imageClicked];
                self.isFileUpload = YES;
                [self.picker dismissViewControllerAnimated:YES completion:nil];
            };
            
            // get the asset library and fetch the asset based on the ref url (pass in block above)
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];

		} else {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Error loading image!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
		}
	}
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

@end
