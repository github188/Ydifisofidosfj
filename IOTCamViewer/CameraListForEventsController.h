//
//  CameraListForEventsController.h
//  IOTCamViewer
//
//  Created by tutk on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "DDBadgeViewCell.h"
#import "AppDelegate.h"

extern NSMutableArray *camera_list;

@interface CameraListForEventsController : UITableViewController <CameraDelegate, MyCameraDelegate>
{
    DDBadgeViewCell *tableViewCell;
}

@property (nonatomic, retain) IBOutlet DDBadgeViewCell *tableViewCell;

@end
