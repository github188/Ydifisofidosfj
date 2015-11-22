//
//  PhotoTableViewController.m
//  PlugCam
//
//  Created by ZINWELL on 2012/1/4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#import "PhotoTableViewController.h"
#import "CustomGridTableViewCellStyle1.h"
#import "CustomGridTableViewCellStyle2.h"
#import "PhotoViewerViewController.h"
#import "RecordFileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"


@interface PhotoTableViewController()
@property (nonatomic, retain)NSArray *dataSource;
@property (nonatomic)BOOL editMode;
@property (nonatomic, retain)UIToolbar *editModeToolBar;
@property (nonatomic, retain)NSMutableArray *checkedPhotoArray;
@end

@implementation PhotoTableViewController


@synthesize dataSource;
@synthesize directoryPath;
@synthesize editMode;
@synthesize editModeToolBar;
@synthesize checkedPhotoArray;
@synthesize camera;

- (NSArray *)dataSource {
	if (!dataSource || isSigmentChanged) {
        
        if (isSigmentChanged) {
            isSigmentChanged = !isSigmentChanged;
        }
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot WHERE dev_uid=?", camera.uid];

        while([rs next]) {
        
            NSString *filePath = [rs stringForColumn:@"file_path"];            
            NSLog(@"%@", filePath);
            
            if (isRecordFileView) {
                if ([filePath rangeOfString:@"CEO_Record"].location != NSNotFound) {
                    [mutableArray addObject:[NSString stringWithFormat:@"%@", filePath]];
                }
            }
            
            else if (isFromChannel) {
                if ([filePath rangeOfString:@"CEO_Record"].location != NSNotFound) {
                    continue;
                }
                if ([filePath rangeOfString:[NSString stringWithFormat:@"CH%d",cameraChannel]].location != NSNotFound) {
                    [mutableArray addObject:[NSString stringWithFormat:@"%@", filePath]];
                }
            } else {
                if ([filePath rangeOfString:@"CEO_Record"].location != NSNotFound) {
                    continue;
                }
                [mutableArray addObject:[NSString stringWithFormat:@"%@", filePath]];
            }
        }
        [rs close];
        dataSource = [[NSArray alloc] initWithArray:mutableArray];
        [mutableArray release];
        
        /*
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:self.directoryPath] == YES) {
			NSMutableArray *photoFileNameArray = nil;
            for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:self.directoryPath error:nil]) {
                if (fileName.length > 18) {
                    if (!photoFileNameArray) {
                        photoFileNameArray = [[[NSMutableArray alloc] init] autorelease];
                    }
                    [photoFileNameArray addObject:fileName];
                }
            }
            dataSource = [[NSArray alloc] initWithArray:photoFileNameArray];
        }
        */
	}
	return dataSource;
}

#pragma mark Initialization

- (void)filterImage:(int)channel {
    isFromChannel = YES;
    cameraChannel = channel;
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[[dirs objectAtIndex:0] stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (void)deleteSnapshotRecords:(NSString *)fileName {
    
    if (database != NULL) {
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot WHERE file_path=?", fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while([rs next]) {
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[self pathForDocumentsResource: filePath] error:NULL];        
            NSLog(@"camera(%@) snapshot removed", filePath);
            
            if (isRecordFileView) {
                NSString *videoFilePath = [filePath stringByReplacingOccurrencesOfString:@"jpg" withString:@"mp4"];
                [fileManager removeItemAtPath:[self pathForDocumentsResource: videoFilePath] error:NULL];
            }
            
        }
        
        [rs close];        
        
        [database executeUpdate:@"DELETE FROM snapshot WHERE file_path=?", fileName];
    }
    
    //    if (isRecordFileView) {
    //        NSString *videoFileName = [[[self.dataSource objectAtIndex:index] substringToIndex:14] stringByAppendingString:@".mp4"];
    //        NSString *videoFilePath = [self.directoryPath stringByAppendingPathComponent:videoFileName];
    //
    //        if (YES==[[NSFileManager defaultManager] removeItemAtPath:thumbnailFilePath error:nil]) {
    //            if (NO == [[NSFileManager defaultManager] removeItemAtPath:videoFilePath error:nil]) {
    //                NSLog(@"Delete video(%d) failed...",index);
    //            }
    //        }
    //    }
}


