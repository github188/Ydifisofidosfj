//
//  DetailRECSettingController.m
//  temptest
//
//  Created by apple  on 16/1/5.
//  Copyright © 2016年 jayzhou. All rights reserved.
//


#define REC_SWITCH_ROW 0
#define REC_ALARM_ROW 1
#define REC_FULLTIME_ROW 2

//#define ALARM_REC_MODE 0
//#define FULLTIME_REC_MODE 1

#import "DetailRECSettingController.h"
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "DefineExtension.h"

#import "FullTimeRECViewController.h"

@interface DetailRECSettingController ()<MyCameraDelegate,FullTimeRECViewControllerDelegate>
{
    char          planTime[49*7]; //planTime[7][49] ;
    UILabel *labelHint;
}
@property (nonatomic ,assign) ENUM_RECORD_TYPE RECType;
@property (nonatomic ,assign) int RECLength;
@property (nonatomic , retain) NSArray * itmes;

@property (nonatomic, retain) UIActivityIndicatorView *senderIndicator;

@end

@implementation DetailRECSettingController
@synthesize camera;
@synthesize senderIndicator;
//lazy loading
- (NSArray *)itmes
{
    if (!_itmes) {
        _itmes = [[NSArray alloc] initWithObjects:
                  NSLocalizedString(@"Open/Close", @""),
                  NSLocalizedString(@"Alarm", @""),
                  NSLocalizedString(@"Full Time", @""),
                  nil];
    }
    return _itmes;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self initData];
    //send CMD
    SMsgAVIoctrlGetRecordReq *s1 = malloc(sizeof(SMsgAVIoctrlGetRecordReq));
    memset(s1, 0, sizeof(SMsgAVIoctrlGetRecordReq));
    s1->channel=0;
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETRECORD_REQ
                           Data:(char *)s1
                       DataSize:sizeof(SMsgAVIoctrlGetRecordReq)];
    free(s1);

}
- (void)viewWillAppear:(BOOL)animated {
    
    camera.delegate2 = self;
    [super viewWillAppear:animated];
}

- (void)setUI
{
    //1.1left btn
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
    //1.2.rightbtn
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(save:)];
    
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
   
    self.navigationItem.rightBarButtonItem.enabled=!senderIndicator.isAnimating;
   

}
- (void)initData
{
   self.RECLength = 500;
    self.RECType = 0;
//    for (int i = 0 ; i<7; i++) {
//        for (int j = 0 ; j<48; j++) {
//        planTime[i][j] = 'N';
//        } 342
//    }343  48 97 146 195 244 293 342
    for (int i = 0; i < 7 *49;  i++) {
        if (i == 48 || i ==97 || i ==146 || i== 195 || i== 244 || i== 293|| i== 342){
            continue;
        }
        planTime[i] = 'N';
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    //1. send cmd
    if (self.RECType == AVIOTC_RECORDTYPE_OFF || self.RECType == AVIOTC_RECORDTYPE_ALARM)
        {
            SMsgAVIoctrlSetRecordReq *s1 = malloc(sizeof(SMsgAVIoctrlSetRecordReq));
            memset(s1, 0, sizeof(SMsgAVIoctrlSetRecordReq));
            s1->channel=0;
            s1->recordType = self.RECType;
            [camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SETRECORD_REQ
                                   Data:(char *)s1
                               DataSize:sizeof(SMsgAVIoctrlSetRecordReq)];
            free(s1);

        }else if (self.RECType == AVIOTC_RECORDTYPE_FULLTIME)
            {
                //1. setting ptf
                SMsgAVIoctrlSetRecReq *s1 = malloc(sizeof(SMsgAVIoctrlSetRecReq));
                memset(s1, 0, sizeof(SMsgAVIoctrlSetRecReq));
                s1->u32RecChn = 12;
                s1->u32PlanRecEnable = 1;
                s1->u32PlanRecLen = self.RECLength;
                s1->u32AlarmRecEnable = 0;
                s1->u32AlarmRecLen = 15;
                [camera sendIOCtrlToChannel:0
                                       Type:IOTYPE_USER_IPCAM_SET_REC_REQ
                                       Data:(char *)s1
                                   DataSize:sizeof(SMsgAVIoctrlSetRecReq)];
                free(s1);
#pragma mark - TODO:
                //2. send plan
                double delayInSeconds = 0.15;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                    SMsgAVIoctrlSetScheduleReq *s2 = malloc(sizeof(SMsgAVIoctrlSetScheduleReq));
                    memset(s2, 0, sizeof(SMsgAVIoctrlSetScheduleReq));
                    
                    memcpy(s2->sDayData, planTime, sizeof(planTime));
                    
                    s2->u32ScheduleType = AVIOTC_SCHEDULETYPE_PLAN;

                    [camera sendIOCtrlToChannel:0
                                           Type:IOTYPE_USER_IPCAM_SET_SCHEDULE_REQ
                                           Data:(char *)s2
                                       DataSize:sizeof(SMsgAVIoctrlSetScheduleReq)];
                    free(s2);

                });

                
            }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Switch 改变
