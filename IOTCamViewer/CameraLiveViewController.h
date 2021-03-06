//
//  CameraLiveViewController.h
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

#define SOUND_CONTROL 0
#define RECORDING 1
#define SNAPSHOT 2
#define MIRROR_UP_DOWN 3
#define MIRROR_LEFT_RIGHT 4
//#define GO_CAMERA_SET 4
#define QVGA 5
#define EMODE 6
//jay add for Camline Pro
#define LANDSCAPE_GAP 12
#define CONTRAST 12
#define BRIGHT  13
#define INFRARED 14 //红外
#define RESTRORE 15

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+TextSize.h"
#import "MyCamera.h"
#import "FMDatabase.h"
#import "WEPopoverController.h"
#import "ChannelPickerContentController.h"
#import "AudioPickerContentController.h"
#import "CameraShowGLView.h"
#import "APLEAGLView.h"
#import "MKHorizMenu.h"
#import "Categories.h"
#import "EditCameraDefaultController.h"
#import <VideoRecorderSDK/VideoRecorderSDK.h>
#import "DefineExtension.h"

extern FMDatabase *database;
extern NSString *deviceTokenString;

@protocol CameraLiveViewDelegate;

@interface CameraLiveViewController : UIViewController 
<MyCameraDelegate, MonitorTouchDelegate, EditCameraDefaultDelegate, UIScrollViewDelegate, ChannelPickerDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,UIActionSheetDelegate> {
    
	unsigned short mCodecId;
	CameraShowGLView *glView;
	CVPixelBufferPoolRef mPixelBufferPool;
	CVPixelBufferRef mPixelBuffer;
	CGSize mSizePixelBuffer;
	
    UIView *portraitView;
    UIView *landscapeView;
    Monitor *monitorPortrait;
    Monitor *monitorLandscape;
    UIScrollView *scrollViewPortrait;
    UIScrollView *scrollViewLandscape;
    UIActivityIndicatorView *loadingViewPortrait;
    UIActivityIndicatorView *loadingViewLandscape;
    
    UIImageView *connModeImageView;
    
    UILabel *statusLabel;
    UILabel *modeLabel;    
    UILabel *videoInfoLabel;
    UILabel *frameInfoLabel;

    NSString *directoryPath;

    MyCamera *camera;
    
    NSInteger selectedChannel;
    ENUM_AUDIO_MODE selectedAudioMode;
    WEPopoverController *multiStreamPopoverController;
    Class popoverClass;
    
    int wrongPwdRetryTime;
	BOOL bStopShowCompletedLock;
    
	IBOutlet UIButton *btnPlaySwitcher_Portrait;
	IBOutlet UIButton *btnPlaySwitcher_Landscpae;
    
    //for CEO
    MKHorizMenu *_horizMenu;
    MKHorizMenu *_longHorizMenu;
    NSMutableArray *_items;
    NSMutableArray *_selectItems;
    
    BOOL isListening;
    BOOL isTalking;
    IBOutlet UIView *talkButton;
    IBOutlet UIView *longTalkButton;//2
    IBOutlet UIButton *AudioTitle;
    IBOutlet UIButton *longAudioTitle;
    
    BOOL isVerticalFlip;
    BOOL isHorizontalFlip;
    
    BOOL isQVGAView;
    IBOutlet UIScrollView *scrollQVGAView;
    IBOutlet UIView *qvgaView;
    IBOutlet UIView *longQVGAView; //1
    IBOutlet UIButton *setHighest;
    IBOutlet UIButton *setHigh;
    IBOutlet UIButton *setMedium;
    IBOutlet UIButton *setLow;
    IBOutlet UIButton *setLowest;
    IBOutlet UIButton *QVGATitle;
    IBOutlet UIButton *longQVGATitle;
    IBOutlet UIButton *longSetHighest;
    IBOutlet UIButton *longSetHigh;
    IBOutlet UIButton *longSetMedium;
    IBOutlet UIButton *longSetLow;
    IBOutlet UIButton *longSetLowest;
    
    BOOL isEModeView;
    IBOutlet UIScrollView *scrollEModeView;
    IBOutlet UIView *emodeView;
    IBOutlet UIView *longEModeView;//3
    IBOutlet UIButton *set50Hz;
    IBOutlet UIButton *set60Hz;
    IBOutlet UIButton *setOutDoor;
    IBOutlet UIButton *setNight;
    IBOutlet UIButton *EModeTitle;
    IBOutlet UIButton *longSetOutDoor;
    IBOutlet UIButton *longSetNight;
    IBOutlet UIButton *longEModeTitle;
    
    BOOL isLandscape;
    NSTimer *hideToolBarTimer;
    /**
     * 菜单是否为激活状态
     */
    BOOL isActive;
    
    IBOutlet UIButton *zoomDigital;
    IBOutlet UIButton *zoomOptics;
    
    NSNumber *viewTag;
    BOOL isChangeChannel;
    
    IBOutlet UIView *statusBar;
    
    VideoGenerator* videoGenerator;
    BOOL isRecording;
    NSString *recordFileName;
	CGSize msizeOrgVideoResolution;	// During local recording cannot change this , and also cannot do listen / talk function
    
    BOOL bIsChangeChannnel;
    
    BOOL isMyRationed;
    
    char emode;
    
    BOOL isHiddenTopNav;
    
    
    BOOL isBright;
    BOOL isContrast;
    
    BOOL isInfrared;//add by jay;
    BOOL isPrePosition;
    
    NSArray *preBtnArr;

    //jay add
    NSInteger selectIdex;

    
    UIView *swipCameraPopView;
    
    NSMutableArray *swipCameraBtns;
    
    UIBarButtonItem *listButtonItem;
    
    NSTimer *wenDuLblTimer;

}

