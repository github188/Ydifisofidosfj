//
//  EditPasswordViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/12/5.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "EditPasswordViewController.h"
#import "HttpTool.h"
#import "AccountInfo.h"

@interface EditPasswordViewController ()

@end

@implementation EditPasswordViewController
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
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
    self.navigationItem.title=NSLocalizedStringFromTable(@"Modify Password", @"login", nil);
    
    self.tipsLbl.text=NSLocalizedStringFromTable(@"Alpha/number/symbol(any cobination of not less than six)", @"login", nil);
//    "Old password"="Old password";
//    "New password"="New password";
//    "Confirm password"="Confirm password";
//    "Submit"="Submit";
//    "Reset"="Reset";
    self.oldPasswordField.placeholder=NSLocalizedStringFromTable(@"Old password", @"login", nil);
    self.newPasswordField.placeholder=NSLocalizedStringFromTable(@"New password", @"login", nil);
    self.reNewPasswordField.placeholder=NSLocalizedStringFromTable(@"Confirm password", @"login", nil);
    [self.submitBtn setTitle:NSLocalizedStringFromTable(@"Submit", @"login", nil) forState:UIControlStateNormal];
    [self.resetBtn setTitle:NSLocalizedStringFromTable(@"Reset", @"login", nil) forState:UIControlStateNormal];
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
    [_tipsLbl release];
    [_oldPasswordField release];
    [_newPasswordField release];
    [_reNewPasswordField release];
    [_submitBtn release];
    [_resetBtn release];
    [_newPasswordField release];
    [super dealloc];
}
-(void)alertInfo:(NSString *)message{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)  message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];
    [alert release];
}
- (IBAction)submit:(id)sender {
    NSString *old=self.oldPasswordField.text;
    NSString *newp=self.newPasswordField.text;
    NSString *reNewp=self.reNewPasswordField.text;
    [old stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [newp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [reNewp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(old.length<6||old.length>16){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入长度为6-16位的密码", @"login", nil)];
        return;
    }
    if(newp.length<6||newp.length>16){
        [self alertInfo:NSLocalizedStringFromTable(@"请输入长度为6-16位的密码", @"login", nil)];
        return;
    }
    if(![newp isEqualToString:reNewp])
    {
        [self alertInfo:NSLocalizedStringFromTable(@"两次密码输入不一致", @"login", nil)];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HttpTool *tool=[HttpTool shareInstance];
    NSDictionary *dic=@{@"id":[NSString stringWithFormat:@"%ld",(long)[AccountInfo getUserId]],@"oldpass":old,@"newpass":newp};
    [tool JsonGetRequst:@"/index.php?ctrl=app&act=chgPass" parameters:dic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        if(code==1){
            [self alertInfo:msg];
        }
        else{
            [self alertInfo:msg];
            [self back:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self alertInfo:error.localizedDescription];
    }];
}

- (IBAction)reset:(id)sender {
    self.oldPasswordField.text=@"";
    self.newPasswordField.text=@"";
    self.reNewPasswordField.text=@"";
}
@end
