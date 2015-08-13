//
//  MailSettingController.m
//  IOTCamViewer
//
//  Created by tommy on 14-9-5.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "MailSettingController.h"

@interface MailSettingController ()

@end

@implementation MailSettingController

@synthesize camera;
@synthesize labelItems;
@synthesize newValue;
@synthesize origValue;
@synthesize delegate;
@synthesize mailProtocol;
@synthesize senderIndicator;
@synthesize sSender;
@synthesize sReceiver;
@synthesize sSmtpServer;
@synthesize sAccount;
@synthesize sPasswd;
@synthesize nPort;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<MailSettingDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}
- (IBAction)save:(id)sender {
    
    sSender=textFieldSender.text;
    sSmtpServer=textFieldSmtpServer.text;
    nPort=[textFieldPort.text intValue];
    sAccount=textFieldAccount.text;
    sPasswd=textFieldPasswd.text;
    sReceiver=textFieldReceiver.text;
    
    
    SMsgAVIoctrlExSetSmtpReq *s1 = malloc(sizeof(SMsgAVIoctrlExSetSmtpReq));
    memset(s1, 0, sizeof(SMsgAVIoctrlExSetSmtpReq));
    s1->channel = 0;
    memcpy(s1->sender, [sSender UTF8String], [sSender length]);
    memcpy(s1->server, [sSmtpServer UTF8String], [sSmtpServer length]);
    memcpy(s1->user, [sAccount UTF8String], [sAccount length]);
    memcpy(s1->pwd, [sPasswd UTF8String], [sPasswd length]);
    memcpy(s1->receiver1, [sReceiver UTF8String], [sReceiver length]);
    s1->port=nPort;
    s1->mail_tls=mailProtocol;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USEREX_IPCAM_SET_SMTP_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlExSetSmtpReq)];
    free(s1);
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle
- (void)dealloc {
    self.delegate = nil;
    [textFieldSender release];
    [textFieldAccount release];
    [textFieldPasswd release];
    [textFieldReceiver release];
    [textFieldSmtpServer release];
    [senderIndicator release];
    [labelHint release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    mailProtocol=-1;
    newValue=origValue;
    

    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"smtpServers" ofType:@"plist"];
    labelItems=[[NSArray alloc]initWithContentsOfFile:path];
    
    senderIndicator = [ [ UIActivityIndicatorView alloc ]initWithFrame:CGRectMake(150.0,20.0,30.0,30.0)];
    senderIndicator.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
    senderIndicator.hidesWhenStopped = YES;
    [ self.view addSubview:senderIndicator ];
    [senderIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(senderIndicator.isAnimating){
            [senderIndicator stopAnimating];
            labelHint=[[UILabel alloc]initWithFrame:CGRectMake(100.0,60.0,130.0,130.0)];
            labelHint.text=NSLocalizedString(@"Remote Device Timeout", @"");
            [self.view addSubview:labelHint];
        }
    });
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"Cancel", @"")
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(save:)];
    self.navigationItem.rightBarButtonItem.enabled=!senderIndicator.isAnimating;
    self.navigationItem.title = NSLocalizedString(@"Mail Setting", @"");
    self.newValue = -1;
    
    SMsgAVIoctrlExGetSmtpReq *s1 = malloc(sizeof(SMsgAVIoctrlExGetSmtpReq));
    memset(s1, 0, sizeof(SMsgAVIoctrlExGetSmtpReq));
    s1->channel=0;
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USEREX_IPCAM_GET_SMTP_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlExGetSmtpReq)];
    free(s1);
    NSLog(@"send IOTYPE_USEREX_IPCAM_GET_SMTP_REQ");
}
- (void)viewWillAppear:(BOOL)animated {
    
    self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}
