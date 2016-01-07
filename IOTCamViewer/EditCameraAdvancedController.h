//
//  AdvancedSettingController.h
//  IOTCamViewer
//
//  Created by tutk on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "RecordingModeController.h"
#import "MotionDetectionController.h"
#import "VideoQualityController.h"
#import "VideoFlipController.h"
#import "EnvironmentModeController.h"
#import "SecurityCodeController.h"
#import "WiFiNetworkController.h"
#import "TimeZoneListController.h"
#import "FMDatabase.h"
#import "DeviceListOnCloud.h"
#import "ChooseViewController.h"
#if defined(CameraMailSetting)|| defined(CamLineProTarget)
#import "MailSettingController.h"
#import "FTPSettingController.h"
#endif

#ifdef CamLineProTarget
#import "RecordingSettingController.h"
#endif

#define SECURITYCODE_SECTION_INDEX 0
#define VIDEO_SECTION_INDEX 1
#define WIFI_SECTION_INDEX 2
#define EVENT_SECTION_INDEX 3
#define RECORD_SECTION_INDEX 4
#define ABOUTDEVICE_SECTION_INDEX 5
//for CamLineProTarget
#define CamLineProTarget_SECTION_INDEX 3
#define ALARM_SETTING_ROW 0
#define FTP_SETTING_ROW 1
#define MAIL_SETTING_ROW 2
#define SD_CARD_REC_SETTING_ROW 3

extern FMDatabase *database;

@protocol EditCameraAdvancedDelegate;
#if defined(CameraMailSetting) || defined(CamLineProTarget)
@interface EditCameraAdvancedController : UITableViewController 
<MyCameraDelegate, RecordingModeDelegate, MotionDetectionDelegate, VideoQualityDelegate, VideoFlipDelegate, EnvironmentModeDelegate, SecurityCodeDelegate, WiFiNetworkDelegate, TimeZoneChangedDelegate, DeviceOnCloudDelegate,ChooseDelegate,MailSettingDelegate,FTPSettingDelegate> {
#else
@interface EditCameraAdvancedController : UITableViewController
    <MyCameraDelegate, RecordingModeDelegate, MotionDetectionDelegate, VideoQualityDelegate, VideoFlipDelegate, EnvironmentModeDelegate, SecurityCodeDelegate, WiFiNetworkDelegate, TimeZoneChangedDelegate, DeviceOnCloudDelegate,ChooseDelegate> {
#endif
    
    MyCamera *camera;
    NSString *theNewPassword;
    NSString *wifiSSID;  
    NSInteger videoQuality;
    NSInteger videoFlip;
    NSInteger envMode;
    NSInteger motionDetection;
    NSInteger recordingMode;
    NSInteger wifiStatus;
    
    BOOL isRecvWiFi;
    BOOL isNeedReconn;
    BOOL isChangePasswd;
	
	BOOL isWaitingForSetTimeZoneResp;
	SMsgAVIoctrlTimeZone mIoCtrlData_SetTimeZoneBefore;
	NSTimer* timerTimeZoneTimeOut;
    
    UIActivityIndicatorView *videoQualityIndicator;
    UIActivityIndicatorView *videoFlipIndicator;
    UIActivityIndicatorView *envModeIndicator;
    UIActivityIndicatorView *wifiIndicator;
    UIActivityIndicatorView *motionIndicator;
    UIActivityIndicatorView *recordIndicator;
    UIActivityIndicatorView *timezoneIndicator;
    
    id<EditCameraAdvancedDelegate> delegate;
	
	NSMutableArray* arrRequestIoCtrl;
	NSTimer* timerListWifiApResp;
	int nTotalWaitingTime;
	BOOL bTimerListWifiApResp;
	int nLastSelSection;
	int nLastSelRow;
    
    BOOL bPendingWifi;
    BOOL bIsSync;
    
    BOOL summerTime;
    
    NSArray* arrTimeZoneTable;
        
    
    NSString *timeZoneString;
        NSInteger timeZoneValue;
        
        BOOL isHasSDCard;
        
        CGRect detailFrame;
        
}

@property (nonatomic, retain) NSTimer* timerListWifiApResp;
@property (nonatomic, retain) NSMutableArray* arrRequestIoCtrl;
@property (nonatomic, retain) NSTimer* timerTimeZoneTimeOut;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, copy) NSString *theNewPassword;
@property (nonatomic, copy) NSString *wifiSSID;
@property (nonatomic, retain) UIActivityIndicatorView *videoQualityIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *videoFlipIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *envModeIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *wifiIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *motionIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *recordIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *timezoneIndicator;
@property (nonatomic, assign) id<EditCameraAdvancedDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<EditCameraAdvancedDelegate>)delegate;
- (IBAction)back:(id)sender;
@property (nonatomic, retain) IBOutlet UITableViewCell *timeZoneCell;

@end

@protocol EditCameraAdvancedDelegate

- (void)didChangeAdvancedSetting:(NSString *)newPassword :(BOOL)needReconn;

@end
