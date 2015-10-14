//
//  SnapshotViewController.m
//  P2PCamCEO
//
//  Created by jacky on 15/10/14.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "SnapshotViewController.h"

@interface SnapshotViewController ()

@end

@implementation SnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.camera.delegate2=self;
    
    //获取设置
    SMsgAVIoctrlGetRecReq *request = (SMsgAVIoctrlGetRecReq *)malloc(sizeof(SMsgAVIoctrlGetRecReq));
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_REC_REQ Data:(char *)request DataSize:sizeof(SMsgAVIoctrlGetRecReq)];
    free(request);
    //获取抓拍设置
    SMsgAVIoctrlGetSnapReq *snapRequest=(SMsgAVIoctrlGetSnapReq *)malloc(sizeof(SMsgAVIoctrlGetSnapReq));
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_SNAP_REQ Data:(char *)snapRequest DataSize:sizeof(SMsgAVIoctrlGetSnapReq)];
    free(snapRequest);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [super dealloc];
    [_camera release];
}
- (IBAction)settingRecord:(id)sender {
    SMsgAVIoctrlSetRecReq *request = (SMsgAVIoctrlSetRecReq *)malloc(sizeof(SMsgAVIoctrlSetRecReq));
    request->u32RecChn=12;
    request->u32PlanRecEnable=0;
    request->u32PlanRecLen=60;
    request->u32AlarmRecEnable=0;
    request->u32AlarmRecLen=120;
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SET_REC_REQ Data:(char *)request DataSize:sizeof(SMsgAVIoctrlSetRecReq)];
    free(request);
}

- (IBAction)settingSnapshot:(id)sender {
    SMsgAVIoctrlSetSnapReq *request = (SMsgAVIoctrlSetSnapReq *)malloc(sizeof(SMsgAVIoctrlSetSnapReq));
    request->u32SnapChn=11;
    request->u32SnapCount=2;
    request->u32SnapEnable=1;
    request->u32SnapInterval=10;
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SET_SNAP_REQ Data:(char *)request DataSize:sizeof(SMsgAVIoctrlSetSnapReq)];
    free(request);
}

- (IBAction)getSnapshotList:(id)sender {
    SMsgAVIoctrlGetPreReq *request = (SMsgAVIoctrlGetPreReq *)malloc(sizeof(SMsgAVIoctrlGetPreReq));
    request->resolution=0;
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USEREX_IPCAM_GET_PREVIEW_REQ Data:(char *)request DataSize:sizeof(SMsgAVIoctrlGetPreReq)];
    free(request);
}

-(void)camera:(MyCamera *)camera _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size{
    if(type==IOTYPE_USER_IPCAM_SET_REC_RESP){
        SMsgAVIoctrlSetRecResp* pResult=(SMsgAVIoctrlSetRecResp*)data;
        NSLog(@"设置结果：%d",pResult->result);
    }
    else if(type==IOTYPE_USER_IPCAM_GET_REC_RESP){
        SMsgAVIoctrlGetRecResp *pResult=(SMsgAVIoctrlGetRecResp *)data;
        NSLog(@"%d",pResult->u32PlanRecLen);
    }
    else if(type==IOTYPE_USER_IPCAM_GET_SNAP_RESP){
        SMsgAVIoctrlGetSnapResp *pResult=(SMsgAVIoctrlGetSnapResp *)data;
        NSLog(@"%d",pResult->u32SnapCount);
    }
    else if(type==IOTYPE_USER_IPCAM_SET_SNAP_RESP){
        SMsgAVIoctrlSetSnapResp* pResult=(SMsgAVIoctrlSetSnapResp*)data;
        NSLog(@"设置结果：%d",pResult->result);
    }
    else if(type==IOTYPE_USEREX_IPCAM_GET_PREVIEW_RESP){
        SMsgAVIoctrlGetPreResp* pResult=(SMsgAVIoctrlGetPreResp*)data;
        //pResult->picinfo 添加到自定义的数组即可
        if(pResult->endflag!=1){
            //继续
            [self getSnapshotList:nil];
        }
    }
}
@end
