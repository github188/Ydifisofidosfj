//
//  LoginViewController.h
//  P2PCamCEO
//
//  Created by fourones on 15/11/17.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignupViewController.h"
#import "ForgotViewController.h"

@interface LoginViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *rememberBtn;
- (IBAction)remember:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *rememberLbl;

@property (retain, nonatomic) IBOutlet UIButton *loginBtn;
- (IBAction)login:(id)sender;


@property (retain, nonatomic) IBOutlet UIButton *forgotBtn;
- (IBAction)forgot:(id)sender;


@property (retain, nonatomic) IBOutlet UIButton *signupBtn;
- (IBAction)signup:(id)sender;


@property (retain, nonatomic) IBOutlet UITextField *userNameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@end
