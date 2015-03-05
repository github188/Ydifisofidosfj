//
//  CheckViewController.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/5/13.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "AddCameraDetailController.h"
#import "Categories.h"

extern NSString *deviceTokenString;

@interface CheckViewController : UIViewController {
    IBOutlet UIView *checkView;
    IBOutlet UILabel *textLabel;
    IBOutlet UIButton *OK;
    IBOutlet UIButton *Cancel;
}

@end
