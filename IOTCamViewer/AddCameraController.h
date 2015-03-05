//
//  AddCameraController.h
//  IOTCamViewer
//
//  Created by tutk on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AddCameraDelegate.h"
#import "MyCamera.h"
#import "ZXingWidgetController.h"
#import "LANSearchController.h"
#import "AddCameraDetailController.h"

extern NSString *deviceTokenString;

@interface AddCameraController : UIViewController
<ZXingDelegate, LANSearchDelegate, AddCameraDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UIButton *addCameraByTyping;
    UIButton *addCameraByScan;
    UIButton *addCameraBySearch;
    UITableView *tableView;    
    NSMutableArray *device_list;
}

@property (nonatomic, retain) IBOutlet UIButton *addCameraByTyping;
@property (nonatomic, retain) IBOutlet UIButton *addCameraByScan;
@property (nonatomic, retain) IBOutlet UIButton *addCameraBySearch;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)addCameraByTypingPressed:(id)sender;
- (IBAction)addCameraByScanPressed:(id)sender;
- (IBAction)searchCameraPressed:(id)sender;

@end
