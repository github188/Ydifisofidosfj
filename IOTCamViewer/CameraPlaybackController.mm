//
//  CameraPlaybackController.m
//  IOTCamViewer
//
//  Created by tutk on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/GLog.h>
#import <IOTCamera/GLogZone.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "CameraPlaybackController.h"
#import <IOTCamera/AVFRAMEINFO.h>
#import <IOTCamera/ImageBuffInfo.h>
#import "iToast.h"
#import "AppDelegate.h"

#define DEF_WAIT4STOPSHOW_TIME	250
extern unsigned int _getTickCount();

@implementation CameraPlaybackController

@synthesize bStopShowCompletedLock;
@synthesize mCodecId;
@synthesize glView;
@synthesize mPixelBufferPool;
@synthesize mPixelBuffer;
@synthesize mSizePixelBuffer;
@synthesize camera;
@synthesize event;
@synthesize portraitView, landscapeView;
@synthesize monitorPortrait, monitorLandscape;
@synthesize scrollViewPortrait, scrollViewLandscape;
@synthesize playButton, pauseButton;
@synthesize toolBar;
@synthesize statusLabel, videoInfoLabel, frameInfoLabel; 

- (void)verifyConnectionStatus
{
    if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
        self.statusLabel.text = NSLocalizedString(@"Connecting...", @"");
        NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
        self.statusLabel.text = NSLocalizedString(@"Off line", @"");
        NSLog(@"%@ off line", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
        self.statusLabel.text = NSLocalizedString(@"Unknown Device", @"");
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        self.statusLabel.text = NSLocalizedString(@"Timeout", @"");
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
        self.statusLabel.text = NSLocalizedString(@"Unsupported", @"");
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
        self.statusLabel.text = NSLocalizedString(@"Connect Failed", @"");
        NSLog(@"%@ connected failed", camera.uid);
    }
    
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
        
#ifndef SHOW_SESSION_MODE
        self.statusLabel.text = NSLocalizedString(@"Online", @"");
#else
        if (camera.sessionMode == CONNECTION_MODE_P2P) {
            self.connModeImageView.image = [UIImage imageNamed:@"ConnectMode_P2P"];
            self.statusLabel.text = [NSString stringWithFormat:@"%@ / P2P", NSLocalizedString(@"Online", @"")];
        }
        else if (camera.sessionMode == CONNECTION_MODE_RELAY) {
            self.connModeImageView.image = [UIImage imageNamed:@"ConnectMode_RLY"];
            self.statusLabel.text = [NSString stringWithFormat:@"%@ / Relay", NSLocalizedString(@"Online", @"")];
        }
        else if (camera.sessionMode == CONNECTION_MODE_LAN) {
            self.connModeImageView.image = [UIImage imageNamed:@"ConnectMode_LAN"];
            self.statusLabel.text = [NSString stringWithFormat:@"%@ / %@", NSLocalizedString(@"Online", @""), NSLocalizedString(@"LAN", @"")];
        }
        else {
            self.statusLabel.text = NSLocalizedString(@"Online", @"");
        }
#endif
        
        NSLog(@"%@ online", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
        self.statusLabel.text = NSLocalizedString(@"Connecting...", @"");
        NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED) {
        self.statusLabel.text = NSLocalizedString(@"Off line", @"");
        NSLog(@"%@ off line", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
        self.statusLabel.text = NSLocalizedString(@"Unknown Device", @"");
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
        self.statusLabel.text = NSLocalizedString(@"Wrong Password", @"");
        NSLog(@"%@ wrong password", camera.uid);
        
        //Un-mapping
        [self unRegMapping:camera.uid];
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
        self.statusLabel.text = NSLocalizedString(@"Timeout", @"");
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
        self.statusLabel.text = NSLocalizedString(@"Unsupported", @"");
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
        self.statusLabel.text = NSLocalizedString(@"Connecting...", @"");
        NSLog(@"%@ wait for connecting", camera.uid);
    }
}

- (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height {
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buff, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    
    
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    
    
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }   
    
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    } 
    
    return [[img copy] autorelease];
}

- (void)showPlayButton {
    
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolBar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:playButton];
    toolBar.items = toolbarItems;
}

- (void)showPauseButton {
    
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolBar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:pauseButton];
    toolBar.items = toolbarItems;    
}

- (void)showPlaybackNotFoundMsg {
    
    if (playbackChannelIndex < 0) {
        
        isOpened = false;
        [self showPlayButton];
        
        [[[iToast makeText:NSLocalizedString(@"Can not play remote record", @"")] setDuration:iToastDurationNormal] show];
    }
    
    tmrRecvPlayback = nil;
}

