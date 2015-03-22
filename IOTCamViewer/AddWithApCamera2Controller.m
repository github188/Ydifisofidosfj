//
//  AddWithApCamera2Controller.m
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "AddWithApCamera2Controller.h"
#import "AppDelegate.h"
#import "HiSmartLink.h"

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
    [super dealloc];
}
- (IBAction)setting:(id)sender {
    
    
    NSString *ssid = self.ssidInput.text;
    NSString *password = self.psdInput.text;
    
    ssid = [ssid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"ssid:'%s', password:'%s'",[ssid UTF8String], [password UTF8String]);
    
    if (ssid == nil || [ssid length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"SSID不能为空！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (password == nil || [password length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不能为空！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if([ssid length] > 0 && [password length] > 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否听到摄像机叮咚提示音" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alert show];
        [alert release];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请长按摄像机复位键10秒，重新设置。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        const char *ssid=[self.ssidInput.text UTF8String];
        const char *psd=[self.psdInput.text UTF8String];
        NSLog(@"HiStartSmartConnection:%s,%s",ssid,psd);
        int result = HiStartSmartConnection(ssid, psd);
        NSLog(@"%d",result);
        //返回搜索设备界面
        
    }
}
@end
