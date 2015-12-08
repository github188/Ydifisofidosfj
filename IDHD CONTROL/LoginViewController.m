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
    
    self.rememberBtn.selected=[AccountInfo isRemember];
    self.userNameField.text=[AccountInfo getUserName];
    self.passwordField.text=[AccountInfo getPassword];
    
    
    
    if (database != NULL) {
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM device"];
        while([rs next]) {
            NSString *uid = [rs stringForColumn:@"dev_uid"];
            [self unMapping:uid];
        }
    }
    
    
    
}

-(void)unMapping:(NSString *)uid{
    // unregister from apns server
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
    dispatch_async(queue, ^{
        if (true) {
            NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
            NSError *error = nil;
            NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
            
            NSString *argsString = @"%@?cmd=unreg_mapping&uid=%@&appid=%@&udid=%@&os=ios";
            NSString *getURLString = [NSString stringWithFormat:argsString, g_tpnsHostString, uid, appidString, uuid];
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
#endif
            NSString *unregisterResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
            
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @">>> %@", unregisterResult );
            NSLog( @"==============================================");
#endif
            if (error != NULL) {
                NSLog(@"%@",[error localizedDescription]);
                
                if (database != NULL) {
                    [database executeUpdate:@"INSERT INTO apnsremovelst(dev_uid) VALUES(?)",uid];
                }
            }
            
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @">>> %@", unregisterResult );
            NSLog( @"==============================================");
            if (error != NULL) {
                NSLog(@"%@",[error localizedDescription]);
            }
#endif
        }
    });
    
    dispatch_release(queue);
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
            [AccountInfo SignIn:id withUserName:user withPassword:psd withIsRemember:self.rememberBtn.selected];
            if(!self.isReLogin){
                CameraMultiLiveViewController *vc=[[[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil] autorelease];
                AppDelegate *delegate=(AppDelegate *)([[UIApplication sharedApplication] delegate]);
                
                UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
                [navigationController setNavigationBarHidden:YES];
                [delegate.window setRootViewController:navigationController];
            }
            else{
                self.navigationController.viewControllers[0].view=nil;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
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
