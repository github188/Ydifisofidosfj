//
//  LoginViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/11/17.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_rememberBtn release];
    [_rememberLbl release];
    [_loginBtn release];
    [_forgotBtn release];
    [_signupBtn release];
    [_userNameField release];
    [_passwordField release];
    [super dealloc];
}
- (IBAction)remember:(id)sender {
}
- (IBAction)login:(id)sender {
}
- (IBAction)forgot:(id)sender {
    ForgotViewController *forgot=[[[ForgotViewController alloc]initWithNibName:@"ForgotViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:forgot animated:YES];
}
- (IBAction)signup:(id)sender {
    SignupViewController *signupVC=[[[SignupViewController alloc]initWithNibName:@"SignupViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:signupVC animated:YES];
}
@end
