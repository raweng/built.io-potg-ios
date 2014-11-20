//
//  FilesViewController.m
//  tibbr
//
//  Created by Reefaq on 14/10/12.
//  Copyright (c) 2012 Reefaq. All rights reserved.
//

#import "FilesViewController.h"
#import "AppUtils.h"
#import <MobileCoreServices/UTType.h>

@interface FilesViewController ()

@property (nonatomic,copy) NSString* path;
@property (nonatomic,copy) NSMutableArray* filesArray;
@end

@implementation FilesViewController

-(id)initWithDirectoryAtPath:(NSString*)directoryPath {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        self.path = directoryPath;
        
        self.title = [self.path lastPathComponent];
        
        NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil];
        NSMutableArray *visibleFiles = [NSMutableArray arrayWithCapacity:[allFiles count]];
        
        for (NSString *file in allFiles) {
            if (![file hasPrefix:@"."]) {
                NSString *fullPath = [self.path stringByAppendingPathComponent:file];
                BOOL isDir = NO;
                [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
                NSError *error = nil;
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
                DirectoryItem *entry = [[DirectoryItem alloc] initWithPath:fullPath name:file mimeType:[AppUtils mimeTypeForFileURL:[NSURL fileURLWithPath:fullPath]] size:[attributes objectForKey:NSFileSize] dir:isDir];
                [visibleFiles addObject:entry];
            }
        }
        
        self.filesArray = visibleFiles;

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        self.path = [AppUtils documentDirectoryURL].path;
        
        self.title = @"App Documents";
        
        NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil];
        NSMutableArray *visibleFiles = [NSMutableArray arrayWithCapacity:[allFiles count]];
        
        for (NSString *file in allFiles) {
            if (![file hasPrefix:@"."]) {
                NSString *fullPath = [self.path stringByAppendingPathComponent:file];
                BOOL isDir = NO;
                [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
                NSError *error = nil;
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
                ;
                
                DirectoryItem *entry = [[DirectoryItem alloc] initWithPath:fullPath name:file mimeType:[AppUtils mimeTypeForFileURL:[NSURL fileURLWithPath:fullPath]] size:[attributes objectForKey:NSFileSize]  dir:isDir];
                [visibleFiles addObject:entry];
            }
        }
        
        self.filesArray = visibleFiles;

    }
    return self;
}



- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.filesArray count]?[self.filesArray count]:1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([self.filesArray count]) {
        DirectoryItem *entry = [self.filesArray objectAtIndex:[indexPath row]];
        
        if ([entry isDir]) {
            [[cell textLabel] setFont:[UIFont systemFontOfSize:14.0]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        } else {
            [[cell textLabel] setFont:[UIFont systemFontOfSize:14.0]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        [[cell textLabel] setText:[entry name]];
        [[cell textLabel] setTextAlignment:NSTextAlignmentLeft];
        

    }else{
        [[cell textLabel] setFont:[UIFont systemFontOfSize:16.0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell textLabel] setText:@"Empty Folder"];
        [[cell textLabel] setEnabled:FALSE];
        [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.filesArray count]) {
        DirectoryItem *entry = [self.filesArray objectAtIndex:[indexPath row]];
        if (entry.isDir) {
            FilesViewController *detailViewController = [[FilesViewController alloc] initWithDirectoryAtPath:[entry path]];
            detailViewController.filedelegate = self.filedelegate;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }else {
            //return to delegator
            if (self.filedelegate !=nil && [self.filedelegate respondsToSelector:@selector(didSelectFileItem:)]) {
                [self.filedelegate didSelectFileItem:entry];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//////

@implementation DirectoryItem

- (DirectoryItem *)initWithPath:(NSString *)path name:(NSString *)name mimeType:(NSString*)mimeType size:(NSNumber*)size dir:(BOOL)dir
{
    self = [super init];
    
    if (self) {
        _path = [path copy];
        _name = [name copy];
        _dir = dir;
        _mimeType = [mimeType copy];
        _size = [size copy];
    }
    
    return self;
}
@end