- (IBAction)back:(id)sender {
	
	if(isBack) {
		GLog( tUI, (@"================") );
		GLog( tUI, (@" Ignore back !!") );
		GLog( tUI, (@"================") );
		return;
	}
    isBack = YES;
	
    [monitorLandscape deattachCamera];
    [monitorPortrait deattachCamera];
    
    if (playbackChannelIndex >= 0) {
        
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_STOP;
        req->stTimeDay = [Event getTimeDay:event.eventTime];
        req->Param = 0;
        
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        
        free(req);
		

    }

	[camera clearRemoteNotifications];
	if (tmrRecvPlayback != nil) {
		[tmrRecvPlayback invalidate];
		tmrRecvPlayback = nil;
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		// We have to force stopshow here, due to the IO command may not response immediately
		//
		[camera stopSoundToPhone:playbackChannelIndex];
		[camera stopShow:playbackChannelIndex];
		[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
		[camera stop:playbackChannelIndex];

		[self.navigationController popViewControllerAnimated:YES];
	});
	
}

- (IBAction)play:(id)sender {
    
    if (playbackChannelIndex < 0) {
        
        isOpened = true;
        
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_START;
        req->stTimeDay = [Event getTimeDay:event.eventTime];
        req->Param = 0;
        
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        
        free(req);
        
        [self showPauseButton];
        
        if (tmrRecvPlayback != nil) {
            
            [tmrRecvPlayback invalidate];
            tmrRecvPlayback = nil;
        }
        
        tmrRecvPlayback = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showPlaybackNotFoundMsg) userInfo:nil repeats:nil];

    }
    else {        
        [self pause:nil];
    }
}

- (IBAction)pause:(id)sender {

    if (playbackChannelIndex >= 0) {
        
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_PAUSE;
        req->stTimeDay = [Event getTimeDay:event.eventTime];
        req->Param = 0;
        
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        
        free(req);
    }
    
    
    isPaused = !isPaused;
    
    if (isPaused) 
        [self showPlayButton];                
    else 
        [self showPauseButton];
}

- (void)removeGLView :(BOOL)toPortrait
{
	if( glView ) {
		BOOL bRemoved = FALSE;
		if(toPortrait) {
			for (UIView *subView in self.scrollViewLandscape.subviews) {
				
				if ([subView isKindOfClass:[CameraShowGLView class]]) {
					
					[subView removeFromSuperview];
					NSLog( @"glView has been removed from scrollViewLandscape <OK>" );
					bRemoved = TRUE;
					break;
				}
			}
			if( !bRemoved ) {
				for (UIView *subView in self.scrollViewPortrait.subviews) {
					
					if ([subView isKindOfClass:[CameraShowGLView class]]) {
						
						[subView removeFromSuperview];
						NSLog( @"glView has been removed from scrollViewPortrait <OK>" );
						//bRemoved = TRUE;  //vic seem no need???
						break;
					}
				}
			}
		}
		else {
			for (UIView *subView in self.scrollViewPortrait.subviews) {
				
				if ([subView isKindOfClass:[CameraShowGLView class]]) {
					
					[subView removeFromSuperview];
					NSLog( @"glView has been removed from scrollViewPortrait <OK>" );
					bRemoved = TRUE;
					break;
				}
			}
			if( !bRemoved ) {
				for (UIView *subView in self.scrollViewLandscape.subviews) {
					
					if ([subView isKindOfClass:[CameraShowGLView class]]) {
						
						[subView removeFromSuperview];
						NSLog( @"glView has been removed from scrollViewLandscape <OK>" );
						//bRemoved = TRUE;      //vic seem no need???
						break;
					}
				}
			}
		}
	}
}

