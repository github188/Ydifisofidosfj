//
//  FTPSettingTableViewController.h
//  P2PCamCEO
//
//  Created by apple  on 15/12/31.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "DefineExtension.h"
@protocol FTPSettingDelegate;
@interface FTPSettingController : UITableViewController <MyCameraDelegate>{
    MyCamera *camera;
    id<FTPSettingDelegate> delegate;

    UITextField* textFieldServer;
    UITextField* textFieldPort;
    UITextField* textFieldAccount;
    UITextField* textFieldPasswd;
    UIActivityIndicatorView *senderIndicator;
    UILabel *labelHint;
    
    
}
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, assign) id<FTPSettingDelegate> delegate;
@property (nonatomic, retain) UIActivityIndicatorView *senderIndicator;

@property (nonatomic,copy) NSString* sServer;
@property (nonatomic,copy) NSString* sSmtpServer;
@property (nonatomic,copy) NSString* sAccount;
@property (nonatomic,copy) NSString* sPasswd;
@property (nonatomic) NSInteger nPort;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<FTPSettingDelegate>)delegate;


@end

@protocol FTPSettingDelegate
@optional
- (void)didSetMail:(NSInteger)value;

@end