- (void)viewDidUnload {
    
    self.senderIndicator = nil;
    self.labelItems = nil;
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
        return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger section=[indexPath section];
    NSUInteger row=[indexPath row];
    
    static NSString *SectionTableIdentifier=@"SectionTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionTableIdentifier];
    
    if (cell==nil) {
        if (row==1) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SectionTableIdentifier]autorelease];
            
        }else if(row==3){
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SectionTableIdentifier]autorelease];
        }else{
            cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionTableIdentifier]autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        if (row==0) {
            textFieldSender=[[UITextField alloc]initWithFrame:CGRectMake(115,11,180,25)];
            textFieldSender.placeholder=NSLocalizedString(@"MailSenderHint", @"");
            textFieldSender.clearsOnBeginEditing=NO;
            textFieldSender.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldSender.textColor=[UIColor grayColor];
            [textFieldSender addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldSender];
            cell.textLabel.text=NSLocalizedString(@"MailSender", @"");
        }else if(row==1){
            textFieldSmtpServer=[[UITextField alloc]initWithFrame:CGRectMake(115,11,180,25)];
            textFieldSmtpServer.placeholder=NSLocalizedString(@"MailServerHint", @"");
            textFieldSmtpServer.clearsOnBeginEditing=NO;
            textFieldSmtpServer.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldSmtpServer.textColor=[UIColor grayColor];
            [textFieldSmtpServer addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.contentView addSubview:textFieldSmtpServer];
            cell.textLabel.text=NSLocalizedString(@"MailServer", @"");
        }else if(row==2){
            textFieldPort=[[UITextField alloc]initWithFrame:CGRectMake(115,11,180,25)];
            textFieldPort.placeholder=NSLocalizedString(@"Port", @"");
            textFieldPort.clearsOnBeginEditing=NO;
            textFieldPort.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldPort.textColor=[UIColor grayColor];
            [textFieldPort addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldPort];
            cell.textLabel.text=NSLocalizedString(@"Port", @"");
        }else if(row==3){//需要改为选项
            cell.textLabel.text=NSLocalizedString(@"MailProtocol", @"");
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }else if(row==4){
            textFieldAccount=[[UITextField alloc]initWithFrame:CGRectMake(115,11,180,25)];
            textFieldAccount.placeholder=NSLocalizedString(@"Account", @"");
            textFieldAccount.clearsOnBeginEditing=NO;
            textFieldAccount.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldAccount.textColor=[UIColor grayColor];
            [textFieldAccount addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldAccount];
            cell.textLabel.text=NSLocalizedString(@"Account", @"");
        }else if(row==5){
            textFieldPasswd=[[UITextField alloc]initWithFrame:CGRectMake(115,11,180,25)];
            textFieldPasswd.placeholder=NSLocalizedString(@"Password", @"");
            textFieldPasswd.clearsOnBeginEditing=NO;
            textFieldPasswd.secureTextEntry = YES;
            textFieldPasswd.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldPasswd.textColor=[UIColor grayColor];
            [textFieldPasswd addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldPasswd];
            cell.textLabel.text=NSLocalizedString(@"Password", @"");
        }else if(row==6){
            textFieldReceiver=[[UITextField alloc]initWithFrame:CGRectMake(115,11,180,25)];
            textFieldReceiver.placeholder=NSLocalizedString(@"MailReceiverHint", @"");
            textFieldReceiver.clearsOnBeginEditing=NO;
            textFieldReceiver.clearButtonMode=UITextFieldViewModeWhileEditing;
            textFieldReceiver.textColor=[UIColor grayColor];
            [textFieldReceiver addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [cell.contentView addSubview:textFieldReceiver];
            cell.textLabel.text=NSLocalizedString(@"MailReceiver", @"");
        }
    }
    if (row==0) {
        textFieldSender.text=sSender;
    }else if(row==1){
        textFieldSmtpServer.text=sSmtpServer;
    }else if(row==2){
        textFieldPort.text=[NSString stringWithFormat:@"%d",self.nPort];
    }else if(row==3){
        NSString *text = nil;
        if (mailProtocol == 0)
            text = [[NSString alloc] initWithString:NSLocalizedString(@"Off", @"")];
        else if (mailProtocol == 1 )
            text = [[NSString alloc] initWithString:NSLocalizedString(@"TLS", @"")];
        else if (mailProtocol == 2 )
            text = [[NSString alloc] initWithString:NSLocalizedString(@"STARTLS", @"")];
        else if(mailProtocol==3){
            text = [[NSString alloc] initWithString:NSLocalizedString(@"SSL", @"")];
        }
        else
            text = nil;
        cell.detailTextLabel.text = text;
        if (text)
            [text release];
    }else if(row==4){
        textFieldAccount.text=sAccount;
    }else if(row==5){
        textFieldPasswd.text=sPasswd;
    }else if(row==6){
        textFieldReceiver.text=sReceiver;
    }

    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSInteger row = [indexPath row];
    if (row==1) {
        MailSmtpController *controller = [[MailSmtpController alloc] initWithStyle:UITableViewStyleGrouped delgate:self];
        controller.camera = self.camera;
        controller.origValue = nSmtpServerIndex;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else if (row==3) {
        MailProtocolController *controller = [[MailProtocolController alloc] initWithStyle:UITableViewStyleGrouped delgate:self];
        controller.camera = self.camera;
        controller.origValue = mailProtocol;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    self.sSender=textFieldSender.text;
    self.sSmtpServer=textFieldSmtpServer.text;
    self.nPort=[textFieldPort.text intValue];
    self.sAccount=textFieldAccount.text;
    self.sPasswd=textFieldPasswd.text;
    self.sReceiver=textFieldReceiver.text;
}
#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USEREX_IPCAM_GET_SMTP_RESP) {
        
        SMsgAVIoctrlExGetSmtpResp *s = (SMsgAVIoctrlExGetSmtpResp*)data;
        self.sSender = [NSString stringWithUTF8String:(char *)s->sender];
        self.sReceiver = [NSString stringWithUTF8String:(char *)s->receiver1];
        self.sSmtpServer = [NSString stringWithUTF8String:(char *)s->server];
        self.sAccount = [NSString stringWithUTF8String:(char *)s->user];
        self.sPasswd = [NSString stringWithUTF8String:(char *)s->pwd];
        self.nPort=s->port;
        self.mailProtocol=s->mail_tls;
        
        labelHint.hidden=YES;
        [senderIndicator stopAnimating];
        self.navigationItem.rightBarButtonItem.enabled=!senderIndicator.isAnimating;
        [self.tableView reloadData];
    }
}
#pragma mark - didSetMailProtocolDelegate Methods
- (void)didSetMailProtocol:(NSInteger)value {
    mailProtocol = value;
    [self.tableView reloadData];
}
#pragma mark - didSetMailSmtpDelegate Methods
- (void)didSetMailSmtp:(NSInteger)value {
    nSmtpServerIndex = value;
    sSmtpServer=[labelItems objectAtIndex:nSmtpServerIndex];
    [self.tableView reloadData];
}
- (IBAction)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
}
@end