- (void)changeOrientation:(UIInterfaceOrientation)orientation {
      
    NSLog(@"change orientation");

    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        
        [monitorPortrait deattachCamera];
        [monitorLandscape attachCamera:camera];
        
		[self removeGLView:FALSE];
        self.view = self.landscapeView;
		NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorLandscape.frame.origin.x, (int)self.monitorLandscape.frame.origin.y, (int)self.monitorLandscape.frame.size.width, (int)self.monitorLandscape.frame.size.height);
		if( glView == nil ) {
			glView = [[CameraShowGLView alloc] initWithFrame:self.monitorLandscape.frame];
			[glView setMinimumGestureLength:100 MaximumVariance:50];
			glView.delegate = self;
			[glView attachCamera:camera];
		}
		else {
			[self.glView destroyFramebuffer];
			self.glView.frame = self.monitorLandscape.frame;
		}
		[self.scrollViewLandscape addSubview:glView];
		self.scrollViewLandscape.zoomScale = 1.0;
		
		if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
			[self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
		}
		else {
			[self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
		}
		
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    else {
        
        [monitorLandscape deattachCamera];
        [monitorPortrait attachCamera:camera];
        
		[self removeGLView:TRUE];
        self.view = self.portraitView;
        
        self.scrollViewPortrait.frame=CGRectMake(0, self.view.frame.size.height-self.toolBar.frame.size.height-self.view.frame.size.width/4*3, self.view.frame.size.width, self.view.frame.size.width/4*3);
        self.scrollViewPortrait.contentSize=self.scrollViewPortrait.frame.size;
        self.monitorPortrait.frame=CGRectMake(0, 0, self.scrollViewPortrait.frame.size.width, self.scrollViewPortrait.frame.size.height);
        
		NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorPortrait.frame.origin.x, (int)self.monitorPortrait.frame.origin.y, (int)self.monitorPortrait.frame.size.width, (int)self.monitorPortrait.frame.size.height);
		if( glView == nil ) {
			glView = [[CameraShowGLView alloc] initWithFrame:self.monitorPortrait.frame];
			[glView setMinimumGestureLength:100 MaximumVariance:50];
			glView.delegate = self;
			[glView attachCamera:camera];
		}
		else {
			[self.glView destroyFramebuffer];
			self.glView.frame = self.monitorPortrait.frame;
		}
		[self.scrollViewPortrait addSubview:glView];
		self.scrollViewPortrait.zoomScale = 1.0;
		
		if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
			[self.scrollViewPortrait bringSubviewToFront:monitorPortrait/*self.glView*/];
		}
		else {
			[self.scrollViewPortrait bringSubviewToFront:/*monitorPortrait*/self.glView];
		}
		
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self changeOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)unRegMapping:(NSString *)uid {
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // unregister from apns server
    dispatch_queue_t queue = dispatch_queue_create("apns-unreg_client", NULL);
    dispatch_async(queue, ^{
        if (true) {
            NSError *error = nil;
            NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];

			NSString *argsString = @"%@?cmd=unreg_mapping&uid=%@&appid=%@&udid=%@&os=ios";
            NSString *getURLString = [NSString stringWithFormat:argsString, g_tpnsHostString, uid, appidString, uuid];
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
#endif
            NSString *unregisterResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
            
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @">>> %@", unregisterResult );
            NSLog( @"==============================================");
#endif
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

#pragma mark - View lifecycle

- (void)viewDidLoad {    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];
    
    toolBar.items = [NSArray arrayWithObjects:playButton, nil];        
    playbackChannelIndex = -1;
    
    NSTimeZone *time=[NSTimeZone localTimeZone];
    NSInteger timeZoneNum=time.secondsFromGMT/3600;
    NSInteger diffSecons=(_timeZoneNumber-timeZoneNum)*3600;
    
#ifndef MacGulp
    self.navigationItem.title = NSLocalizedString(@"Playback", nil);
    //self.navigationItem.prompt = camera.name;
#else    
    NSString *evtTime;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.event.eventTime+diffSecons];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];    
    evtTime = [dateFormatter stringFromDate:date];    
    [dateFormatter release];
    [date release];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@", evtTime];
#endif
    
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
    
    [self.monitorPortrait setMinimumGestureLength:100 MaximumVariance:50];
    [self.monitorPortrait setUserInteractionEnabled:YES];
    self.monitorPortrait.contentMode = UIViewContentModeScaleToFill;
    self.monitorPortrait.backgroundColor = [UIColor blackColor];
    self.monitorPortrait.delegate = self;
    
    [self.monitorLandscape setMinimumGestureLength:100 MaximumVariance:50];
    [self.monitorLandscape setUserInteractionEnabled:YES];
    self.monitorLandscape.contentMode = UIViewContentModeScaleToFill;
    self.monitorLandscape.backgroundColor = [UIColor blackColor];
    self.monitorLandscape.delegate = self;
    
    self.scrollViewPortrait.minimumZoomScale = ZOOM_MIN_SCALE;
    self.scrollViewPortrait.maximumZoomScale = ZOOM_MAX_SCALE;
    self.scrollViewPortrait.contentMode = UIViewContentModeScaleToFill;
    self.scrollViewPortrait.contentSize = self.scrollViewPortrait.frame.size;
    
    self.scrollViewLandscape.minimumZoomScale = ZOOM_MIN_SCALE;
    self.scrollViewLandscape.maximumZoomScale = ZOOM_MAX_SCALE;
    self.scrollViewLandscape.contentMode = UIViewContentModeScaleToFill;
    self.scrollViewLandscape.contentSize = self.scrollViewLandscape.frame.size;
    
