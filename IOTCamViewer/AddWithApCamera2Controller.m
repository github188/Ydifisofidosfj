//
//  AddWithApCamera2Controller.m
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "AddWithApCamera2Controller.h"
#import "AppDelegate.h"
#ifndef TARGET_IPHONE_SIMULATOR
#import "HiSmartLink.h"
#endif
#import "AddCameraDetailController.h"

@interface AddWithApCamera2Controller ()

@end

@implementation AddWithApCamera2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    [negativeSpacer release];
    
    self.title=NSLocalizedStringFromTable(@"WIFI一键设置", @"easyn", nil);
    self.psdLbl.text=NSLocalizedString(@"Password", @"");
    [self.settingBnr setTitle:NSLocalizedStringFromTable(@"AddApWifiStep3SettingBtnTitle", @"easyn", nil) forState:UIControlStateNormal];
    
    self.ssidInput.delegate=self;
    self.psdInput.delegate=self;
    
    self.viewPsdLbl.text=NSLocalizedStringFromTable(@"ViewPsdLbl", @"easyn", nil);
    self.psdInput.secureTextEntry=YES;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *) textField
{
    if (textField == self.ssidInput) {
        [self.ssidInput resignFirstResponder];
    }
    
    if (textField == self.psdInput) {
        [self.psdInput resignFirstResponder];
    }
    
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.psdInput resignFirstResponder];
    [self.ssidInput resignFirstResponder];
}

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.ssidInput.text=[[app fetchSSIDInfo]objectForKey:@"SSID"];
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
    [_ssidLbl release];
    [_psdLbl release];
    [_ssidInput release];
    [_psdInput release];
    [_settingBnr release];
    [_viewPsdBtn release];
    [_viewPsdLbl release];
    [super dealloc];
}
- (IBAction)setting:(id)sender {
    
    
    NSString *ssid = self.ssidInput.text;
    NSString *password = self.psdInput.text;
    
    ssid = [ssid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"ssid:'%s', password:'%s'",[ssid UTF8String], [password UTF8String]);
    
    if (ssid == nil || [ssid length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedStringFromTable(@"AddApWifiSSIDTips", @"easyn", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
    }
    else if (password == nil || [password length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedStringFromTable(@"AddApWifiPsdTips", @"easyn", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
    }
    else if([ssid length] > 0 && [password length] > 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedStringFromTable(@"AddApWifiAudioTips", @"easyn", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", @"") otherButtonTitles:NSLocalizedString(@"NO", @""), nil];
        [alert show];
        [alert release];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedStringFromTable(@"AddApWifiResetTips", @"easyn", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        const char *ssid=[self.ssidInput.text UTF8String];
        const char *psd=[self.psdInput.text UTF8String];
        NSLog(@"HiStartSmartConnection:%s,%s",ssid,psd);
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.detailsLabelText = NSLocalizedStringFromTable(@"AddApWifiWaitingTips", @"easyn", nil);
        [hud show:YES];
        [hud release];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#ifndef TARGET_IPHONE_SIMULATOR
            int result=HiStartSmartConnection(ssid, psd);
#else
            int result=0;
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [hud removeFromSuperview];
                if(result==0){
                    MBProgressHUD *hud1 = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    [self.navigationController.view addSubview:hud1];
                    hud1.detailsLabelText = NSLocalizedStringFromTable(@"AddApWifiWaitingTips", @"easyn", nil);
                    [hud1 showAnimated:YES whileExecutingBlock:^{
                        sleep(60);
                    } completionBlock:^{
                        [hud1 removeFromSuperview];
                        [hud1 release];
                        //返回搜索设备界面
                        LANSearchController *controller = [[LANSearchController alloc] init];
                        controller.delegate = self;
                        controller.isFromAutoWifi=YES;
                        [self.navigationController pushViewController:controller animated:YES];
                        [controller release];
#ifndef TARGET_IPHONE_SIMULATOR
                        HiStopSmartConnection();
#endif
                    }];
                }
                else{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedStringFromTable(@"AddApWifiErrorTips", @"easyn", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Warning", @"") otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
#ifndef TARGET_IPHONE_SIMULATOR
                    HiStopSmartConnection();
#endif
                }
            });
        });
        
    }
}

#pragma mark --LANSearchControllerDelegate
- (void) didSelectUID:(NSString *)selectedUid{
    
    /*[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:0]];
    controller.uid=selectedUid;
    controller.isFromAutoWifi=YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    sleep(1);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];*/
}

- (IBAction)viewPsdAction:(id)sender {
    if(self.psdInput.secureTextEntry){
        self.psdInput.secureTextEntry=NO;
        [self.viewPsdBtn setBackgroundImage:[UIImage imageNamed:@"remeberpsd1.png"] forState:UIControlStateNormal];
    }
    else{
        self.psdInput.secureTextEntry=YES;
        [self.viewPsdBtn setBackgroundImage:[UIImage imageNamed:@"remeberpsd2.png"] forState:UIControlStateNormal];
    }
}
@end
