//
//  BayitCamViewController.m
//  P2PCamCEO
//
//  Created by fourones on 11/9/15.
//  Copyright © 2015 TUTK. All rights reserved.
//

#import "BayitCamViewController.h"
#import "AppDelegate.h"

@interface BayitCamViewController ()

@end

@implementation BayitCamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.skipBtn setTitle:NSLocalizedString(@"GuidSkip", @"") forState:UIControlStateNormal];
    self.attentionLbl.text=NSLocalizedStringFromTable(@"Attention!", @"bayitcam", nil);
    self.infoTextView.text=NSLocalizedStringFromTable(@"We have developed a new easier method for setting up your camera, as a result the WPS setup option (shown in the manual included) is no longer available.Please take a look at the video in the following link for instructions on how to setup your camera.", @"bayitcam", nil);
    [self.urlBtn setTitle:NSLocalizedStringFromTable(@"startUrl", @"bayitcam", nil) forState:UIControlStateNormal];
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
    [_skipBtn release];
    [_attentionLbl release];
    [_infoTextView release];
    [_urlBtn release];
    [super dealloc];
}
- (IBAction)skip:(id)sender {
    CameraMultiLiveViewController *vc=[[[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil] autorelease];
    AppDelegate *delegate=(AppDelegate *)([[UIApplication sharedApplication] delegate]);
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [navigationController setNavigationBarHidden:YES];
    [delegate.window setRootViewController:navigationController];
}
- (IBAction)urlAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedStringFromTable(@"startUrl", @"bayitcam", nil)]];
}
@end
