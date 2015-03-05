//
//  StartViewController.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/29.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceListOnCloud.h"

@interface StartViewController : UIViewController <UITextFieldDelegate,DeviceOnCloudDelegate> {
    IBOutlet UITextField *emailText;
    IBOutlet UITextField *passwordText;
    IBOutlet UIButton *skipBTN;
    IBOutlet UIButton *forgotBTN;
    IBOutlet UIButton *signupBTN;
    IBOutlet UIButton *loginBTN;
    
    DeviceListOnCloud *dloc;
    
    @public
    BOOL isFromDOC;
    BOOL isFromMCV;
}
- (IBAction)toMultiView:(id)sender;
- (IBAction)tryIDandPWD:(id)sender;
- (IBAction)goForgotWeb:(id)sender;
- (IBAction)goCreateWeb:(id)sender;

@end
