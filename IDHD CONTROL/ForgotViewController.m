//
//  ForgotViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/11/17.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "ForgotViewController.h"

@interface ForgotViewController ()

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.emailField.placeholder=NSLocalizedStringFromTable(@"EmailTips", @"login", nil);
    [self.submitBtn setTitle:NSLocalizedStringFromTable(@"Submit", @"login", nil) forState:UIControlStateNormal];
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

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {
    [_emailField release];
    [_submitBtn release];
    [super dealloc];
}
-(void)alertInfo:(NSString *)message withTitle:(NSString *)title{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"确定", @"login", nil), nil];
    [alert show];
    [alert release];
}
- (IBAction)submit:(id)sender {
    NSString *email=[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(email.length==0||![email containsString:@"@"]){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入有效的Email", @"login", nil) withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic=@{@"email":email};
    HttpTool *httpTool=[HttpTool shareInstance];
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=getPwdFr" parameters:dic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        if(code==1){
            [self alertInfo:msg withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
        }
        else{
            [self alertInfo:msg withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
            [self back:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        [self alertInfo:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
    }];
}
@end
