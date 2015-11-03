//
//  BayitCamAddViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/5/14.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "BayitCamAddViewController.h"
#import "AddCameraDetailController.h"
#import "AddWithApCameraController.h"

@interface BayitCamAddViewController ()

@end

@implementation BayitCamAddViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"Add Camera", @"");
    [self.addBtn setTitle:NSLocalizedString(@"Add Camera", @"") forState:UIControlStateNormal];
    
    [self.view bringSubviewToFront:self.toolBarView];
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.toolBarView];
}
- (IBAction)back:(id)sender{
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
    [_toolBarView release];
    [_addBtn release];
    [super dealloc];
}
- (IBAction)addAction:(id)sender {
    AddWithApCameraController *addController=[[AddWithApCameraController alloc]initWithNibName:@"AddWithApCameraController" bundle:nil];
    [self.navigationController pushViewController:addController animated:YES];
    [addController release];
}
@end