//for Recording

@property(nonatomic) NSInteger cameraQVGANumber;

@property (retain, nonatomic) VideoGenerator* videoGenerator;

@property (nonatomic, retain) NSNumber *viewTag;
@property (nonatomic, retain) NSString *recordFileName;
@property (nonatomic, assign) id<CameraLiveViewDelegate> delegate;

@property (nonatomic, assign) BOOL bStopShowCompletedLock;
@property (nonatomic, assign) unsigned short mCodecId;
@property (nonatomic, assign) CGSize mSizePixelBuffer;
@property (nonatomic, assign) CameraShowGLView *glView;
@property CVPixelBufferPoolRef mPixelBufferPool;
@property CVPixelBufferRef mPixelBuffer;
@property (nonatomic, retain) IBOutlet UIView *portraitView;
@property (nonatomic, retain) IBOutlet UIView *landscapeView;
@property (nonatomic, retain) IBOutlet Monitor *monitorPortrait;
@property (nonatomic, retain) IBOutlet Monitor *monitorLandscape;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewPortrait;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewLandscape;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingViewPortrait;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingViewLandscape;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *modeLabel;
@property (nonatomic, retain) IBOutlet UILabel *videoInfoLabel;
@property (nonatomic, retain) IBOutlet UILabel *frameInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *qualityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *connModeImageView;
@property (nonatomic, retain) MyCamera *camera;
@property NSInteger selectedChannel;
@property ENUM_AUDIO_MODE selectedAudioMode;;
@property (nonatomic, retain) WEPopoverController *multiStreamPopoverController;
@property (nonatomic, copy) NSString *directoryPath;

@property (nonatomic, retain) IBOutlet MKHorizMenu *horizMenu;
@property (nonatomic, retain) IBOutlet MKHorizMenu *longHorizMenu;

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *selectItems;
@property (nonatomic, retain)NSTimer *hideToolBarTimer;
@property(nonatomic) BOOL isCanSendSetCameraCMD;
@property(nonatomic) BOOL isTalkButtonAction;

- (IBAction)back:(id)sender;
- (IBAction)snapshot:(id)sender;
- (IBAction)selectChannel:(id)sender;
- (IBAction)selectAudio:(id)sender;
- (IBAction)onPlaySwitcher:(id)sender;
- (IBAction)talkOn:(id)sender;
- (IBAction)talkOff:(id)sender;
/**
 * 设置qvga 模式
 */
- (IBAction)onBtnSetQVGA:(id)sender;
- (IBAction)onBtnSetEMode:(id)sender;
//- (IBAction)onBtnSetCamera:(id)sender;

//云台转动方向键
/**
 * 控制相机转动方向 view
 */
@property (retain, nonatomic) IBOutlet UIView *myPtzView;
@property (retain, nonatomic) IBOutlet UIButton *myPTZDownBtn;
- (IBAction)myPtzDownAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *myPtzUpBtn;
- (IBAction)myPtzUpAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *myPtzLeftBtn;
- (IBAction)myPtzLeftAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *myPtzRightBtn;
- (IBAction)myPtzRightAction:(id)sender;
-(void)myPtzAction:(ENUM_PTZCMD) cmd;
//屏幕切换的
@property (retain, nonatomic) IBOutlet UIButton *landBackBtn;
- (IBAction)landBackAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *longBtn50HZ;
@property (retain, nonatomic) IBOutlet UIButton *longBtn60HZ;

@property (retain, nonatomic) IBOutlet UIButton *talkButtonBtn;
@property (retain, nonatomic) IBOutlet UIButton *longTalkButtonBtn;
//对比度
@property (retain, nonatomic) IBOutlet UIScrollView *portraitConstrastScrollView;
@property (retain, nonatomic) IBOutlet UIView *portraitContrastView;
@property (retain, nonatomic) IBOutlet UIButton *portraitContrastTitle;
@property (retain, nonatomic) IBOutlet UIButton *portaitContrastHigest;
@property (retain, nonatomic) IBOutlet UIButton *portaitContrastHigt;
@property (retain, nonatomic) IBOutlet UIButton *portaitContrastMiddle;
@property (retain, nonatomic) IBOutlet UIButton *portaitContrastLow;
@property (retain, nonatomic) IBOutlet UIButton *portaitContrastLowest;

