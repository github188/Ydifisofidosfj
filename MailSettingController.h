//
//  MailSettingController.h
//  IOTCamViewer
//
//  Created by tommy on 14-9-5.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "MailProtocolController.h"
#import "MailSmtpController.h"
#import "DefineExtension.h"
@protocol MailSettingDelegate;
@interface MailSettingController : UITableViewController <MyCameraDelegate,MailProtocolDelegate,MailSmtpDelegate>{
    MyCamera *camera;
    NSArray *labelItems;
    NSInteger origValue;
    NSInteger newValue;
    id<MailSettingDelegate> delegate;
    
    //发送者、接收者、mail服务器、端口、协议、用户名、密码
    UITextField* textFieldSender;
    UITextField* textFieldReceiver;
    UITextField* textFieldSmtpServer;
    UITextField* textFieldPort;
    UITextField* textFieldProtocol;
    UITextField* textFieldAccount;
    UITextField* textFieldPasswd;
    UIActivityIndicatorView *senderIndicator;
    UILabel *labelHint;
    
    NSString* sSender;
    NSString* sReceiver;
    NSString* sSmtpServer;
    NSString* sAccount;
    NSString* sPasswd;
    NSInteger nPort;
    NSInteger mailProtocol;
    
    NSInteger nSmtpServerIndex;
    
}
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSArray *labelItems;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, assign) id<MailSettingDelegate> delegate;
@property (nonatomic, retain) UIActivityIndicatorView *senderIndicator;

@property (nonatomic,copy) NSString* sSender;
@property (nonatomic,copy) NSString* sReceiver;
@property (nonatomic,copy) NSString* sSmtpServer;
@property (nonatomic,copy) NSString* sAccount;
@property (nonatomic,copy) NSString* sPasswd;
@property (nonatomic) NSInteger nPort;
@property (nonatomic) NSInteger mailProtocol;


- (IBAction)textFieldDone:(id)sender;
- (id)initWithStyle:(UITableViewStyle)style delgate:(id<MailSettingDelegate>)delegate;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@end

@protocol MailSettingDelegate

- (void)didSetMail:(NSInteger)value;

@end