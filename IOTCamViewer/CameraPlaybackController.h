//
//  CameraPlaybackController.h
//  IOTCamViewer
//
//  Created by tutk on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define ZOOM_MAX_SCALE 5.0
#define ZOOM_MIN_SCALE 1.0
#define degreeToRadians(x) (M_PI * (x) / 180.0)

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import "MyCamera.h"
#import "FMDatabase.h"
#import "Event.h"
#import "CameraShowGLView.h"

extern FMDatabase *database;
extern NSString *deviceTokenString;

@interface CameraPlaybackController : UIViewController <MyCameraDelegate, MonitorTouchDelegate> {
    
	unsigned short mCodecId;
	CameraShowGLView *glView;
	
    UIView *portraitView;
    UIView *landscapeView;
    Monitor *monitorPortrait;
    Monitor *monitoirLandscape;
    UIScrollView *scrollViewPortrait;
    UIScrollView *scrollViewLandscape;
    UIBarButtonItem *playButton;
    UIBarButtonItem *pauseButton;
    UIToolbar *toolBar;
    UILabel *statusLabel;
    UILabel *videoInfoLabel;
    UILabel *frameInfoLabel;

    MyCamera *camera;
    Event *event;
    
    NSInteger playbackChannelIndex;
    bool isPaused;
    bool isOpened;
    
    NSTimer *tmrRecvPlayback;
	BOOL bStopShowCompletedLock;
    
    BOOL isBack;
}

@property (nonatomic, assign) BOOL bStopShowCompletedLock;
@property (nonatomic, assign) unsigned short mCodecId;
@property (nonatomic, assign) CameraShowGLView *glView;
@property CVPixelBufferPoolRef mPixelBufferPool;
@property CVPixelBufferRef mPixelBuffer;
@property (nonatomic, assign) CGSize mSizePixelBuffer;
@property (nonatomic, retain) IBOutlet UIView *portraitView;
@property (nonatomic, retain) IBOutlet UIView *landscapeView;
@property (nonatomic, retain) IBOutlet Monitor *monitorPortrait;
@property (nonatomic, retain) IBOutlet Monitor *monitorLandscape;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewPortrait;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewLandscape;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *pauseButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *videoInfoLabel;
@property (nonatomic, retain) IBOutlet UILabel *frameInfoLabel;

@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) Event *event;

- (IBAction)back:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;

@end
