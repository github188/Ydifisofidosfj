//
//  LoginViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/11/17.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "LoginViewController.h"
#import "CameraMultiLiveViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    [_rememberBtn release];
    [_rememberLbl release];
    [_loginBtn release];
    [_forgotBtn release];
    [_signupBtn release];
    [_userNameField release];
    [_passwordField release];
    [super dealloc];
}
- (IBAction)remember:(id)sender {
    self.rememberBtn.selected=!self.rememberBtn.selected;
}
- (IBAction)login:(id)sender {
    HttpTool *httpTool=[HttpTool shareInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *user=[self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *psd=[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(user.length==0||psd.length==0){
        [self alertInfo:@"请输入用户名和密码" withTitle:@"提示"];
        return;
    }
    NSDictionary *paraDic=@{@"uname":user,@"pwd":psd};
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=logIn" parameters:paraDic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"%@",responseObject);
        
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        
        if(code==1){
            [self alertInfo:msg withTitle:@"提示"];
        }
        else{
            NSDictionary *dic=responseObject[@"list"];
            NSInteger id=[dic[@"id"]integerValue];
            [AccountInfo SignIn:id withIsRemember:self.rememberBtn.selected];
            
            CameraMultiLiveViewController *vc=[[[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil] autorelease];
            AppDelegate *delegate=(AppDelegate *)([[UIApplication sharedApplication] delegate]);
            
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
            [navigationController setNavigationBarHidden:YES];
            [delegate.window setRootViewController:navigationController];
        }
        
    } failure:^(NSError *error) {
        [self alertInfo:error.localizedDescription withTitle:@"提示"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}
- (IBAction)forgot:(id)sender {
    ForgotViewController *forgot=[[[ForgotViewController alloc]initWithNibName:@"ForgotViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:forgot animated:YES];
}
- (IBAction)signup:(id)sender {
    SignupViewController *signupVC=[[[SignupViewController alloc]initWithNibName:@"SignupViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:signupVC animated:YES];
}
-(void)alertInfo:(NSString *)message withTitle:(NSString *)title{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}
@end
