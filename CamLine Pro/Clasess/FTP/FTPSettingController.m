//
//  FTPSettingTableViewController.m
//  P2PCamCEO
//
//  Created by apple  on 15/12/31.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "FTPSettingController.h"

@interface FTPSettingController ()

@end

@implementation FTPSettingController

@synthesize camera;
@synthesize delegate;
@synthesize senderIndicator;
@synthesize sServer;

@synthesize sAccount;
@synthesize sPasswd;
@synthesize nPort;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<FTPSettingDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}

- (void)save:(id)sender {
    
    sServer=textFieldServer.text;
    sAccount=textFieldAccount.text;
    sPasswd=textFieldPasswd.text;
    nPort=textFieldPort.text.integerValue;
    
    //send CMD
    SMsgAVIoctrlSetFtpReq *s1 = malloc(sizeof(SMsgAVIoctrlSetFtpReq));
    memset(s1, 0, sizeof(SMsgAVIoctrlSetFtpReq));
    s1->channel = 0;
    memcpy(s1->ftpServer, [sServer UTF8String], [sServer length]);
    memcpy(s1->userName, [sAccount UTF8String], [sAccount length]);
    memcpy(s1->password, [sPasswd UTF8String], [sPasswd length]);
    s1->ftpPort=(int)nPort;
   
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_SET_FTP_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlSetFtpReq)];
    free(s1);
    
    [self.navigationController popViewControllerAnimated:YES];
}
//- (IBAction)cancel:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}
#pragma mark - View lifecycle
- (void)dealloc {
    self.delegate = nil;
    [textFieldServer release];
    [textFieldAccount release];
    [textFieldPasswd release];
    [textFieldPort release];
    [textFieldAccount release];
    [senderIndicator release];
    [labelHint release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    //send CMD
    SMsgAVIoctrlGetFtpReq *s1 = malloc(sizeof(SMsgAVIoctrlGetFtpReq));
    memset(s1, 0, sizeof(SMsgAVIoctrlGetFtpReq));
    s1->channel=0;
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GET_FTP_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlGetFtpReq)];
    free(s1);
    NSLog(@"send IOTYPE_USER_IPCAM_GET_FTP_REQ");
}

- (void)setUI
{
    //1. Chrysanthemum
    float x =  ([UIScreen mainScreen].bounds.size.width - 30) * 0.5;
    senderIndicator = [ [ UIActivityIndicatorView alloc ]initWithFrame:CGRectMake(x,20.0,30.0,30.0)];
    senderIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    senderIndicator.hidesWhenStopped = YES;
    [ self.view addSubview:senderIndicator ];
    [senderIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(senderIndicator.isAnimating){
            [senderIndicator stopAnimating];
            labelHint=[[UILabel alloc]initWithFrame:CGRectMake(0.0,60.0,[UIScreen mainScreen].bounds.size.width,130.0)];
            labelHint.textAlignment =  NSTextAlignmentCenter;
            labelHint.text=NSLocalizedString(@"Remote Device Timeout", @"");
            [self.view addSubview:labelHint];
        }
    });
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                             initWithTitle:NSLocalizedString(@"Cancel", @"")
//                                             style:UIBarButtonItemStylePlain
//                                             target:self
//                                             action:@selector(cancel:)];
//
    //right btn
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(save:)];
    self.navigationItem.rightBarButtonItem.enabled=!senderIndicator.isAnimating;
    self.navigationItem.title = NSLocalizedString(@"FTP Setting", @"");

}
- (void)viewWillAppear:(BOOL)animated {
    
    self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}
- (void)viewDidUnload {
    
    self.senderIndicator = nil;
    self.camera = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int row=1;
    
    return row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(senderIndicator.isAnimating)
        return 0;
    else
        return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger section=[indexPath section];
    NSUInteger row=[indexPath row];
    
    static NSString *SectionTableIdentifier=@"SectionTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionTableIdentifier];
    
    if (cell==nil) {
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionTableIdentifier]autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (row==0) {
            textFieldServer=[[UITextField alloc]initWithFrame:CGRectMake(135,11,160,25)];
        textFieldServer.placeholder=NSLocalizedString(@"FTP Server", @"");
            textFieldServer.clearsOnBeginEditing=NO;
            textFieldServer.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldServer.textColor=[UIColor grayColor];
            [textFieldServer addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldServer];
            cell.textLabel.text=NSLocalizedString(@"FTP Server", @"");
        }else if(row==1){
            textFieldPort=[[UITextField alloc]initWithFrame:CGRectMake(135,11,160,25)];
            textFieldPort.placeholder=NSLocalizedString(@"Port(Default)", @"");
            textFieldPort.clearsOnBeginEditing=NO;
            textFieldPort.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldPort.textColor=[UIColor grayColor];
            [textFieldPort addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            textFieldPort.userInteractionEnabled = NO;
            [cell.contentView addSubview:textFieldPort];
            
            cell.textLabel.text=NSLocalizedString(@"Port", @"");
        }else if(row==2){
            textFieldAccount=[[UITextField alloc]initWithFrame:CGRectMake(135,11,160,25)];
            textFieldAccount.placeholder=NSLocalizedString(@"Account", @"");
            textFieldAccount.clearsOnBeginEditing=NO;
            textFieldAccount.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldAccount.textColor=[UIColor grayColor];
            [textFieldAccount addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldAccount];
            cell.textLabel.text=NSLocalizedString(@"Account", @"");
        }else if(row==3){
            textFieldPasswd=[[UITextField alloc]initWithFrame:CGRectMake(135,11,160,25)];
            textFieldPasswd.placeholder=NSLocalizedString(@"Password", @"");
            textFieldPasswd.clearsOnBeginEditing=NO;
            textFieldPasswd.secureTextEntry = YES;
            textFieldPasswd.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldPasswd.textColor=[UIColor grayColor];
            [textFieldPasswd addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldPasswd];
            cell.textLabel.text=NSLocalizedString(@"Password", @"");
        }
    }
    if (row==0) {
        textFieldServer.text=sServer;
    }else if(row==1){
        textFieldPort.text=[NSString stringWithFormat:@"%ld",(long)self.nPort];
    }else if(row==2){
        textFieldAccount.text=sAccount;
    }else if(row==3){
        textFieldPasswd.text=sPasswd;
        }
    return cell;
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GET_FTP_RESP) {
        
        SMsgAVIoctrlGetFtpResp *s = (SMsgAVIoctrlGetFtpResp*)data;
        self.sServer = [NSString stringWithUTF8String:(char *)s->ftpServer];
        self.sAccount = [NSString stringWithUTF8String:(char *)s->userName];
        self.sPasswd = [NSString stringWithUTF8String:(char *)s->password];
        self.nPort=s->ftpPort;

        labelHint.hidden=YES;
        [senderIndicator stopAnimating];
        self.navigationItem.rightBarButtonItem.enabled=!senderIndicator.isAnimating;
        [self.tableView reloadData];
    }
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_SET_FTP_RESP) {
        SMsgAVIoctrlSetFtpResp *s = (SMsgAVIoctrlSetFtpResp*)data;
        NSLog(@"%d",s->result);
    }
}
- (void)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
}
@end