#define DELETE_PHOTO_ALERT_VIEW_TAG 1
#define NO_PHOTO_TO_DELETE_ALERT_VIEW_TAG   2
- (void)deletePhotoAtIndex:(NSInteger)index {
    NSString *thumbnailFilePath = [self.directoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:index]];

    NSString *photoFileName = [[[self.dataSource objectAtIndex:index] substringToIndex:14] stringByAppendingString:@".jpg"];
    NSString *photoFilePath = [self.directoryPath stringByAppendingPathComponent:photoFileName];
    
    if (YES==[[NSFileManager defaultManager] removeItemAtPath:thumbnailFilePath error:nil]) {
        if (NO == [[NSFileManager defaultManager] removeItemAtPath:photoFilePath error:nil]) {
            NSLog(@"Delete thumbnail(%d) failed...",index);
        }
    }
}
- (void)deletePhotos {
    for (NSNumber *index in self.checkedPhotoArray) {
        
        NSString *photoFile = [dataSource objectAtIndex:[index intValue]];
        [self deleteSnapshotRecords:photoFile];
        
        //[self deletePhotoAtIndex:[index integerValue]];
    }
}
- (void)deletePhotosAlertView {
    if (self.checkedPhotoArray.count>0) {
        UIAlertView *makeSureAlertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete?", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil),NSLocalizedString(@"Cancel", nil), nil] autorelease];
        makeSureAlertView.tag = DELETE_PHOTO_ALERT_VIEW_TAG;
        [makeSureAlertView show];
    }else {
        
        NSString *tips=isRecordFileView?@"Please select records to delete.":@"Please select photos to delete.";
        
        UIAlertView *makeSureAlertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(tips, nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease];
        makeSureAlertView.tag = NO_PHOTO_TO_DELETE_ALERT_VIEW_TAG;
        [makeSureAlertView show];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (DELETE_PHOTO_ALERT_VIEW_TAG == alertView.tag) {
        switch (buttonIndex) {
            case 0:
                [self deletePhotos];
                self.checkedPhotoArray = [[[NSMutableArray alloc] init] autorelease];
                self.dataSource = nil;
                [self.tableView reloadData];
                break;
                
            default:
                break;
        }
    }
}
- (void)adjustEditModeToolBarUi {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ) {
		CGFloat fTmp = screenBounds.size.height;
		screenBounds.size.height = screenBounds.size.width;
		screenBounds.size.width = fTmp;
	}
    
    if (UIInterfaceOrientationLandscapeLeft == orientation||UIInterfaceOrientationLandscapeRight == orientation) {
        
        
        
        if (screenBounds.size.height == 568) {
            self.editModeToolBar.frame = CGRectMake(0, 320-20-24, 568, 44);
        } else if(screenBounds.size.height == 480) {
            self.editModeToolBar.frame = CGRectMake(0, 320-20-24, 480, 44);
        }
        
        
        
    }else {
        
        if (screenBounds.size.height == 568) {
            self.editModeToolBar.frame = CGRectMake(0, 568-20-24, 320, 44);
        } else if(screenBounds.size.height == 480) {
            self.editModeToolBar.frame = CGRectMake(0, 480-20-24, 320, 44);
        }
        
    }
    self.editModeToolBar.frame = CGRectMake(0, screenBounds.size.height-44, screenBounds.size.width, 44);

}
- (void)showEditModeToolBar {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ) {
		CGFloat fTmp = screenBounds.size.height;
		screenBounds.size.height = screenBounds.size.width;
		screenBounds.size.width = fTmp;
	}
    
    if (UIInterfaceOrientationLandscapeLeft == orientation||UIInterfaceOrientationLandscapeRight == orientation) {
        self.editModeToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 320-20-24, 480, 44)] autorelease];
    } else {
        self.editModeToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-20-24, 320, 44)] autorelease];
    }
    self.editModeToolBar.frame = CGRectMake(0, screenBounds.size.height-44, screenBounds.size.width, 44);
    
    self.editModeToolBar.barStyle = UIBarStyleDefault;
	self.editModeToolBar.translucent = NO;
    //self.editModeToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth/*|UIViewAutoresizingFlexibleHeight*/;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"buttonRedBackground.png"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
    
    button.frame=CGRectMake(0.0, 100.0, 120.0, 30.0);
    [button addTarget:self action:@selector(deletePhotosAlertView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* deleteButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    
    
    [self.editModeToolBar setItems:[NSArray arrayWithObjects:flexibleSpace,deleteButton,flexibleSpace,nil]];
    
    [self.navigationController.view addSubview:self.editModeToolBar];
}
- (void)hideEditModeToolBar {
    [self.editModeToolBar removeFromSuperview];
    self.editModeToolBar = nil;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self adjustEditModeToolBarUi];
    if (self.editMode == YES) {
        self.editModeToolBar.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.editMode == YES) {
        self.editModeToolBar.hidden = YES;
    }
}

