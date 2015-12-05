//
//  EditPasswordViewController.h
//  P2PCamCEO
//
//  Created by fourones on 15/12/5.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface EditPasswordViewController : UIViewController


@property (retain, nonatomic) IBOutlet UILabel *tipsLbl;
@property (retain, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (retain, nonatomic) IBOutlet UITextField *newPasswordField;

@property (retain, nonatomic) IBOutlet UITextField *reNewPasswordField;
@property (retain, nonatomic) IBOutlet UIButton *submitBtn;
@property (retain, nonatomic) IBOutlet UIButton *resetBtn;


- (IBAction)submit:(id)sender;
- (IBAction)reset:(id)sender;
@end