#if defined(SVIPCLOUD)
    statusLabel.textColor=HexRGB(0x3d3c3c);
    videoInfoLabel.textColor=HexRGB(0x3d3c3c);
    frameInfoLabel.textColor=HexRGB(0x3d3c3c);
#endif
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
	
	isBack = NO;
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
	
    self.camera = nil;
    self.playButton = nil;
    self.pauseButton = nil;
    self.toolBar = nil;
    self.statusLabel = nil;
    self.videoInfoLabel = nil;
    self.frameInfoLabel = nil;
    self.portraitView = nil;
    self.landscapeView = nil;
    self.monitorPortrait = nil;
    self.monitorLandscape = nil;
    self.scrollViewPortrait = nil;
    self.scrollViewLandscape = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationDidBecomeActiveNotification];
    
	if(glView) {
    	[self.glView tearDownGL];
		//[self.glView release];
        self.glView = nil;
	}
	CVPixelBufferRelease(mPixelBuffer);
	CVPixelBufferPoolRelease(mPixelBufferPool);
    [super viewDidUnload];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (camera != nil)
        camera.delegate2 = self;
    
    [self play:nil];
    
    NSString *evtName;
    NSString *evtTime;
    
    evtName = [Event getEventTypeName:self.event.eventType];
    
    NSTimeZone *time=[NSTimeZone localTimeZone];
    NSInteger timeZoneNum=time.secondsFromGMT/3600;
    NSInteger diffSecons=(self.timeZoneNumber-timeZoneNum)*3600;
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.event.eventTime+diffSecons];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];    
    evtTime = [dateFormatter stringFromDate:date];    
    [dateFormatter release];
    [date release];
    
    self.statusLabel.text = [NSString stringWithFormat:@"%@ (%@) ", evtName, evtTime];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{    
    [super viewWillDisappear:animated];

	if (tmrRecvPlayback != nil) {
		[tmrRecvPlayback invalidate];
		tmrRecvPlayback = nil;
	}
}

