//
//  SnapshotViewController.h
//  P2PCamCEO
//
//  Created by jacky on 15/10/14.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "MBProgressHUD.h"
#import "DefineExtension.h"

@interface SnapshotViewController : UIViewController<MyCameraDelegate>

@property(nonatomic,retain) MyCamera *camera;


- (IBAction)settingRecord:(id)sender;
- (IBAction)settingSnapshot:(id)sender;
- (IBAction)getSnapshotList:(id)sender;
@end
