//
//  SignupViewController.h
//  P2PCamCEO
//
//  Created by fourones on 15/11/17.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

- (IBAction)back:(id)sender;


@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UITextField *userNameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UITextField *confirmPasswordField;

@property (retain, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)submit:(id)sender;
@end
