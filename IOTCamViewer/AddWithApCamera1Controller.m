//
//  AddWithApCamera1Controller.m
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "AddWithApCamera1Controller.h"
#import "iToast.h"

@interface AddWithApCamera1Controller ()

@end

@implementation AddWithApCamera1Controller

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
    [self.nextBtn setTitle:NSLocalizedStringFromTable(@"AddApWifiNextStep", @"easyn", nil) forState:UIControlStateNormal];
    self.tipsLbl.text=NSLocalizedStringFromTable(@"AddApWifiStep2Tips", @"easyn", nil);
    
#if defined(SVIPCLOUD)
    [self.nextBtn setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
#endif
}
-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    if (r == nil) {
        isConnectionWIFI=NO;
    }
    else{
        switch ([r currentReachabilityStatus]) {
            case NotReachable:
                isConnectionWIFI=NO;
                break;
            case ReachableViaWWAN:
                isConnectionWIFI=NO;
                break;
            case ReachableViaWiFi:
                isConnectionWIFI=YES;
                break;
        }
    }
    
    //提示手机连接wifi
    [self noWifiTips];
    
}
-(BOOL)noWifiTips{
    if(!isConnectionWIFI){
        [[iToast makeText:NSLocalizedStringFromTable(@"AddApWifiStep2NeedWifiTips", @"easyn", nil)]show];
        return YES;
    }
    return NO;
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
    [_nextBtn release];
    [_tipsLbl release];
    [_image release];
    [super dealloc];
}
- (IBAction)next:(id)sender {
    if([self noWifiTips]) return;
    AddWithApCamera2Controller *add=[[AddWithApCamera2Controller alloc]initWithNibName:@"AddWithApCamera2Controller" bundle:nil];
    [self.navigationController pushViewController:add animated:nil];
    [add release];
}
@end
