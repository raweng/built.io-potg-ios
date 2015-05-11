//
//  FilesViewController.h
//
//  Created by Reefaq on 14/10/12.
//  Copyright (c) 2012 Reefaq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectoryItem : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, assign, getter = isDir) BOOL dir;
- (DirectoryItem *)initWithPath:(NSString *)path name:(NSString *)name mimeType:(NSString*)mimeType size:(NSNumber*)size dir:(BOOL)dir;
@end

@protocol FileViewerDelegate <NSObject>
-(void)didSelectFileItem:(DirectoryItem*)fileItem;
@end


//// FilesViewController

@interface FilesViewController : UITableViewController

-(id)initWithDirectoryAtPath:(NSString*)directoryPath;

@property (nonatomic, unsafe_unretained) id<FileViewerDelegate> filedelegate;
@end

