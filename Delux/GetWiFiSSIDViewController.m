//
//  GetWiFiSSIDViewController.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/29.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "GetWiFiSSIDViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CheckSSIDViewController.h"

@interface GetWiFiSSIDViewController ()

@end

@implementation GetWiFiSSIDViewController

//輸入後按return將螢幕鍵盤縮下
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

- (IBAction)nextStep:(id)sender {
    
    //記錄WIFI SSID&PW
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:SSID.text forKey:@"apSSID"];
    [userDefaults setObject:password.text forKey:@"apPassword"];
    [userDefaults synchronize];

    CheckSSIDViewController *controller = [[CheckSSIDViewController alloc] initWithNibName:@"CheckSSIDView" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cautionLabel.text = NSLocalizedString(@"Please connect to your Wi-Fi network.", @"");
    
    [password setSecureTextEntry:YES];
    
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
    
    password.delegate = self;
    
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [ifs objectForKey:@"SSID"];
    
    if (ssid!=nil){
        SSID.text=ssid;
    } else {
        bgImage.hidden = YES;
        cautionView.hidden = NO;
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
                                     self.view.frame.origin.y - 45,
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
                                     self.view.frame.origin.y + 45,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
        
        [UIView commitAnimations];
    }
}

@end
