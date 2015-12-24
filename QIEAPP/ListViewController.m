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
#define CAMERA_NAME_TAG 1
#define CAMERA_STATUS_TAG 2
#define CAMERA_UID_TAG 3
#define CAMERA_SNAPSHOT_TAG 4

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
    self.navigationController.navigationBar.translucent = NO;
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_logo"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
    [self initPopView];
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
    [_tableViewCell release];
    [popView release];
    [super dealloc];
}
- (void)loadDeviceFromDatabase {
    if (database != NULL) {
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM device"];
        while([rs next]) {
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
            tempCamera.delegate2=self;
            [tempCamera release];
        }
        [rs close];
    }
}
- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[[dirs objectAtIndex:0] stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}
- (void)unRegMapping:(NSString *)uid {
    
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // unregister from apns server
    dispatch_queue_t queue = dispatch_queue_create("apns-unreg_client", NULL);
    dispatch_async(queue, ^{
        if (true) {
            NSError *error = nil;
            NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
#ifndef DEF_APNSTest
            NSString *hostString = g_tpnsHostString;
#else
            NSString *hostString = g_tpnsHostString; //測試Host
#endif
            NSString *argsString = @"%@?cmd=unreg_mapping&uid=%@&appid=%@&udid=%@&os=ios";
            NSString *getURLString = [NSString stringWithFormat:argsString, hostString, uid, appidString, uuid];
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
#endif
            NSString *unregisterResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
            
            NSLog( @"==============================================");
            NSLog( @">>> %@", unregisterResult );
            NSLog( @"==============================================");
            if (error != NULL) {
                NSLog(@"%@",[error localizedDescription]);
                
                if (database != NULL) {
                    [database executeUpdate:@"INSERT INTO apnsremovelst(dev_uid) VALUES(?)",uid];
                }
            }
        }
    });
    dispatch_release(queue);
}

