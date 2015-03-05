//
//  PhotoTableViewController.h
//  PlugCam
//
//  Created by ZINWELL on 2012/1/4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

extern FMDatabase *database;

@interface PhotoTableViewController : UITableViewController <UIAlertViewDelegate> {
	NSArray *dataSource;
	NSString *directoryPath;
    BOOL editMode;
    UIToolbar *editModeToolBar;
    NSMutableArray *checkedPhotoArray;

    Camera *camera;
    BOOL isFromChannel;
    int cameraChannel;
    
    UISegmentedControl *statFilter;
    BOOL isRecordFileView;
    BOOL isSigmentChanged;
}

@property (nonatomic, retain)NSString *directoryPath;
@property (nonatomic, retain)Camera *camera;

- (void)filterImage:(int)channel;

@end