- (void)switchChanged:(UISwitch *)sender
{
    if (!sender.on) {
        self.RECType = AVIOTC_RECORDTYPE_OFF;
        [self.tableView reloadData];
    }
  
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return senderIndicator.isAnimating ? 0 : self.itmes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     tableView.tableFooterView = [[UIView alloc] init];
    
    NSInteger row = indexPath.row;
    static NSString *TableIdentifier = @"SectionTableIdentif";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if (cell == nil)
        {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableIdentifier]
                    autorelease];
            
            
            if (row == REC_SWITCH_ROW) {
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.tag = 7000;
                cell.accessoryView = switchView;
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                [switchView release];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            }
            
        }
    if (row == REC_SWITCH_ROW) {
        [(UISwitch *)cell.accessoryView setOn:(self.RECType != AVIOTC_RECORDTYPE_OFF) ? YES:NO animated:YES];
    } else if (self.RECType == AVIOTC_RECORDTYPE_ALARM && row == REC_ALARM_ROW)
                {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }else if (self.RECType == AVIOTC_RECORDTYPE_FULLTIME && row == REC_FULLTIME_ROW)
                        {
                            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                
                        }
    
    cell.textLabel.text = self.itmes[row];
    return cell;
}

#pragma mark - tableview delegate M

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = [indexPath row];
    if (row != REC_SWITCH_ROW) {
        for (UITableViewCell *cell in [self.tableView visibleCells])
        {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (row == REC_FULLTIME_ROW)
        {
            self.RECType = AVIOTC_RECORDTYPE_FULLTIME;
        //全时录像
            FullTimeRECViewController * fullTimeVC = [[FullTimeRECViewController alloc] initWithNibName:@"FullTimeRECViewController" bundle:nil];
            fullTimeVC.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Full Time", @"")];
            fullTimeVC.delegate = self;
            fullTimeVC.RECLength =self.RECLength;
            [self.navigationController pushViewController:fullTimeVC animated:YES];
        }else if(row == REC_ALARM_ROW)
            {
                self.RECType = AVIOTC_RECORDTYPE_ALARM;
            }
}
#pragma mark - FulltimeREC Delegate
- (void)fullTimeRECViewController:(FullTimeRECViewController *)fullTimeVC scheduleFullTimeFrom:(NSInteger)strat to:(NSInteger)end withRECTime:(id)timeLenght
{
    for (NSInteger i = strat; i <end; i++) {
        if (i == 48 || i ==97 || i ==146 || i== 195 || i== 244 || i== 293|| i== 342){
            continue;
        }
        planTime[i] = 'P';
    }
    self.RECLength = timeLenght;
}
#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GETRECORD_RESP) {
        
        SMsgAVIoctrlGetRecordResp *s = (SMsgAVIoctrlGetRecordResp*)data;
        self.RECType = s->recordType;
        labelHint.hidden=YES;
        [senderIndicator stopAnimating];
        self.navigationItem.rightBarButtonItem.enabled=!senderIndicator.isAnimating;
        
        [self.tableView reloadData];
    }else if (camera_ == camera && type == IOTYPE_USER_IPCAM_SETRECORD_RESP)
        {
            SMsgAVIoctrlSetRecordResp *s = (SMsgAVIoctrlSetRecordResp*)data;
            NSLog(@"设置报警或关闭录像：%d",s->result);
        }else if(camera_ == camera && type == IOTYPE_USER_IPCAM_SET_REC_RESP)
            {
                SMsgAVIoctrlSetRecResp *s = (SMsgAVIoctrlSetRecResp*)data;
                NSLog(@"初始化相机：%d",s->result);
            }else if (camera_ == camera && type == IOTYPE_USER_IPCAM_SET_SCHEDULE_RESP)
                    {
                        SMsgAVIoctrlSetScheduleResp *s =  (SMsgAVIoctrlSetScheduleResp *)data;
                        if (s->result) {
                            NSLog(@"plan rec ：%d",s->result);
                        }
                    }
}

- (void) dealloc
{
    [super dealloc];
    [self.itmes release];
    [senderIndicator release];
    [labelHint release];
}
@end
