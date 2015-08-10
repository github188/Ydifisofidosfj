//
//  MailSmtpController.h
//  IOTCamViewer
//
//  Created by tommy on 14-9-10.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
@protocol MailSmtpDelegate;

@interface MailSmtpController : UITableViewController<MyCameraDelegate>{
    MyCamera *camera;
    NSArray *labelItems;
    NSInteger origValue;
    NSInteger newValue;
    id<MailSmtpDelegate> delegate;

}
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSArray *labelItems;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, assign) id<MailSmtpDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<MailSmtpDelegate>)delegate;
- (IBAction)back:(id)sender;

@end

@protocol MailSmtpDelegate

- (void)didSetMailSmtp:(NSInteger)value;

@end
