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
    
    self.userNameField.placeholder=NSLocalizedStringFromTable(@"UserNameTips", @"login", nil);
    self.passwordField.placeholder=NSLocalizedStringFromTable(@"PasswordTips", @"login", nil);
    self.rememberLbl.text=NSLocalizedStringFromTable(@"Remember", @"login", nil);
    [self.loginBtn setTitle:NSLocalizedStringFromTable(@"Login", @"login", nil) forState:UIControlStateNormal];
    [self.forgotBtn setTitle:NSLocalizedStringFromTable(@"Forget password", @"login", nil) forState:UIControlStateNormal];
    [self.signupBtn setTitle:NSLocalizedStringFromTable(@"Sign up", @"login", nil) forState:UIControlStateNormal];
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
    
    NSString *user=[self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *psd=[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(user.length==0||psd.length==0){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入用户名和密码", @"login", nil) withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *paraDic=@{@"uname":user,@"pwd":psd};
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=logInFr" parameters:paraDic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"%@",responseObject);
        
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        
        if(code==1){
            [self alertInfo:msg withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
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
        [self alertInfo:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
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
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"确定", @"login", nil), nil];
    [alert show];
    [alert release];
}
@end
