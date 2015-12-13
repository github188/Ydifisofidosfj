//
//  ListViewController.m
//  P2PCamCEO
//
//  Created by fourones on 15/12/13.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "ListViewController.h"
#import "AddWithApCameraController.h"
#import "AppDelegate.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadDeviceFromDatabase];
    BOOL isHasCamera=[camera_list count]>0;
    self.myTableView.hidden=!isHasCamera;
    self.noCameraTipLbl.hidden=isHasCamera;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_logo"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_bk"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
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

- (IBAction)add:(id)sender {
    AddWithApCameraController *add=[[[AddWithApCameraController alloc] initWithNibName:@"AddWithApCameraController" bundle:nil] autorelease];
    [self.navigationController pushViewController: add animated:YES];
}
- (void)dealloc {
    [_myTableView release];
    [_noCameraTipLbl release];
    [super dealloc];
}
- (void)loadDeviceFromDatabase {
    if (database != NULL) {
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM device"];
        int cnt = 0;
        
        while([rs next] && cnt++ < MAX_CAMERA_LIMIT) {
            
            NSString *uid = [rs stringForColumn:@"dev_uid"];
            NSString *name = [rs stringForColumn:@"dev_nickname"];
            NSString *view_acc = [rs stringForColumn:@"view_acc"];
            NSString *view_pwd = [rs stringForColumn:@"view_pwd"];
            NSInteger channel = [rs intForColumn:@"channel"];
            NSInteger isSync = [rs intForColumn:@"sync"];
            NSInteger isFromCloud = [rs intForColumn:@"isFromCloud"];
            NSLog(@"Load Camera(%@, %@, %@, %@, %d, ch:%d)", name, uid, view_acc, view_pwd, (int)isFromCloud, (int)channel);
            
            MyCamera *tempCamera = [[MyCamera alloc] initWithName:name viewAccount:view_acc viewPassword:view_pwd];
            [tempCamera setLastChannel:channel];
            [tempCamera connect:uid];
            [tempCamera setSync:isSync];
            [tempCamera setCloud:isFromCloud];
            [tempCamera start:0];
            
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [tempCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [tempCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
            
            SMsgAVIoctrlTimeZone s3={0};
            s3.cbSize = sizeof(s3);
            [tempCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
            [camera_list addObject:tempCamera];
            [tempCamera release];
        }
        [rs close];
    }
}
#pragma mark - AddCameraDelegate Methods
- (void)camera:(NSString *)UID didAddwithName:(NSString *)name password:(NSString *)password syncOnCloud:(BOOL)isSync addToCloud:(BOOL)isAdd addFromCloud:(BOOL)isFromCloud {
    
    
    
    MyCamera *camera_ = [[MyCamera alloc] initWithName:name viewAccount:@"admin" viewPassword:password];
    [camera_ connect:UID];
    [camera_ start:0];
    
    SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
    s->channel = 0;
    [camera_ sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
    free(s);
    
    SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
    [camera_ sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
    free(s2);
    
    if ( [camera_ getTimeZoneSupportOfChannel:0] ){
        SMsgAVIoctrlTimeZone s3={0};
        s3.cbSize = sizeof(s3);
        [camera_ sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [camera_ setSync:[[NSNumber numberWithBool:isSync] intValue]];
    [camera_ setCloud:[[NSNumber numberWithBool:isFromCloud] intValue]];
    [camera_list addObject:camera_];
    
    if (database != NULL) {
        [database executeUpdate:@"INSERT INTO device(dev_uid, dev_nickname, dev_name, dev_pwd, view_acc, view_pwd, channel, sync, isFromCloud) VALUES(?,?,?,?,?,?,?,?,?)",
         camera_.uid, name, name, password, @"admin", password, [NSNumber numberWithInt:0], [NSNumber numberWithBool:isSync], [NSNumber numberWithBool:isFromCloud]];
    }
    
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // register to apns server
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
    dispatch_async(queue, ^{
        if (deviceTokenString != nil) {
            NSError *error = nil;
            NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
            
            NSString *argsString = @"%@?cmd=reg_mapping&token=%@&uid=%@&appid=%@&udid=%@&os=ios";
            NSString *getURLString = [NSString stringWithFormat:argsString, g_tpnsHostString, deviceTokenString, UID, appidString , uuid];
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
#endif
            NSString* registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @">>> %@", registerResult);
            NSLog( @"==============================================");
#endif
        }
    });
    
    [userDefaults synchronize];
    
    [camera_ release];
    
    [self.myTableView reloadData];
}
@end