#pragma mark -
#pragma mark View lifecycle
- (void)backToPreviousView {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)switchEditMode {
    self.editMode = !self.editMode;
    if (self.editMode) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(switchEditMode)] autorelease];
        self.editModeToolBar.hidden = NO;
        self.checkedPhotoArray = [[[NSMutableArray alloc] init] autorelease];
    }else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(switchEditMode)] autorelease];
        self.editModeToolBar.hidden = YES;
        [self.tableView reloadData];
        self.checkedPhotoArray = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Add footer to prevent from that the tool bar blocks the last table cell 
    UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 49/*49 is the height of tab bar. 44 is the hieght of tool bar*/+5/*gap*/)] autorelease];
	footer.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = footer;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(switchEditMode)] autorelease];
    
//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backToPreviousView)];
//	self.navigationItem.leftBarButtonItem = leftBarButtonItem;
//	[leftBarButtonItem release];
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(backToPreviousView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    statFilter = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Snapshot", @""), NSLocalizedString(@"Record Files", @""), nil]];
    [statFilter setSegmentedControlStyle:UISegmentedControlStyleBar];
    [statFilter setSelectedSegmentIndex:0];
    [statFilter setTintColor:[UIColor colorWithRed:3.0/255.0f green:110/255.0f blue:184/255.0f alpha:1.0f]];
    [statFilter setBackgroundColor:[UIColor whiteColor]];
    [statFilter sizeToFit];
    [statFilter addTarget:self
                         action:@selector(sigmentChanged)
               forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = statFilter;
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 79;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg4.png"]]; 
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
}

- (void)sigmentChanged {
    
    isSigmentChanged = YES;
    
    if (statFilter.selectedSegmentIndex == 0) {

        isRecordFileView = NO;
        [self.tableView reloadData];
    } else {

        isRecordFileView = YES;
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self showEditModeToolBar];
    if (self.editMode) {
        self.editModeToolBar.hidden = NO;
    }else {
        self.editModeToolBar.hidden = YES;
    }
    
    self.navigationController.navigationBarHidden = NO;
    
	self.dataSource = nil;
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideEditModeToolBar];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger buttonNumberInRow = 4;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        buttonNumberInRow = 6;
    }else {
        buttonNumberInRow = 4;
    }
    int row = self.dataSource.count/buttonNumberInRow+(self.dataSource.count%buttonNumberInRow==0?0:1);
    return row;
}

