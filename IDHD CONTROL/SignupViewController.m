//
//  SignupViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/11/17.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.submitBtn setTitle:NSLocalizedStringFromTable(@"Submit", @"login", nil) forState:UIControlStateNormal];
    self.emailField.placeholder=NSLocalizedStringFromTable(@"EmailTips", @"login", nil);
    self.userNameField.placeholder=NSLocalizedStringFromTable(@"UserNameTips", @"login", nil);
    self.passwordField.placeholder=NSLocalizedStringFromTable(@"firstPasswordTips", @"login", nil);
    self.confirmPasswordField.placeholder=NSLocalizedStringFromTable(@"secondPasswordTips", @"login", nil);
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
    [_emailField release];
    [_userNameField release];
    [_passwordField release];
    [_confirmPasswordField release];
    [_submitBtn release];
    [super dealloc];
}
- (IBAction)submit:(id)sender {
    
    NSString *email=[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *user=[self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *psd=[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rePsd=[self.confirmPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(email.length==0||[email rangeOfString:@"@"].length==0){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入有效的Email", @"login", nil) withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        return;
    }
    if(user.length<6){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入至少6位长度的帐号", @"login", nil) withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        return;
    }
    if(psd.length<6||psd.length>16){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入长度为6-16位的密码", @"login", nil) withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        return;
    }
    if(![psd isEqualToString:rePsd]){
        [self alertInfo:NSLocalizedStringFromTable(@"两次密码输入不一致", @"login", nil) withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic=@{@"email":email,@"uname":user,@"pwd":psd};
    HttpTool *httpTool=[HttpTool shareInstance];
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=regInFr" parameters:dic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        if(code==1){
            [self alertInfo:msg withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        }
        else{
            [self back:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        [self alertInfo:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
    }];
}
-(void)alertInfo:(NSString *)message withTitle:(NSString *)title{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"确定", @"login", nil), nil];
    [alert show];
    [alert release];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
