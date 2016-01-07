//
//  AlarmTableViewController.m
//  temptest
//
//  Created by apple  on 16/1/3.
//  Copyright © 2016年 jayzhou. All rights reserved.
//
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height;

#define MOTION_DETECTION_ROW 0
#define MOTION_DETECTION_SENSITIVITY 1
#define ALARM_PRESET 2
#define EMAIL_ALARM 3

#import "AlarmTableViewController.h"
#import "Sensitivity&PreSetController.h"

#import "MyCamera.h"
#import "DefineExtension.h"
#import <IOTCamera/AVIOCTRLDEFs.h>

@interface AlarmTableViewController ()<Sensitivity_PreSetControllerDelegate,MyCameraDelegate>
@property (nonatomic, retain) UIActivityIndicatorView *senderIndicator;

@property (nonatomic, retain) UIActivityIndicatorView *motionIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *sensitivityIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *presetIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *alarmIndicator;
@property (nonatomic, retain) UILabel *labelHint;

@property (nonatomic , assign)  NSInteger isMotionSwitch;
@property (nonatomic , assign)  NSInteger motionDetection;
@property (nonatomic , assign)  NSInteger alarmPresetValue;
@property (nonatomic , assign)  NSInteger isEmailAlaram;

/**
 * 传给sensitivity界面选中的行数
 */
@property (nonatomic , assign)  NSInteger sensitivitySelectRow;

@end

@implementation AlarmTableViewController

#pragma mark - VC life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //注意camera  代理位置
    [self initData];
    [self  setUI];
    
   
}

- (void)viewWillAppear:(BOOL)animated {
     self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}