- (void)highlightButton:(UIButton *)b { 
    [b setHighlighted:YES];
}
- (void)cancelHighlightButton:(UIButton *)b { 
    [b setHighlighted:NO];
}
- (void)btnPressed:(UIButton *)sender {
    //NSLog(@"sender.tag=%d",sender.tag);
    if (self.editMode == NO) {

        if (isRecordFileView) {
            
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@",self.directoryPath,[[self.dataSource objectAtIndex:sender.tag]stringByReplacingOccurrencesOfString:@"jpg" withString:@"mp4"]];
            
            RecordFileViewController *recordView = [[RecordFileViewController alloc] init];
            [recordView setPlayer:urlStr index:sender.tag];
            [recordView setVideoArray:self.dataSource videoPath:self.directoryPath];
            recordView.camera = camera;
            [self.navigationController pushViewController:recordView animated:YES];
            [recordView release];
            
        } else {
            PhotoViewerViewController *photo = [[PhotoViewerViewController alloc] init];
            photo.title = self.title;
            
            photo.camera = camera;
            photo.albumPath = self.directoryPath;
            photo.photoFileName = [self.dataSource objectAtIndex:sender.tag];
            photo.hidesBottomBarWhenPushed = YES;
            [photo filterImage:cameraChannel];
            [self.navigationController pushViewController:photo animated:YES];
            [photo release];
        }
    }
    else {

        if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:sender.tag]] == NSNotFound) {
            [sender setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
            [self.checkedPhotoArray addObject:[NSNumber numberWithInteger:sender.tag]];
        }
        else {
            [sender setImage:nil forState:UIControlStateNormal];
            NSInteger checkedPhotoArrayIndex = [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:sender.tag]];
            if (NSNotFound != checkedPhotoArrayIndex) {
                [self.checkedPhotoArray removeObjectAtIndex:checkedPhotoArrayIndex];
            }
        }
        //NSLog(@"checkedPhotoArray = %@",self.checkedPhotoArray);
    }


}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) 
    {
        static NSString *CellIdentifierLanscape = @"CustomGridTableViewCellStyle2";
        
        CustomGridTableViewCellStyle2 *cell = (CustomGridTableViewCellStyle2 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierLanscape];
        if (cell == nil) {
            NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomGridTableViewCellStyle2" owner:nil options:nil];
            for (id currentObject in nibObjects) {
                if ([currentObject isKindOfClass:[CustomGridTableViewCellStyle2 class]]) {
                    cell = (CustomGridTableViewCellStyle2 *)currentObject;
                }
            }
        }
        // Configure the cell...
        NSString *albumDirectoryPath = self.directoryPath;
         
        if (self.dataSource.count>0) {
            for (int i = 0; i<6; i++) {
                if ((6*indexPath.row+i)<self.dataSource.count) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor=[UIColor clearColor];  
                    switch (i) {
                        case 0:
                            cell.button1.tag = 6*indexPath.row+i;
                            [cell.button1 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button1.tag]]] forState:UIControlStateNormal];
                            [cell.button1 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button1.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button1.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button1.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button1 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button1 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button1 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            
                            break;
                        case 1:
                            cell.button2.tag = 6*indexPath.row+i;
                            [cell.button2 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button2.tag]]] forState:UIControlStateNormal];
                            [cell.button2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button2.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button2.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button2.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button2 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button2 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button2 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        case 2:
                            cell.button3.tag = 6*indexPath.row+i;
                            [cell.button3 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button3.tag]]] forState:UIControlStateNormal];
                            [cell.button3 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button3.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button3.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button3.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button3 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button3 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button3 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        case 3:
                            cell.button4.tag = 6*indexPath.row+i;
                            [cell.button4 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button4.tag]]] forState:UIControlStateNormal];
                            [cell.button4 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button4.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button4.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button4.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button4 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button4 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button4 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        case 4:
                            cell.button5.tag = 6*indexPath.row+i;
                            [cell.button5 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button5.tag]]] forState:UIControlStateNormal];
                            [cell.button5 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button5.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button5.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button5.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button5 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button5 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button5 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        case 5:
                            cell.button6.tag = 6*indexPath.row+i;
                            [cell.button6 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button6.tag]]] forState:UIControlStateNormal];
                            [cell.button6 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button6.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button6.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button6.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button6 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button6 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button6 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        default:
                            break;
                    }
                    
                }
            }
            
            
            //cell.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
            //cell.imageView.layer.borderWidth = 5.0;
            //cell.imageView.layer.cornerRadius = 10.0;
            //cell.imageView.layer.masksToBounds = YES;
        }else {
            [cell.button1 setImage:[UIImage imageNamed:@"NoPhotoAvailable.png"] forState:UIControlStateNormal];
        }	
        
        return cell;

    }
    else 
    {
        static NSString *CellIdentifier = @"CustomGridTableViewCellStyle1";
        
        CustomGridTableViewCellStyle1 *cell = (CustomGridTableViewCellStyle1 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomGridTableViewCellStyle1" owner:nil options:nil];
            for (id currentObject in nibObjects) {
                if ([currentObject isKindOfClass:[CustomGridTableViewCellStyle1 class]]) {
                    cell = (CustomGridTableViewCellStyle1 *)currentObject;
                }
            }
        }
        //NSLog(@"test");
        //NSLog(@"checkedPhotoArray = %@",self.checkedPhotoArray);
        // Configure the cell...
        //cell.textLabel.text = [[[self.dataSource objectAtIndex:indexPath.row] substringWithRange:NSMakeRange(0, 14)] stringByAppendingString:@".jpg"];	// photo name (file name)
        NSString *albumDirectoryPath = self.directoryPath;
        
        if (self.dataSource.count>0) {
            for (int i = 0; i<4; i++) {
                if ((4*indexPath.row+i)<self.dataSource.count) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor=[UIColor clearColor];  
                    switch (i) {
                        case 0:
                            cell.button1.tag = 4*indexPath.row+i;
                            [cell.button1 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button1.tag]]] forState:UIControlStateNormal];
                            [cell.button1 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button1.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button1.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button1.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button1 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button1 setImage:nil forState:UIControlStateNormal];
                                }

                            }else {
                                [cell.button1 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            
                            break;
                        case 1:
                            cell.button2.tag = 4*indexPath.row+i;
                            [cell.button2 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button2.tag]]] forState:UIControlStateNormal];
                            [cell.button2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button2.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button2.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button2.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button2 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button2 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button2 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        case 2:
                            cell.button3.tag = 4*indexPath.row+i;
                            [cell.button3 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button3.tag]]] forState:UIControlStateNormal];
                            [cell.button3 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button3.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button3.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button3.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button3 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button3 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button3 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        case 3:
                            cell.button4.tag = 4*indexPath.row+i;
                            [cell.button4 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:cell.button4.tag]]] forState:UIControlStateNormal];
                            [cell.button4 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.button4.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.button4.layer.borderWidth = 1.0;
                            if (self.checkedPhotoArray == nil || [self.checkedPhotoArray indexOfObject:[NSNumber numberWithInteger:cell.button4.tag]] == NSNotFound) {
                                if (isRecordFileView) {
                                    [cell.button4 setImage:[UIImage imageNamed:@"ceo_record_play"] forState:UIControlStateNormal];
                                } else {
                                    [cell.button4 setImage:nil forState:UIControlStateNormal];
                                }
                            }else {
                                [cell.button4 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                            break;
                        default:
                            break;
                    }
                    
                }
            }
            
            //cell.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
            //cell.imageView.layer.borderWidth = 5.0;
            //cell.imageView.layer.cornerRadius = 10.0;
            //cell.imageView.layer.masksToBounds = YES;
        }else {
            [cell.button1 setImage:[UIImage imageNamed:@"NoPhotoAvailable.png"] forState:UIControlStateNormal];
        }	
        
        return cell;
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        NSString *thumbnailFilePath = [self.directoryPath stringByAppendingPathComponent:[self.dataSource objectAtIndex:indexPath.row]];
        NSString *photoFileName = [[[self.dataSource objectAtIndex:indexPath.row] substringToIndex:14] stringByAppendingString:@".jpg"];
        NSString *photoFilePath = [self.directoryPath stringByAppendingPathComponent:photoFileName];
        
		if (YES==[[NSFileManager defaultManager] removeItemAtPath:thumbnailFilePath error:nil]) {
            if (NO == [[NSFileManager defaultManager] removeItemAtPath:photoFilePath error:nil]) {
                NSLog(@"Delete thumbnail failed...");
            }
			self.dataSource=nil;
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    camera = nil;
}


- (void)dealloc {
    [editModeToolBar release];
    [checkedPhotoArray release];
	[dataSource release];
	[directoryPath release];
    [camera release];
    [super dealloc];
}


@end

