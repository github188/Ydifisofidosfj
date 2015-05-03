//
//  CameraMultiLiveViewController.h
//  IOTCamViewer
//
//  Created by tutk on 12/7/11.
//  Copyright (c) 2012 TUTK. All rights reserved.
//

#define MAX_IMG_BUFFER_SIZE	(1920*1080*4)
#define PT_SPEED 8
#define PT_DELAY 1.5
#define ZOOM_MAX_SCALE 5.0
#define ZOOM_MIN_SCALE 1.0
#define degreeToRadians(x) (M_PI * (x) / 180.0)

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <IOTCamera/IOTCAPIs.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MyCamera.h"
#import "FMDatabase.h"
#import "WEPopoverController.h"
#import "ChannelPickerContentController.h"
#import "AudioPickerContentController.h"
#import "CameraShowGLView.h"
#import "CameraListForLiveViewController.h"
#import "CameraLiveViewController.h"
#import "AddCameraDetailController.h"
#import "EditCameraDefaultController.h"
#import "DeviceListOnCloud.h"
#import "MBProgressHUD.h"

extern NSMutableArray *camera_list;
extern FMDatabase *database;
extern NSString *deviceTokenString;


@interface CameraMultiLiveViewController : UIViewController
<MyCameraDelegate, UIAlertViewDelegate,CameraListDelegate,CameraLiveViewDelegate,AddCameraDelegate,EditCameraDefaultDelegate,DeviceOnCloudDelegate,MBProgressHUDDelegate> {
    
	unsigned short mCodecId;
	CameraShowGLView *glView;
	CVPixelBufferPoolRef mPixelBufferPool;
	CVPixelBufferRef mPixelBuffer;
	CGSize mSizePixelBuffer;
    UIImageView *connModeImageView;
    NSString *directoryPath;
    ENUM_AUDIO_MODE selectedAudioMode;
    int wrongPwdRetryTime;
	BOOL bStopShowCompletedLock;
    
    NSMutableArray *selectChannelArray;
    IBOutlet UIButton *defaultButton1;
    IBOutlet UIButton *defaultButton2;
    IBOutlet UIButton *defaultButton3;
    IBOutlet UIButton *defaultButton4;
    
    IBOutlet UIButton *reConnectBTN1;
    IBOutlet UIButton *reConnectBTN2;
    IBOutlet UIButton *reConnectBTN3;
    IBOutlet UIButton *reConnectBTN4;

    IBOutlet UIButton *fullScreenButton1;
    IBOutlet UIButton *fullScreenButton2;
    IBOutlet UIButton *fullScreenButton3;
    IBOutlet UIButton *fullScreenButton4;
    BOOL isFullScreen;
    
    IBOutlet UIView * statusBar1;
    IBOutlet UIView * statusBar2;
    IBOutlet UIView * statusBar3;
    IBOutlet UIView * statusBar4;

    IBOutlet UIImageView *cameraConnect1;
    IBOutlet UIImageView *cameraConnect2;
    IBOutlet UIImageView *cameraConnect3;
    IBOutlet UIImageView *cameraConnect4;
    
    IBOutlet UILabel *cameraName1;
    IBOutlet UILabel *cameraName2;
    IBOutlet UILabel *cameraName3;
    IBOutlet UILabel *cameraName4;
    
    IBOutlet UILabel *cameraStatus1;
    IBOutlet UILabel *cameraStatus2;
    IBOutlet UILabel *cameraStatus3;
    IBOutlet UILabel *cameraStatus4;
    
    IBOutlet UIButton *moreFunction1;
    IBOutlet UIButton *moreFunction2;
    IBOutlet UIButton *moreFunction3;
    IBOutlet UIButton *moreFunction4;
    NSNumber *moreFunctionTag;
    
    IBOutlet UIView *moreFunctionView;
    IBOutlet UIButton *changeView;
    IBOutlet UIButton *cameraEvent;
    IBOutlet UIButton *cameraSnapshot;
    IBOutlet UIButton *cameraSetting;
    IBOutlet UIButton *deleteView;
    
    NSMutableArray *cameraArray;
    NSMutableArray *channelArray;
    NSMutableArray *selectCameraArray;
    BOOL isMoreSetOpen;
    IBOutlet UIView *moreSet;
    
    int mnViewTag;
    int viewTag;
    IBOutlet UIButton *dropboxRec;
    IBOutlet UIButton *infoBTN;
    IBOutlet UIButton *logInOut;
    BOOL isLogOut;
    BOOL isDelete;
    
    BOOL isCamStopShow;
    
    MBProgressHUD *HUD;
    BOOL isWaitWiFiResp;
    BOOL isWaitReConnect;
    MyCamera *camNeedReconnect;
	
	NSTimer* mTimerStartShowRevoke;
    BOOL isGoPlayEvent; //是否去了观看录像的界面
    
    BOOL moreFunCViewIsOpen;
	
}

@property (nonatomic, assign) BOOL bStopShowCompletedLock;
@property (nonatomic, assign) unsigned short mCodecId;
@property (nonatomic, assign) CGSize mSizePixelBuffer;
@property (nonatomic, assign) CameraShowGLView *glView;
@property CVPixelBufferPoolRef mPixelBufferPool;
@property CVPixelBufferRef mPixelBuffer;
@property (nonatomic, retain) IBOutlet UIImageView *connModeImageView;
@property (nonatomic, retain) MyCamera *camNeedReconnect;
@property (nonatomic, retain) NSMutableArray *cameraArray;
@property (nonatomic, retain) NSMutableArray *channelArray;
@property ENUM_AUDIO_MODE selectedAudioMode;;
@property (nonatomic, copy) NSString *directoryPath;
@property (nonatomic, retain) NSMutableArray *selectCameraArray;
@property (nonatomic, retain) NSNumber *moreFunctionTag;

@property (retain, nonatomic) IBOutlet UIImageView *vdo1;
@property (retain, nonatomic) IBOutlet UIImageView *vdo2;
@property (retain, nonatomic) IBOutlet UIImageView *vdo3;
@property (retain, nonatomic) IBOutlet UIImageView *vdo4;

- (IBAction)goSetting:(id)sender;
- (IBAction)goAddCamera:(id)sender;
- (IBAction)moreFunction:(id)sender;
- (IBAction)goLiveView:(id)sender;
- (IBAction)changeViewSetting:(id)sender;
- (IBAction)goEventList:(id)sender;
- (IBAction)goSnapshot:(id)sender;
- (IBAction)goSetting:(id)sender;
- (IBAction)deleteViewSetting:(id)sender;
- (IBAction)hideMoreFunctionView:(id)sender;
- (IBAction)goInfo:(id)sender;
- (IBAction)logOut:(id)sender;
- (IBAction)goDropboxRec:(id)sender;
- (IBAction)reConnect:(id)sender;

@end
