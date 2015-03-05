//
//  GetWiFiSSIDViewController.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/29.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetWiFiSSIDViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UILabel *SSID;
    IBOutlet UITextField *password;
    IBOutlet UIView *bgImage;
    IBOutlet UIView *cautionView;
    IBOutlet UILabel *cautionLabel;
}

- (IBAction)nextStep:(id)sender;

@end
