//
//  AddWithApCamera2Controller.h
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LANSearchController.h"
#import "MBProgressHUD.h"

@interface AddWithApCamera2Controller : UIViewController<UIAlertViewDelegate,LANSearchDelegate,UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel *ssidLbl;
@property (retain, nonatomic) IBOutlet UILabel *psdLbl;
@property (retain, nonatomic) IBOutlet UITextField *ssidInput;
@property (retain, nonatomic) IBOutlet UITextField *psdInput;
@property (retain, nonatomic) IBOutlet UIButton *settingBnr;
- (IBAction)setting:(id)sender;


@end
