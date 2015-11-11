//
//  CameraListForLiveViewController.h
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "MyCamera.h"
#import "Categories.h"

#define HIRESDEVICE (((int)rintf([[[UIScreen mainScreen] currentMode] size].width/[[UIScreen mainScreen] bounds].size.width ) > 1))

#define CAMERA_NAME_TAG 1
#define CAMERA_STATUS_TAG 2
#define CAMERA_UID_TAG 3
#define CAMERA_SNAPSHOT_TAG 4

extern NSMutableArray *camera_list;
extern FMDatabase *database;
extern NSString *deviceTokenString;

@class Camera;

@protocol CameraListDelegate;

@interface CameraListForLiveViewController : UIViewController 
    <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MyCameraDelegate> {

    NSMutableArray *searchedData;
    UITableView *tableView;
    UISearchBar *searchBar;
    UITableViewCell *tableViewCell;
	NSMutableArray *arrReConntFlag;
        
    NSNumber *viewTag;
    NSString *selectCamera;
    IBOutlet UIView *addBTNView;
    IBOutlet UILabel *remoteLabel;
    IBOutlet UILabel *localLabel;
        IBOutlet UIButton *localBtn;
    
    @public
    BOOL isFromChange;
}

@property (nonatomic, assign) id<CameraListDelegate> delegate;
@property (nonatomic, retain) NSNumber *viewTag;
@property (nonatomic, retain) NSMutableArray *arrReConntFlag;
@property (nonatomic, retain) NSString *selectCamera;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCell;

- (IBAction)toggleEdit:(id)sender;
- (IBAction)goAddCamera:(id)sender;
- (IBAction)goDeviceOnCloud:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *bayitTipsLbl;
@property (retain, nonatomic) IBOutlet UILabel *bayitNoCameraTipsLbl;

@end

@protocol CameraListDelegate <NSObject>

- (void) didRemoveDevice:(MyCamera *)removedCamera;
- (void)didAddCamera:(MyCamera *)camera cameraChannel:(NSNumber *)channel withView:(NSNumber *)tag;

@end