- (void)doMapping:(NSString *)uid{
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_mapping", NULL);
    dispatch_async(queue, ^{
        if (deviceTokenString != nil) {
            NSError *error = nil;
            NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
#ifndef DEF_APNSTest
            NSString *hostString = g_tpnsHostString;
#else
            NSString *hostString = g_tpnsHostString; //測試Host
#endif
            NSString *argsString = @"%@?cmd=reg_mapping&token=%@&uid=%@&appid=%@&udid=%@&os=ios";
            NSString *getURLString = [NSString stringWithFormat:argsString, hostString, deviceTokenString, uid, appidString , uuid];
            
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
            
            NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
            
            NSLog( @"==============================================");
            NSLog( @">>> %@", registerResult );
            NSLog( @"==============================================");
        }
    });
    
    dispatch_release(queue);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate->passwordChanged = NO;
}
#pragma mark --UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [camera_list count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CameraListCellIdentifier = @"CameraListCellIdentifier";
    
    UITableViewCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
    
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CameraListCell" owner:self options:nil];
        
        if ([nib count] > 0)
            cell = self.tableViewCell;
    }
    
    NSUInteger row = [indexPath row];
    {
        Camera *camera = [camera_list objectAtIndex:row];
        
        /* load camera name */
        UILabel *cameraNameLabel = (UILabel *)[cell viewWithTag:CAMERA_NAME_TAG];
        if (cameraNameLabel != nil)
        {
            cameraNameLabel.text = camera.name;
        }
        /* load camera status */
        UILabel *cameraStatusLabel = (UILabel *)[cell viewWithTag:CAMERA_STATUS_TAG];
        
        if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Connecting...", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
            }
            NSLog(@"%@ connecting", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Off line", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Off line", @"");
            }
            NSLog(@"%@ off line", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Unknown Device", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Unknown Device", @"");
            }
            NSLog(@"%@ unknown device", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Timeout", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Timeout", @"");
            }
            NSLog(@"%@ timeout", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Unsupported", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Unsupported", @"");
            }
            NSLog(@"%@ unsupported", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Connect Failed", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Connect Failed", @"");
            }
            NSLog(@"%@ connected failed", camera.uid);
        }
        
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
            if( g_bDiagnostic ) {
                
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ [%@]%ld,C:%ld,D:%ld,r%d", NSLocalizedString(@"Online", @""), [MyCamera getConnModeString:camera.sessionMode], (long)camera.connTimes, (long)camera.natC, (long)camera.natD, camera.nAvResend ];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Online", @"");
            }
            NSLog(@"%@ online", camera.uid);
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (appDelegate->passwordChanged==YES){
                [self doMapping:camera.uid];
            }
            
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_CONNECTING)", NSLocalizedString(@"Connecting...", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
            }
            NSLog(@"%@ connecting", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED)
        {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_DISCONNECTED)", NSLocalizedString(@"Off line", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Off line", @"");
            }
            NSLog(@"%@ off line", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_UNKNOWN_DEVICE)", NSLocalizedString(@"Unknown Device", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Unknown Device", @"");
            }
            NSLog(@"%@ unknown device", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_WRONG_PASSWORD)", NSLocalizedString(@"Wrong Password", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Wrong Password", @"");
            }
            NSLog(@"%@ wrong password", camera.uid);
            
            //Un-mapping
            [self unRegMapping:camera.uid];
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_TIMEOUT)", NSLocalizedString(@"Timeout", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Timeout", @"");
            }
            NSLog(@"%@ timeout", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_UNSUPPORTED)", NSLocalizedString(@"Unsupported", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Unsupported", @"");
            }
            NSLog(@"%@ unsupported", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
            if( g_bDiagnostic ) {
                cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_NONE)", NSLocalizedString(@"Connecting...", @""), (long)camera.connTimes];
            }
            else {
                cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
            }
            NSLog(@"%@ wait for connecting", camera.uid);
        }
        
        /* load camera UID */
        UILabel *cameraUIDLabel = (UILabel *)[cell viewWithTag:CAMERA_UID_TAG];
        if (cameraUIDLabel != nil)
        {
            cameraUIDLabel.text = camera.uid;
        }
        /* load camera snapshot */
        UIImageView *cameraSnapshotImageView = (UIImageView *)[cell viewWithTag:CAMERA_SNAPSHOT_TAG];
        if (cameraSnapshotImageView != nil) {
            NSString *imgFullName = [self pathForDocumentsResource:[NSString stringWithFormat:@"%@.jpg", camera.uid]];
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imgFullName];
            
            cameraSnapshotImageView.image = fileExists ? [UIImage imageWithContentsOfFile:imgFullName] : [UIImage imageNamed:@"videoClip.png"];
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
#pragma mark - AddCameraDelegate Methods
- (void)camera:(NSString *)UID didAddwithName:(NSString *)name password:(NSString *)password syncOnCloud:(BOOL)isSync addToCloud:(BOOL)isAdd addFromCloud:(BOOL)isFromCloud {
    
    
    
    MyCamera *camera_ = [[MyCamera alloc] initWithName:name viewAccount:@"admin" viewPassword:password];
    [camera_ connect:UID];
    [camera_ start:0];
    camera_.delegate2=self;
    
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
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
            NSString* registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
            NSLog( @"==============================================");
            NSLog( @">>> %@", registerResult);
            NSLog( @"==============================================");
        }
    });
    
    [userDefaults synchronize];
    
    [camera_ release];
    
    [self.myTableView reloadData];
}
#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera _didChangeSessionStatus:(NSInteger)status
{
    if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera disconnect];
            
        });
    }
        [self.myTableView reloadData];
}

- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (status == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera stop:channel];
            
            usleep(500 * 1000);
            
            [camera disconnect];
        });
    }
        [self.myTableView reloadData];
}
#pragma mark --构建弹窗层
-(void)initPopView{
    if(popView) return;
    popView=[[UIView alloc]init];
    [self.view addSubview:popView];
    CGSize popSize=CGSizeMake(272, 77);
    [popView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(popSize);
        make.center.equalTo(self.view);
    }];
    //背景图
    UIImageView *bgImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-box.png"]];
    [popView addSubview:bgImgView];
    popView.hidden=YES;
    popView.alpha=0;
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(popView);
        make.center.equalTo(popView);
    }];
    [bgImgView release];
    //点击x按钮
    UIButton *closeButton=[[UIButton alloc]init];
    [popView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.mas_equalTo(@(6));
        make.top.mas_equalTo(@(-6));
    }];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close-click.png"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closePop:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton release];
    
    //按钮部分
    NSArray *itemDatas=@[@"pin.png",@"more_event.png",@"more_photo.png",@"more_set.png",@"more_delete.png"];
    NSInteger itemW,itemH;
    itemW=itemH=44;
    CGFloat marginW=(popSize.width-itemW*[itemDatas count])/([itemDatas count]+1);
    
    UIButton *lastView=nil;
    NSInteger index=0;
    for (NSString *s in itemDatas) {
        UIButton *btn=[[UIButton alloc]init];
        [btn setBackgroundImage:[UIImage imageNamed:s] forState:UIControlStateNormal];
        [popView addSubview:btn];
        btn.tag=index;
        index++;
        [btn addTarget:self action:@selector(popClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn release];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(itemW, itemH));
            make.centerY.equalTo(popView);
            if(lastView){
                make.left.mas_equalTo(lastView.mas_right).with.mas_offset(@(marginW));
            }
            else{
                make.left.mas_offset(@(marginW));
            }
        }];
        lastView=btn;
    }
    lastView=nil;
}
#pragma mark --弹窗的相关事件
-(void)closePop:(id)sender{
    [UIView beginAnimations:@"imageViewSmall" context:nil];
    [UIView setAnimationDuration:0.2];
    [popView setAlpha:0.0];
    CGAffineTransform newTransform =  CGAffineTransformScale(popView.transform, 1.0, 1.0);
    [popView setTransform:newTransform];
    [UIView commitAnimations];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:0.2];
}
- (void)hideAnimation{
    popView.hidden = YES;
}

- (void)bigAnimation {
    
    [UIView beginAnimations:@"imageViewBig" context:nil];
    [UIView setAnimationDuration:0.2];
    [popView setAlpha:1.0];
    CGAffineTransform newTransform = CGAffineTransformConcat(popView.transform,  CGAffineTransformInvert(popView.transform));
    [popView setTransform:newTransform];
    [UIView commitAnimations];
    [self performSelector:@selector(smallAnimation) withObject:nil afterDelay:0.2];
}

- (void)bigAnimation2 {
    
    [UIView beginAnimations:@"imageViewBig" context:nil];
    [UIView setAnimationDuration:0.1];
    CGAffineTransform newTransform = CGAffineTransformConcat(popView.transform,  CGAffineTransformInvert(popView.transform));
    [popView setTransform:newTransform];
    [UIView commitAnimations];
}

- (void)smallAnimation {
    
    [UIView beginAnimations:@"imageViewSmall" context:nil];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform newTransform2 =  CGAffineTransformScale(popView.transform, 0.9, 0.9);
    [popView setTransform:newTransform2];
    [UIView commitAnimations];
    
    [self performSelector:@selector(bigAnimation2) withObject:nil afterDelay:0.2];
}
-(void)openPop:(id)sender{
    [popView setHidden:NO];
    CGAffineTransform newTransform = CGAffineTransformScale(popView.transform, 0.1, 0.1);
    [popView setTransform:newTransform];
    [self performSelector:@selector(bigAnimation)];
}
-(void)topCamera:(id)sender{
    
}
-(void)eventCamera:(id)sender{
    
}
-(void)photoCamera:(id)sender{
    
}
-(void)setttingCamera:(id)sender{
    
}
-(void)deleteCamera:(id)sender{
    
}
-(void)popClicked:(UIButton *)btn{
    NSInteger index=btn.tag;
    switch (index) {
        case 0:
            [self topCamera:btn];
            break;
        case  1:
            [self eventCamera:btn];
            break;
        case  2:
            [self photoCamera:btn];
            break;
        case 3:
            [self setttingCamera:btn];
            break;
        case 4:
            [self deleteCamera:btn];
            break;
        default:
            break;
    }
}

@end
