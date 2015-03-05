//
//  DeviceListOnCloudViewController.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/22.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "DeviceListOnCloud.h"

extern NSMutableArray *camera_list;

@interface DeviceListOnCloudViewController : UIViewController <DeviceOnCloudDelegate,UITableViewDataSource,UITableViewDelegate> {
    DeviceListOnCloud *dloc;
    NSMutableArray *syncCameraList;
    
    NSMutableArray *downloadCameraList;
    IBOutlet UITableView *cameraListTable;
    BOOL isGoLogin;
    BOOL isSameUID;
    
    IBOutlet UIView *cautionView;
    IBOutlet UILabel *cautionLabel;
}

@property (nonatomic, retain) NSMutableArray *syncCameraList;

@end
