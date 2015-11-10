//
//  BayitCamAddFlowViewController.m
//  P2PCamCEO
//
//  Created by limingru on 15/11/5.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "BayitCamAddFlowViewController.h"
#import "AddWithApCamera1Controller.h"
#import "BayitCamAddViewController.h"
#import "LANSearchController.h"

@interface BayitCamAddFlowViewController ()

@end

@implementation BayitCamAddFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"Add Camera", @"");
    /***文字界面***/
    [self.firstBtn setTitle:NSLocalizedString(@"Add Camera", @"") forState:UIControlStateNormal];
    [self.secondBtn setTitle:NSLocalizedString(@"Add Camera", @"") forState:UIControlStateNormal];
    [self.thirdBtn setTitle:NSLocalizedString(@"Add Camera", @"") forState:UIControlStateNormal];
    
    self.firstLbl.text=NSLocalizedStringFromTable(@"Quick Setup", @"bayitcam", nil);
    self.secondLbl.text=NSLocalizedStringFromTable(@"Manually add a camera", @"bayitcam", nil);
    self.thirdLbl.text=NSLocalizedStringFromTable(@"Search in LAN", @"bayitcam", nil);
    
    self.firstTextView.text=NSLocalizedStringFromTable(@"Quick Setup Info", @"bayitcam", nil);
    self.secondTextView.text=NSLocalizedStringFromTable(@"Manually add a camera Info", @"bayitcam", nil);
    self.thirdTextView.text=NSLocalizedStringFromTable(@"Search and add a camera in the Local Area Network.", @"bayitcam", nil);
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
    [_firstLbl release];
    [_firstTextView release];
    [_firstBtn release];
    [_secondLbl release];
    [_secondTextView release];
    [_secondBtn release];
    [_thirdLbl release];
    [_thirdTextView release];
    [_thirdBtn release];
    [super dealloc];
}
- (IBAction)firstAction:(id)sender {
    AddWithApCamera1Controller *addController=[[AddWithApCamera1Controller alloc]initWithNibName:@"AddWithApCamera1Controller" bundle:nil];
    [self.navigationController pushViewController:addController animated:YES];
    [addController release];
}
- (IBAction)secondAction:(id)sender {
    BayitCamAddViewController *addController=[[BayitCamAddViewController alloc]initWithNibName:@"BayitCamAddViewController" bundle:nil];
    [self.navigationController pushViewController:addController animated:YES];
    [addController release];
}
- (IBAction)thirdAction:(id)sender {
    LANSearchController *controller = [[LANSearchController alloc] init];
    controller.isFromAutoWifi=YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
@end
