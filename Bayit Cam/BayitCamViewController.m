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
    if(self.isFromFormUI){
        self.navigationItem.title=NSLocalizedStringFromTable(@"Attention!", @"bayitcam", nil);
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
        self.skipBtn.hidden=YES;
        self.remeberBtn.hidden=YES;
        self.remberLbl.hidden=YES;
    }
    // Do any additional setup after loading the view from its nib.
    [self.skipBtn setTitle:NSLocalizedString(@"GuidSkip", @"") forState:UIControlStateNormal];
    self.attentionLbl.text=NSLocalizedStringFromTable(@"Attention!", @"bayitcam", nil);
    self.infoTextView.text=NSLocalizedStringFromTable(@"We have developed a new easier method for setting up your camera, as a result the WPS setup option (shown in the manual included) is no longer available.Please take a look at the video in the following link for instructions on how to setup your camera.", @"bayitcam", nil);
    [self.urlBtn setTitle:NSLocalizedStringFromTable(@"startUrl", @"bayitcam", nil) forState:UIControlStateNormal];
    self.remberLbl.text=NSLocalizedStringFromTable(@"Do not show this message again", @"bayitcam", nil);
    
    
    webView=[[UIMyWebView alloc]init];
    [self.view addSubview:webView];
    
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    webView.frame=CGRectMake(15, self.urlBtn.frame.origin.y+self.urlBtn.frame.size.height, self.view.frame.size.width-30, self.view.frame.size.height-self.skipBtn.frame.size.height-15-(self.urlBtn.frame.origin.y+self.urlBtn.frame.size.height));
    NSURL *movieFile=[NSURL URLWithString:@"https://www.youtube.com/embed/rq2uMHJnpcg"];
    [webView loadRequest:[NSURLRequest requestWithURL:movieFile]];
}
-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
    [webView release];
    [_remberLbl release];
    [_remeberBtn release];
    [super dealloc];
}
- (IBAction)skip:(id)sender {
    
    NSString *key=@"skip.ui";
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setBool:!self.remeberBtn.selected forKey:key];
    
    
    CameraMultiLiveViewController *vc=[[[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil] autorelease];
    AppDelegate *delegate=(AppDelegate *)([[UIApplication sharedApplication] delegate]);
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [navigationController setNavigationBarHidden:YES];
    [delegate.window setRootViewController:navigationController];
}
- (IBAction)urlAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedStringFromTable(@"startUrl", @"bayitcam", nil)]];
}
- (IBAction)remberClick:(id)sender {
    self.remeberBtn.selected=!self.remeberBtn.selected;
}
@end
