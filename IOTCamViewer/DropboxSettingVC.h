//
//  DropboxSettingVC.h
//  IOTCamViewer
//
//  Created by Victor on 2013/12/17.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "MyCamera.h"

extern NSMutableArray *camera_list;

@interface DropboxSettingVC : UIViewController <UITableViewDelegate,UITableViewDataSource,MyCameraDelegate> {
    NSMutableArray *cameras;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *dropboxBtn;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *dropboxBtn;
@property (retain, nonatomic) NSMutableArray *cameras ;

- (IBAction)onDrobpxClick:(id)sender;
- (IBAction)onTestClick:(id)sender;
- (void)updateCameraList;
- (void)updateButtons;
- (void)queryCameraStatus;
- (void)unlinkAllCamera;
- (void)camera:(MyCamera*) camera LinkDropbox:(BOOL) isLink ;

@end
