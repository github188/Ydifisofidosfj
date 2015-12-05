//
//  MyAccountViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/12/5.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "MyAccountViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface MyAccountViewController ()

@end

@implementation MyAccountViewController
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
    self.navigationItem.title=NSLocalizedStringFromTable(@"Account Management", @"login", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_myTableView release];
    [super dealloc];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(void)viewDidLayoutSubviews
{
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    [self.myTableView reloadData];
}
#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 3;
    }
    else{
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key=@"settingCellKey";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:key];
    if(cell==nil){
        cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:key] autorelease];
    }
    else{
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
    cell.backgroundColor=[UIColor whiteColor];
    if(indexPath.row==0){
        cell.backgroundColor=[UIColor clearColor];
    }
    
    UIImage *img=nil;
    NSString *text=nil;
    
    switch (indexPath.row) {
        case 0:
            break;
        case 1:{
            text=NSLocalizedStringFromTable(@"Switch Account", @"login", nil);
            img=[UIImage imageNamed:@"switch.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2:{
            text=NSLocalizedStringFromTable(@"Modify Password", @"login", nil);
            img=[UIImage imageNamed:@"edit.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    
    cell.textLabel.text=text;
    cell.textLabel.textColor=[UIColor colorWithRed:1/255.0 green:1/255.0 blue:1/255.0 alpha:1.0f];
    cell.imageView.image=img;
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==1){
        MBProgressHUD *hud1 = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud1];
        [hud1 showAnimated:YES whileExecutingBlock:^{
            for (MyCamera *ca in camera_list) {
                [ca stop:0];
                [ca disconnect];
            }
            [camera_list removeAllObjects];
        } completionBlock:^{
            UIViewController *rootViewController = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
            [navigationController setNavigationBarHidden:YES];
            [((AppDelegate *)([[UIApplication sharedApplication]delegate])).window setRootViewController:navigationController];
        }];
        [hud1 release];
    }
    else if (indexPath.row==2){
        EditPasswordViewController *pass=[[EditPasswordViewController alloc]initWithNibName:@"EditPasswordViewController" bundle:nil];
        [self.navigationController pushViewController:pass animated:YES];
        [pass release];
    }
}
@end
