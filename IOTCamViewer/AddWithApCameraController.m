//
//  AddWithApCameraController.m
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "AddWithApCameraController.h"
#import "AddCameraDetailController.h"
#import "AddWithApCamera1Controller.h"

@interface AddWithApCameraController ()

@end

@implementation AddWithApCameraController

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
    [_wifiTips release];
    [_wifitips2 release];
    [_otherTips release];
    [_wifiNextBtn release];
    [_otherNextBtn release];
    [super dealloc];
}
- (IBAction)wifiNextAction:(id)sender {
    AddWithApCamera1Controller *controller=[[AddWithApCamera1Controller alloc]initWithNibName:@"AddWithApCamera1Controller" bundle:nil];
    [self.navigationController pushViewController:controller animated:nil];
    [controller release];
}

- (IBAction)otherNextAction:(id)sender {
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:0]];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
@end
