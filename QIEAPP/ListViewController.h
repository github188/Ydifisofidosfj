//
//  ListViewController.h
//  P2PCamCEO
//
//  Created by fourones on 15/12/13.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <IOTCamera/IOTCAPIs.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MyCamera.h"
#import "FMDatabase.h"
#import "MBProgressHUD.h"
#import "AddCameraDelegate.h"

extern NSMutableArray *camera_list;
extern FMDatabase *database;
extern NSString *deviceTokenString;

@interface ListViewController : UIViewController<AddCameraDelegate>


@property (retain, nonatomic) IBOutlet UILabel *noCameraTipLbl;
@property (retain, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)add:(id)sender;
@end
