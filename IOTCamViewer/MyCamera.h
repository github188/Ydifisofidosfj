//
//  MyCamera.h
//  IOTCamViewer
//
//  Created by Cloud Hsiao on 12/7/2.
//  Copyright (c) 2012年 TUTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOTCamera/Camera.h>

@protocol MyCameraDelegate;

@interface MyCamera : Camera <CameraDelegate>
{
    id<MyCameraDelegate> delegate2;
    NSInteger lastChannel;
    NSInteger remoteNotifications;
    NSMutableArray *arrayStreamChannel;
    NSString *viewAcc;
    NSString *viewPwd;
	
	BOOL bIsSupportTimeZone;
	int nGMTDiff;
	NSString* strTimeZone;
    
    BOOL bIsSyncOnCloud;
    BOOL bisAddFromCloud;
}

@property (nonatomic, assign) id<MyCameraDelegate> delegate2;
@property NSInteger lastChannel;
@property (readonly) NSInteger remoteNotifications;
@property (nonatomic, copy) NSString *viewAcc;
@property (nonatomic, copy) NSString *viewPwd;
@property (nonatomic, assign) BOOL bIsSupportTimeZone;
@property (nonatomic, assign) BOOL bIsSyncOnCloud;
@property (nonatomic, assign) BOOL bisAddFromCloud;
@property (nonatomic, assign) int nGMTDiff;
@property (nonatomic, copy) NSString* strTimeZone;
// for dropbox feature
@property (assign) BOOL isSupportDropbox;
@property (assign) BOOL isLinkDropbox;

- (id)initWithName:(NSString *)name viewAccount:(NSString *)viewAcc viewPassword:(NSString *)viewPwd;
- (void)start:(NSInteger)channel;
- (void)start4EventPlayback:(NSInteger)channel;
- (void)setRemoteNotification:(NSInteger)type EventTime:(long)time;
- (void)clearRemoteNotifications;
- (NSArray *)getSupportedStreams;
- (BOOL)getAudioInSupportOfChannel:(NSInteger)channel;
- (BOOL)getAudioOutSupportOfChannel:(NSInteger)channel;
- (BOOL)getPanTiltSupportOfChannel:(NSInteger)channel;
- (BOOL)getEventListSupportOfChannel:(NSInteger)channel;
- (BOOL)getPlaybackSupportOfChannel:(NSInteger)channel;
- (BOOL)getWiFiSettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getMotionDetectionSettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getRecordSettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getFormatSDCardSupportOfChannel:(NSInteger)channel;
- (BOOL)getVideoFlipSupportOfChannel:(NSInteger)channel;
- (BOOL)getEnvironmentModeSupportOfChannel:(NSInteger)channel;
- (BOOL)getMultiStreamSupportOfChannel:(NSInteger)channel;
- (NSInteger)getAudioOutFormatOfChannel:(NSInteger)channel;
- (BOOL)getVideoQualitySettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getDeviceInfoSupportOfChannel:(NSInteger)channel;
- (NSString*)getOverAllQualityString;
- (BOOL)getTimeZoneSupportOfChannel:(NSInteger)channel;
- (void)setSync:(NSInteger)isSync;
- (void)setCloud:(NSInteger)isFromCloud;

+ (NSString*)getConnModeString:(NSInteger)connMode;
+(NSString *)cameraQVGAKey:(NSString *)uid;
+(void)setCameraQVGA:(NSInteger)v ca:(MyCamera *)camera;
+(void)loadCameraQVGA:(MyCamera *)ca;
+(NSInteger)getCameraQVGA:(MyCamera *)camera;

+(void)setcameraLoadAVGA:(NSString *)uid withIsLoad:(BOOL)isLoad;
+(BOOL)getCameraLoadQVGA:(NSString *)uid;


-(void)setCameraSummaryTime:(BOOL)yesOrNo;
-(BOOL)getCameraSummartTime;

+(NSString *)boxUUID:(MyCamera *)camera;
+(NSString *)boxUUID:(NSString *)uid widthPwd:(NSString *)viewPwd withName:(NSString *)name;
+(NSArray *)unBoxUUID:(NSString *)strs;
@end

@protocol MyCameraDelegate <NSObject>
@optional
- (void)camera:(MyCamera *)camera _didReceiveRemoteNotification:(NSInteger)eventType EventTime:(long)eventTime;
- (void)camera:(MyCamera *)camera _didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height;
- (void)camera:(MyCamera *)camera _didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size;
- (void)camera:(MyCamera *)camera _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount;
- (void)camera:(MyCamera *)camera _didChangeSessionStatus:(NSInteger)status;
- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status;
- (void)camera:(MyCamera *)camera _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size;
//- (void)setVideoRecorderDelegate:(MyCamera *)camera;
@end

extern BOOL g_bDiagnostic;
