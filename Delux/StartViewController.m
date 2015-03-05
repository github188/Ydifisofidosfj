//
//  StartViewController.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/29.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "StartViewController.h"
#import "CameraMultiLiveViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

//輸入後按return將螢幕鍵盤縮下
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)toMultiView:(id)sender {
    CameraMultiLiveViewController *controller = [[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)tryIDandPWD:(id)sender {
    dloc = [[DeviceListOnCloud alloc] init];
    dloc.delegate = self;
    [dloc downloadDeviceListID:emailText.text PWD:passwordText.text];
}

- (IBAction)goForgotWeb:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://p2pcamweb.tutk.com/DeviceCloud/forgetPwd.php"]];
}

- (IBAction)goCreateWeb:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://p2pcamweb.tutk.com/DeviceCloud/signup.php"]];
}

- (IBAction)back:(id)sender {
    
    if (isFromMCV) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]  animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isFromDOC||isFromMCV) {
        skipBTN.hidden = YES;
    }
    
    [loginBTN setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
    [skipBTN setTitle:NSLocalizedString(@"Skip >", @"") forState:UIControlStateNormal];
    [forgotBTN setTitle:NSLocalizedString(@"Forgot password", @"") forState:UIControlStateNormal];
    [signupBTN setTitle:NSLocalizedString(@"Sign up", @"") forState:UIControlStateNormal];
    
    emailText.delegate = self;
    passwordText.delegate = self;
    [passwordText setSecureTextEntry:YES];
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]||[userDefaults objectForKey:@"cloudUserPassword"]==nil){
        
        emailText.text = [userDefaults objectForKey:@"cloudUserID"];
        
    } else {
        
        CameraMultiLiveViewController *controller = [[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil];
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    
    NSString *result = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    NSLog(@"result:%@",result);
    
    if ([result rangeOfString:@"error"].location != NSNotFound||[result rangeOfString:@"failed"].location != NSNotFound) {
        
        NSString *msg = NSLocalizedString(@"Wrong ID or Password!", @"");
        NSString *error = NSLocalizedString(@"ERROR!", @"");
        NSString *ok = NSLocalizedString(@"OK", @"");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:error message:msg delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
        [alert show];
        [alert release];

    } else if ([result rangeOfString:@"account not active"].location != NSNotFound) {
    
        NSString *msg = NSLocalizedString(@"Account not active!", @"");
        NSString *error = NSLocalizedString(@"ERROR!", @"");
        NSString *ok = NSLocalizedString(@"OK", @"");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:error message:msg delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    } else {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:emailText.text forKey:[[NSString alloc] initWithString:@"cloudUserID"]];
        [userDefaults setObject:passwordText.text forKey:[[NSString alloc] initWithString:@"cloudUserPassword"]];
        [userDefaults synchronize];
        
        if (isFromDOC==NO && isFromMCV==NO){
            CameraMultiLiveViewController *controller = [[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil];
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        } else {
//            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:3]  animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y - 75,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
        
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y + 75,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
        
        [UIView commitAnimations];
    }
}

@end
