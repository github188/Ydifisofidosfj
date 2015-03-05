//
//  CheckViewController.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/5/13.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//
#import <IOTCamera/IOTCAPIs.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "CheckViewController.h"
#import "AddCameraDetailController.h"
#import "GetWiFiSSIDViewController.h"

@interface CheckViewController ()

@end

@implementation CheckViewController

- (IBAction)goWiFiSetting:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:1 forKey:@"wifiSetting"];
    [userDefaults synchronize];
    
    
    GetWiFiSSIDViewController *controller = [[GetWiFiSSIDViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)goCameraAddView:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:0 forKey:@"wifiSetting"];
    [userDefaults synchronize];
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:0]];
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
    
    self.title = NSLocalizedString(@"Add Device", @"");
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        checkView.y -= 88;
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
    
    textLabel.text = NSLocalizedString(@"Is the IP camera wired or wireless? Please connect the wired IP camera to an Ethernet network.", @"");
    
    [OK setTitle:NSLocalizedString(@"Wired",@"") forState:UIControlStateNormal];
    [Cancel setTitle:NSLocalizedString(@"Wireless",@"") forState:UIControlStateNormal];
}



@end