- (void)dealloc
{
    [camera release];
    [playButton release];
    [pauseButton release];
    [toolBar release];
    [statusLabel release];
    [videoInfoLabel release];
    [frameInfoLabel release];
    [portraitView release];
    [landscapeView release];
    [monitorPortrait release];
    [monitorLandscape release];
    [scrollViewPortrait release];
    [scrollViewLandscape release];
    
    [super dealloc];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size
{ 
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL_RESP) {
        
        SMsgAVIoctrlPlayRecordResp *resp = (SMsgAVIoctrlPlayRecordResp *) data;
        
        switch (resp->command) {
            
            case AVIOCTRL_RECORD_PLAY_START:
            {
                if (isOpened) {
                    
                    if (resp->result > 0 && resp->result <= 32) {

                        playbackChannelIndex = resp->result;
                                                            
                        [camera start4EventPlayback:playbackChannelIndex];
                        [camera startShow:playbackChannelIndex ScreenObject:self];
                        [camera startSoundToPhone:playbackChannelIndex];    
                        
                        isPaused = false;                     
                    }             
                }
                
                break;
            }
            case AVIOCTRL_RECORD_PLAY_PAUSE:
            {
                /*
                isPaused = !isPaused;

                if (isPaused) 
                    [self showPlayButton];                
                else 
                    [self showPauseButton];
                */
                
                break;
            }
            case AVIOCTRL_RECORD_PLAY_STOP:
            {
//                if (!isBack) {
				GLog( tUI, (@"=========================================== ") );
				GLog( tUI, (@"======== AVIOCTRL_RECORD_PLAY_STOP ======== ") );
				
                    [camera stopSoundToPhone:playbackChannelIndex];
                    [camera stopShow:playbackChannelIndex];
                    [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                    [camera stop:playbackChannelIndex];
                    
                    isPaused = false;
                    
                    [self showPlayButton];
                    
                    playbackChannelIndex = -1;
				
                    break;
//                }
            }
                
            case AVIOCTRL_RECORD_PLAY_END:
            {
                [camera stopSoundToPhone:playbackChannelIndex];
                [camera stopShow:playbackChannelIndex];
				[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [camera stop:playbackChannelIndex];
                
                SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
                memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
                
                req->channel = 0;
                req->command = AVIOCTRL_RECORD_PLAY_STOP;
                req->stTimeDay = [Event getTimeDay:event.eventTime];
                req->Param = 0;
                
                [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
                
                free(req);

                isPaused = false;
                isOpened = false;
                playbackChannelIndex = -1;

                [self showPlayButton];
                [[[iToast makeText:NSLocalizedString(@"The video has finished playing", @"")] setDuration:iToastDurationNormal] show];
                
                
                if (tmrRecvPlayback != nil) {
                    
                    [tmrRecvPlayback invalidate];
                    tmrRecvPlayback = nil;
                }
                
                break;
            }
            default:
                break;                
        }
    }
}

- (void)camera:(MyCamera *)camera_ _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned int)frameCount IncompleteFrameCount:(unsigned int)incompleteFrameCount {
    
    if (camera_ == camera) {
		if( videoWidth > 1920 || videoHeight > 1080 ) {
			NSLog( @"!!!!!!!! ERROR !!!!!!!!" );
			return;
		}
		
		CGSize maxZoom = CGSizeMake((videoWidth*2.0 > 1920)?1920:videoWidth*2.0, (videoHeight*2.0 > 1080)?1080:videoHeight*2.0);
		if( glView && videoWidth > 0 && videoHeight > 0 ) {
			[self recalcMonitorRect:CGSizeMake(videoWidth, videoHeight)];
			self.glView.maxZoom = maxZoom;			
		}
		if( maxZoom.width / self.scrollViewPortrait.frame.size.width > 1.0 ) {
			self.scrollViewPortrait.maximumZoomScale = maxZoom.width / self.scrollViewPortrait.frame.size.width;
		}
		else {
			self.scrollViewPortrait.maximumZoomScale = 1;
		}
		if( maxZoom.width / self.scrollViewLandscape.frame.size.width > 1.0 ) {
			self.scrollViewLandscape.maximumZoomScale = maxZoom.width / self.scrollViewLandscape.frame.size.width;
		}
		else {
			self.scrollViewLandscape.maximumZoomScale = 1;
		}
		
		if( g_bDiagnostic ) {
			self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d / FPS: %d / BPS: %d Kbps", (int)videoWidth, (int)videoHeight, (int)fps, (int)(videoBps + audioBps) / 1024];
			self.frameInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %d / Frame ratio: %d / %d", @"Used for display channel information"), onlineNm, incompleteFrameCount, frameCount];
		}
		else {
			self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d", (int)videoWidth, (int)videoHeight ];
			self.frameInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %d", @""), onlineNm];
		}
    }
}

#pragma mark - MonitorTouchDelegate Methods
- (void)monitor:(Monitor *)monitor gestureSwiped:(Direction)direction {
	NSLog( @"Ignore PTZ in Playback mode." );
}

- (void)gestureSwiped:(Direction)direction {
    
}

- (void)gesturePinched:(CGFloat)scale {    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		
		NSLog( @"CameraPlaybackController - Pinched [Landscape] scale:%f/%f", scale, self.scrollViewLandscape.maximumZoomScale );
		if( scale <= self.scrollViewLandscape.maximumZoomScale )
        	[self.scrollViewLandscape setZoomScale:scale animated:YES];
    }
    else {
		NSLog( @"CameraPlaybackController - Pinched scale:%f/%f", scale, self.scrollViewPortrait.maximumZoomScale );
		if( scale <= self.scrollViewPortrait.maximumZoomScale )
			[self.scrollViewPortrait setZoomScale:scale animated:YES];
    }
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        return self.monitorPortrait;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
             self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return self.monitorLandscape;
    }
    else return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView 
                       withView:(UIView *)view 
                        atScale:(CGFloat)scale {
	if( glView ) {
		glView.frame = CGRectMake( 0, 0, scrollView.frame.size.width*scale, scrollView.frame.size.height*scale );
		GLog( tPinchZoom|tUI, ( @"scrollViewDidEndZooming {0,0,%d,%d}", (int)(scrollView.frame.size.width*scale), (int)(scrollView.frame.size.height*scale) ));
	}
}

#pragma mark - UIApplication Delegate
- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (playbackChannelIndex >= 0) {
        
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_PAUSE;
        req->stTimeDay = [Event getTimeDay:event.eventTime];
        req->Param = 0;
        
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        
        free(req);
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (playbackChannelIndex >= 0) {
        
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_PAUSE;
        req->stTimeDay = [Event getTimeDay:event.eventTime];
        req->Param = 0;
        
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        
        free(req);
    }
}

- (void)updateToScreen:(NSValue*)pointer
{
    LPSIMAGEBUFFINFO pScreenBmpStore = (LPSIMAGEBUFFINFO)[pointer pointerValue];
    [glView renderVideo:pScreenBmpStore->pixelBuff];
}

- (void)recalcMonitorRect:(CGSize)videoframe
{
	CGFloat fRatioFrame = videoframe.width / videoframe.height;
	CGFloat fRatioMonitor;
	UIScrollView* viewMonitor;
	UIView* viewCanvas;
	
    if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		viewMonitor = self.scrollViewLandscape;
		viewCanvas = self.monitorLandscape;
	}
	else {
		viewMonitor = self.scrollViewPortrait;
		viewCanvas = self.monitorPortrait;
	}
	fRatioMonitor = viewMonitor.frame.size.width/viewMonitor.frame.size.height;
	
	if( fRatioMonitor < fRatioFrame ) {
		CGFloat canvas_height = (viewMonitor.frame.size.width * viewMonitor.zoomScale) / fRatioFrame;
		
		if( canvas_height < viewMonitor.frame.size.height ) {
			viewCanvas.frame = CGRectMake(0, ((viewMonitor.frame.size.height) - canvas_height)/2.0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
		}
		else {
			viewCanvas.frame = CGRectMake(0, 0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
		}
	}
	else {
		CGFloat canvas_width = (viewMonitor.frame.size.height * viewMonitor.zoomScale) * fRatioFrame;
		
		if( canvas_width < viewMonitor.frame.size.width ) {
			viewCanvas.frame = CGRectMake(((viewMonitor.frame.size.width) - canvas_width)/2.0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
		}
		else {
			viewCanvas.frame = CGRectMake(0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
		}
	}
	
	if( self.glView ) {
		GLog( tUI|tPinchZoom, (@"glView.frame ==> %dx%d", (int)viewCanvas.frame.size.width, (int)viewCanvas.frame.size.height ) );
		self.glView.frame = viewCanvas.frame;
	}
}

// If you want to set the final frame size, just implement this delegation to given the wish frame size
//
- (void)glFrameSize:(NSArray*)param
{
	CGSize* pglFrameSize_Original = (CGSize*)[(NSValue*)[param objectAtIndex:0] pointerValue];
	CGSize* pglFrameSize_Scaling = (CGSize*)[(NSValue*)[param objectAtIndex:1] pointerValue];
	
	[self recalcMonitorRect:*pglFrameSize_Original];
	self.glView.maxZoom = CGSizeMake( (pglFrameSize_Original->width*2.0 > 1920)?1920:pglFrameSize_Original->width*2.0, (pglFrameSize_Original->height*2.0 > 1080)?1080:pglFrameSize_Original->height*2.0 );
	
	CGSize sizeRetina = CGSizeMake( self.glView.frame.size.width, self.glView.frame.size.height );
	CGFloat fScale  = [[UIScreen mainScreen] scale];
	sizeRetina.height *= fScale;
	sizeRetina.width *= fScale;
	*pglFrameSize_Scaling = sizeRetina ;
}

- (void)reportCodecId:(NSValue*)pointer
{
	unsigned short *pnCodecId = (unsigned short *)[pointer pointerValue];
	
	mCodecId = *pnCodecId;
	
	if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
			[self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
        }
        else {
			[self.scrollViewPortrait bringSubviewToFront:monitorLandscape/*self.glView*/];
        }
	}
	else {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
			[self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
        }
        else {
			[self.scrollViewPortrait bringSubviewToFront:/*monitorLandscape*/self.glView];
        }		
	}
}

- (void)waitStopShowCompleted:(unsigned int)uTimeOutInMs
{
	unsigned int uStart = _getTickCount();
	while( self.bStopShowCompletedLock == FALSE ) {
		usleep(1000);
		unsigned int now = _getTickCount();
		if( now - uStart >= uTimeOutInMs ) {
			NSLog( @"CameraPlaybackController - waitStopShowCompleted !!!TIMEOUT!!!" );
			break;
		}
	}
	
}

- (void)cameraStopShowCompleted:(NSNotification *)notification
{
	bStopShowCompletedLock = TRUE;
}

@end