- (void)setUI
{
    //1. Chrysanthemum
    float x =  ([UIScreen mainScreen].bounds.size.width - 30) * 0.5;
    self.senderIndicator = [ [ UIActivityIndicatorView alloc ]initWithFrame:CGRectMake(x,20.0,30.0,30.0)];
    self.senderIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.senderIndicator.hidesWhenStopped = YES;
    [ self.view addSubview:self.senderIndicator ];
    [self.senderIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(self.senderIndicator.isAnimating){
            [self.senderIndicator stopAnimating];
            self.labelHint=[[UILabel alloc]initWithFrame:CGRectMake(0.0,60.0,SCREEN_WIDTH,130.0)];
            self.labelHint.textAlignment =  NSTextAlignmentCenter;
            self.labelHint.text=NSLocalizedString(@"Remote Device Timeout", @"");
            [self.view addSubview:self.labelHint];
        }
    });
    //
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
    //                                             initWithTitle:NSLocalizedString(@"Cancel", @"")
    //                                             style:UIBarButtonItemStylePlain
    //                                             target:self
    //                                             action:@selector(cancel:)];
    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(save:)];
    self.navigationItem.rightBarButtonItem.enabled=!self.senderIndicator.isAnimating;
    self.navigationItem.title = NSLocalizedString(@"Alarm Setting", @"");
    
    
    
    
}
- (void)initData
{
    
    //1 initailze indicator
    self.motionIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.sensitivityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.presetIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.alarmIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    // 2. mark flag
    self.motionDetection = -1;
    self.isEmailAlaram = -1 ;
    self.alarmPresetValue = -1;
    self.sensitivitySelectRow = -1;
    self.isMotionSwitch = -1 ;
    //3. send cmd to server
     //3.1 all
  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    SMsgAVIoctrlGetGuardReqEn *s1 = malloc(sizeof(SMsgAVIoctrlGetGuardReqEn));
    memset(s1, 0, sizeof(SMsgAVIoctrlGetGuardReqEn));
    s1->channel= 0;
    [self.camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETGUARD_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlGetGuardReqEn)];
    free(s1);

    // 3.2 for motion detection
    SMsgAVIoctrlGetMotionDetectReq *s2 = malloc(sizeof(SMsgAVIoctrlGetMotionDetectReq));
    memset(s2, 0, sizeof(SMsgAVIoctrlGetMotionDetectReq));
    s2->channel=0;
    [self.camera sendIOCtrlToChannel:0
                                Type:IOTYPE_USER_IPCAM_GETMOTIONDETECT_REQ
                                Data:(char *)s2
                            DataSize:sizeof(SMsgAVIoctrlGetMotionDetectReq)];
        free(s2);});
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.senderIndicator.isAnimating) {
        return 0;
    }
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    static NSString *TableIdentifier = @"SectionTableIdentif";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    NSString * title = nil;
    NSInteger cellIndicator_X = self.tableView.frame.size.width - 50;
    NSInteger cellIndicator_Y = 23;

    if (cell == nil)
        {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableIdentifier]
                    autorelease];
            if (row == MOTION_DETECTION_ROW || row == EMAIL_ALARM) {
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.tag = 7000+row;
                cell.accessoryView = switchView;
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                [switchView release];
            }else{
           [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
           [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            }
            
        }
    
    // Configure the cell...
    //1.
    if (row == MOTION_DETECTION_ROW) {
        title = nil;
        title = [NSString stringWithString:NSLocalizedString(@"Motion detection", @"")];
        
        if (self.isMotionSwitch < 0) {
            [cell addSubview:self.motionIndicator];
            [self.motionIndicator startAnimating];
            self.motionIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
        }
        else {
            [self.motionIndicator stopAnimating];
            [self.motionIndicator removeFromSuperview];
        }
        [(UISwitch *)cell.accessoryView setOn:self.isMotionSwitch > 0? YES:NO animated:YES];
        
    }else if (row == MOTION_DETECTION_SENSITIVITY) {
        title = nil;
        title = [NSString stringWithString:NSLocalizedString(@"Detection Sensitivity", @"")];
   //         if ([camera getMotionDetectionSettingSupportOfChannel:0]) {
                
                if (self.motionDetection < 0) {
                    [cell addSubview:self.motionIndicator];
                    [self.motionIndicator startAnimating];
                    self.motionIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
                }
                else {
                    [self.motionIndicator stopAnimating];
                    [self.motionIndicator removeFromSuperview];
                }
                NSString *text = nil;
                if (self.motionDetection == 0)
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"", @"")];
                else if (self.motionDetection > 0 && self.motionDetection <= 25)
                {
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Low", @"")];
                    self.sensitivitySelectRow = 0;
                }
                else if (self.motionDetection > 25 && self.motionDetection <= 50){
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", @"")];
                    self.sensitivitySelectRow = 1;
                }
                else if (self.motionDetection > 50 && self.motionDetection <= 75){
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"High", @"")];
                    self.sensitivitySelectRow = 2;
                }
                else if (self.motionDetection == 100){
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Max", @"")];
                    self.sensitivitySelectRow = 3;
                }
                else
                    text = nil;
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
            cell.detailTextLabel.text = text;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
           // detailFrame=cell.detailTextLabel.frame;
            if (text)
                [text release];
        
        
        }else if (row == ALARM_PRESET)
            {
                title = nil;
                title = [NSString stringWithString:NSLocalizedString(@"Alarm Preset", @"")];
                
                if (self.alarmPresetValue < 0) {
                    [cell addSubview:self.sensitivityIndicator];
                    [self.sensitivityIndicator startAnimating];
                    self.sensitivityIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
                }
                else {
                    [self.sensitivityIndicator stopAnimating];
                    [self.sensitivityIndicator removeFromSuperview];
                }
                NSString *text = nil;
                switch (self.alarmPresetValue) {
                    case 0:
                        text = [NSString stringWithFormat:NSLocalizedString(@"NO", @"")];
                        break;
                    case 1:
                        text = [NSString stringWithFormat:NSLocalizedString(@"1", @"")];
                        break;
                    case 2:
                        text = [NSString stringWithFormat:NSLocalizedString(@"2", @"")];
                        break;
                    case 3:
                        text = [NSString stringWithFormat:NSLocalizedString(@"3", @"")];
                        break;
                    case 4:
                        text = [NSString stringWithFormat:NSLocalizedString(@"4", @"")];
                        break;
                    default:
                        text = @"测试！！";
                        break;
                }
                cell.detailTextLabel.text = text;
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

                
        
            }else if (row == EMAIL_ALARM)
            {
                title = nil;
                title = [NSString stringWithString:NSLocalizedString(@"Email Alarm", @"")];
                if (self.isEmailAlaram < 0) {
                    [self.alarmIndicator startAnimating];
                    self.alarmIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
                     [cell addSubview:self.alarmIndicator];
                }
                else {
                    [self.alarmIndicator stopAnimating];
                    [self.alarmIndicator removeFromSuperview];
                }
                [(UISwitch *)cell.accessoryView setOn:self.isEmailAlaram > 0? YES:NO animated:YES];

            }
    
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger selectRow = indexPath.row;
    if (selectRow == MOTION_DETECTION_SENSITIVITY ) {
        Sensitivity_PreSetController * sensitivityVC = [[Sensitivity_PreSetController alloc] initWithStyle:UITableViewStylePlain];
//      sensitivityVC.tableView.tableFooterView = [[UIView alloc] init];
      
        // init data
        sensitivityVC.type = SENSTIVITY_TYPE;
        sensitivityVC.selectRow = self.sensitivitySelectRow;
        sensitivityVC.items = [[NSArray alloc] initWithObjects:
                               NSLocalizedString(@"Low", @""),
                               NSLocalizedString(@"Medium", @""),
                               NSLocalizedString(@"High", @""),
                               NSLocalizedString(@"Max", @""), nil];
        sensitivityVC.delegate = self;
        sensitivityVC.navigationItem.title = [NSString stringWithString:NSLocalizedString(@"Detection Sensitivity", @"")];
        [self.navigationController pushViewController:sensitivityVC animated:YES];
        
    }else if (selectRow == ALARM_PRESET){
        Sensitivity_PreSetController * preSetVC = [[Sensitivity_PreSetController alloc] initWithStyle:UITableViewStylePlain];
        // init data
        preSetVC.type = PRESET_TYPE;
        preSetVC.selectRow = self.alarmPresetValue;
        preSetVC.items = [[NSArray alloc] initWithObjects:
                               NSLocalizedString(@"NO", @""),
                               NSLocalizedString(@"1", @""),
                               NSLocalizedString(@"2", @""),
                               NSLocalizedString(@"3", @""),
                               NSLocalizedString(@"4", @""),
                                nil];
        preSetVC.delegate = self;
        preSetVC.navigationItem.title = [NSString stringWithString:NSLocalizedString(@"Alarm Preset", @"")];
        [self.navigationController pushViewController:preSetVC animated:YES];

    }

}
#pragma mark - Switch 改变
- (void)switchChanged:(UISwitch *)sender
{
    NSLog(@"====%d===",sender.isOn);
    if (sender.tag == 7000) self.isMotionSwitch = sender.isOn;
    else if (sender.tag == 7003) self.isEmailAlaram = sender.isOn ;
    NSLog(@"=====%d=====",self.isMotionSwitch);}
