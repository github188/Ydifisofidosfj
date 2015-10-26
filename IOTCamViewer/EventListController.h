//
//  EventListController.h
//  IOTCamViewer
//
//  Created by tutk on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "Event.h"
#import "PullRefreshTableViewController.h"
#import "CustomPeriodEventSearchController.h"


@interface EventListController : UITableViewController/*PullRefreshTableViewController*/ <MyCameraDelegate, UIActionSheetDelegate, UICustomPeriodEventSearchControllerDelegate> {

    UIBarButtonItem *searchButton;
    UIActivityIndicatorView *indicator;
    NSMutableArray *event_list;
    MyCamera *camera;
        
    BOOL isSearchingEvent;
    
    NSInteger timeZoneNumber;
}

@property (nonatomic, retain) MyCamera *camera;

- (IBAction)search:(id)sender;
- (IBAction)back:(id)sender;

@end