@property (retain, nonatomic) IBOutlet UIView *landConstrastView;
@property (retain, nonatomic) IBOutlet UIButton *landConstrastTitle;
@property (retain, nonatomic) IBOutlet UIButton *landContrastHighest;
@property (retain, nonatomic) IBOutlet UIButton *landContrastHigh;
@property (retain, nonatomic) IBOutlet UIButton *landContrastMiddle;
@property (retain, nonatomic) IBOutlet UIButton *landContrastLow;
@property (retain, nonatomic) IBOutlet UIButton *landContrastLowest;



/**
 * 设置对比度
 */
- (IBAction)onContrastClicked:(id)sender;
//亮度
@property (retain, nonatomic) IBOutlet UIScrollView *portraitBrightScrollView;
@property (retain, nonatomic) IBOutlet UIView *portraitBrightView;
@property (retain, nonatomic) IBOutlet UIButton *portraitBrightTitle;
@property (retain, nonatomic) IBOutlet UIButton *portraitBrightHigh;
@property (retain, nonatomic) IBOutlet UIButton *portraitBrightHighLow;
@property (retain, nonatomic) IBOutlet UIButton *portraitBrightMiddle;
@property (retain, nonatomic) IBOutlet UIButton *portraitBrightLow;
@property (retain, nonatomic) IBOutlet UIButton *portraitBrightLowest;

@property (retain, nonatomic) IBOutlet UIView *landBrightView;
@property (retain, nonatomic) IBOutlet UIButton *landBrightTitle;
@property (retain, nonatomic) IBOutlet UIButton *landBrightHighest;
@property (retain, nonatomic) IBOutlet UIButton *landBrightHigh;
@property (retain, nonatomic) IBOutlet UIButton *landBrightMiddle;
@property (retain, nonatomic) IBOutlet UIButton *landBrightLow;
@property (retain, nonatomic) IBOutlet UIButton *landBrightLowest;

- (IBAction)onBrightClicked:(id)sender;


@property (retain, nonatomic) IBOutlet UIView *prePositionView;
@property (retain, nonatomic) IBOutlet UILabel *prePositionTitleLbl;
@property (retain, nonatomic) IBOutlet UILabel *prePositionTipsLbl;
@property (retain, nonatomic) IBOutlet UIButton *preBtn1;
@property (retain, nonatomic) IBOutlet UIButton *preBtn2;
@property (retain, nonatomic) IBOutlet UIButton *preBtn3;
@property (retain, nonatomic) IBOutlet UIButton *preBtn4;
- (IBAction)preAction:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *preNumView;
@property (retain, nonatomic) IBOutlet UIView *test;

//红外开关
@property (retain, nonatomic) IBOutlet UIView *longInfraredView;
@property (retain, nonatomic) IBOutlet UIButton *longInfraredTitle;

@property (retain, nonatomic) IBOutlet UIButton *longInfraredOpen;
@property (retain, nonatomic) IBOutlet UIButton *longInfraredClose;
@property (retain, nonatomic) IBOutlet UIButton *longInfraredAuto;

- (IBAction)onlongInfraredClicked:(id)sender;

//企鹅版操作
@property (retain, nonatomic) IBOutlet UIView *qieActionView;
@property (retain, nonatomic) IBOutlet UIView *qieLandActionView;
@property (retain, nonatomic) IBOutlet UIButton *qieSnapshotBtn;
@property (retain, nonatomic) IBOutlet UIButton *qieLandSnapshotBtn;
- (IBAction)qieSnapshot:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *qieMonitorBtn;
@property (retain, nonatomic) IBOutlet UIButton *qieLandMonitorBtn;
- (IBAction)qiemonito:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *qieWenduBtn;
@property (retain, nonatomic) IBOutlet UIButton *qieLandWenduBtn;
- (IBAction)qieWendu:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *qieVideoBtn;
@property (retain, nonatomic) IBOutlet UIButton *qieLandVideoBtn;
- (IBAction)qieVideo:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *qieHuaZhiBtn;
@property (retain, nonatomic) IBOutlet UIButton *qieLandHuaZhiBtn;
- (IBAction)qieHuaZhi:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *qiePhoneBtn;
@property (retain, nonatomic) IBOutlet UIButton *qieLandPhoneBtn;
- (IBAction)qiePhone:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *qieWenDuLbl;


@end

@protocol CameraLiveViewDelegate <NSObject>

- (void)didReStartCamera:(MyCamera *)camera cameraChannel:(NSNumber *)channel withView:(NSNumber *)tag;
- (void) didRemoveDevice:(MyCamera *)removedCamera;

@end