#pragma mark - 保存设置 
- (void)save:(id)sender
{
    //save  and loadup
    //send CMD
    SMsgAVIoctrlSetGuardReqEn *s1 = malloc(sizeof(SMsgAVIoctrlSetGuardReqEn));
    memset(s1, 0, sizeof(SMsgAVIoctrlSetGuardReqEn));
    s1->channel = 0;
//    memcpy(s1->ftpServer, [sServer UTF8String], [sServer length]);
//    memcpy(s1->userName, [sAccount UTF8String], [sAccount length]);
//    memcpy(s1->password, [sPasswd UTF8String], [sPasswd length]);
//    s1->ftpPort=(int)nPort;
    s1->alarm_motion_armed = self.isMotionSwitch;
    s1->alarm_motion_sensitivity = self.motionDetection;
    s1->alarm_preset = self.alarmPresetValue;
    s1->alarm_mail = self.isEmailAlaram;
    NSLog(@"=====%d=====",self.isMotionSwitch);
    [self.camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_SETGUARD_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlSetGuardReqEn)];
    free(s1);

    //quit
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - sensi &preset Delegate 
-(void)didSelectSensitivityValue:(NSInteger)value
{
    self.motionDetection = value;
    [self.tableView reloadData];
}

-(void)didSelectPresetValue:(NSInteger)value
{
    self.alarmPresetValue = value;
    [self.tableView reloadData];

}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    NSLog(@"＋＋＋＋＋＋＋＋%s＋＋＋＋＋＋＋",data);
    if (camera_ == self.camera && type == IOTYPE_USER_IPCAM_GETGUARD_RESP) {//1057
        
        SMsgAVIoctrlGetGuardRespEn *s = (SMsgAVIoctrlGetGuardRespEn*)data;
        self.isMotionSwitch = s->alarm_motion_armed;
        self.motionDetection = s->alarm_motion_sensitivity;
        NSLog(@"@@@@@@%ld@@@@@@@",self.motionDetection);
        self.alarmPresetValue = s->alarm_preset;
        self.isEmailAlaram = s->alarm_mail;
        self.labelHint.hidden=YES;
        [self.senderIndicator stopAnimating];
        self.navigationItem.rightBarButtonItem.enabled=!self.senderIndicator.isAnimating;
        [self.tableView reloadData];
    }else if (camera_ == self.camera && type == IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP)
    {
        
        SMsgAVIoctrlGetMotionDetectResp *s = (SMsgAVIoctrlGetMotionDetectResp*)data;
        self.motionDetection = s->sensitivity;
        [self.tableView reloadData];

    }
    
}
- (void)dealloc
{
    [super dealloc];
    [self.motionIndicator release];
    [self.sensitivityIndicator release];
    [self.presetIndicator release];
    [self.alarmIndicator release];
    [self.senderIndicator release];
    [self.labelHint release];
    
}
@end
