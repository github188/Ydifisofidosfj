//
//  CameraLiveViewController.m
//  IOTCamViewer
//
//  Created by tutk on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraLiveViewController.h"
#import "PhotoTableViewController.h"
#import "iToast.h"
#import <IOTCamera/AVFRAMEINFO.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <IOTCamera/ImageBuffInfo.h>
#import <sys/time.h>
#import "UIImage+Extras.h"
#import <AVFoundation/AVFoundation.h>
#import "EditCameraDefaultController.h"

#import "UIAlertView+MKBlockAdditions.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

#ifndef P2PCAMLIVE
#define SHOW_SESSION_MODE
#endif
#define DEF_WAIT4STOPSHOW_TIME	250
extern unsigned int _getTickCount() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (unsigned int)(tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

@implementation CameraLiveViewController

@synthesize recordFileName;
@synthesize bStopShowCompletedLock;
@synthesize mCodecId;
@synthesize glView;
@synthesize mPixelBufferPool;
@synthesize mPixelBuffer;
@synthesize mSizePixelBuffer;
@synthesize portraitView, landscapeView;
@synthesize monitorPortrait, monitorLandscape;
@synthesize loadingViewPortrait, loadingViewLandscape;
@synthesize scrollViewPortrait, scrollViewLandscape;
@synthesize statusLabel, modeLabel, videoInfoLabel, frameInfoLabel;
@synthesize connModeImageView;
@synthesize multiStreamPopoverController;
@synthesize selectedChannel;
@synthesize selectedAudioMode;
@synthesize camera;
@synthesize directoryPath;
@synthesize viewTag;
@synthesize horizMenu = _horizMenu;
@synthesize longHorizMenu = _longHorizMenu;
@synthesize items = _items;
@synthesize selectItems = selectItems;
@synthesize hideToolBarTimer;
@synthesize isCanSendSetCameraCMD;
@synthesize isTalkButtonAction;


@synthesize videoGenerator;

-(AppDelegate *)getAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark Methods
- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] autorelease];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13 
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin; 
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
    
	return props;	
}

- (void)stopPT {
    
    SMsgAVIoctrlPtzCmd *request = (SMsgAVIoctrlPtzCmd *)malloc(sizeof(SMsgAVIoctrlPtzCmd));
    request->channel = 0;
    request->control = AVIOCTRL_PTZ_STOP;
    request->speed = PT_SPEED;
    request->point = 0;
    request->limit = 0;
    request->aux = 0;
    
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
    
    free(request);
}

- (void)verifyConnectionStatus
{
    
    if (isChangeChannel) {
        self.statusLabel.text = NSLocalizedString(@"Online", nil);
    }
    
    else if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Connecting...", @""), camera.connTimes, camera.connFailErrCode];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Connecting...", @"");
		}
        NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Off line", @""), camera.connTimes, camera.connFailErrCode];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Off line", @"");
		}
        NSLog(@"%@ off line", camera.uid);
		
		
    }
    else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Unknown Device", @""), camera.connTimes, camera.connFailErrCode];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Unknown Device", @"");
		}
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Timeout", @""), camera.connTimes, camera.connFailErrCode];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Timeout", @"");
		}
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Unsupported", @""), camera.connTimes, camera.connFailErrCode];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Unsupported", @"");
		}
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Connect Failed", @""), camera.connTimes, camera.connFailErrCode];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Connect Failed", @"");
		}
        NSLog(@"%@ connected failed", camera.uid);
    }
    
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
		
#ifndef SHOW_SESSION_MODE
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ [%@]%d,C:%d,D:%d,r%d", NSLocalizedString(@"Online", @""), [MyCamera getConnModeString:camera.sessionMode], camera.connTimes, camera.natC, camera.natD, camera.nAvResend];
		}
		else {
        	self.statusLabel.text = NSLocalizedString(@"Online", @"");
		}
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
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_CONNECTING)", NSLocalizedString(@"Connecting...", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Connecting...", @"");
		}
		NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_DISCONNECTED)", NSLocalizedString(@"Off line", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Off line", @"");
		}
        NSLog(@"%@ off line", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_UNKNOWN_DEVICE)", NSLocalizedString(@"Unknown Device", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Unknown Device", @"");
		}
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_WRONG_PASSWORD)", NSLocalizedString(@"Wrong Password", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Wrong Password", @"");
		}
        NSLog(@"%@ wrong password", camera.uid);
        
        //Un-mapping
        [self unRegMapping:camera.uid];
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_TIMEOUT)", NSLocalizedString(@"Timeout", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Timeout", @"");
		}
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_UNSUPPORTED)", NSLocalizedString(@"Unsupported", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Unsupported", @"");
		}
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
		if( g_bDiagnostic ) {
			self.statusLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_NONE)", NSLocalizedString(@"Connecting...", @""), camera.connTimes];
		}
		else {
			self.statusLabel.text = NSLocalizedString(@"Connecting...", @"");
		}
        NSLog(@"%@ wait for connecting", camera.uid);
    }
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)_scrollView withScale:(CGFloat)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width  = _scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
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

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[[dirs objectAtIndex:0] stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (void)saveImageToFile:(UIImage *)image :(NSString *)fileName {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *imgFullName = [self pathForDocumentsResource:fileName];
    
    NSLog(@"SNAPSHOTURL:%@",imgFullName);
    
    [imgData writeToFile:imgFullName atomically:YES];   
}

- (NSString *)directoryPath {
    
	if (!directoryPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directoryPath = [[[dirs objectAtIndex:0] stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
	return directoryPath;
}

#pragma mark Functions of buttons
- (IBAction)talkOn:(id)sender {
    
    if(!self.isTalkButtonAction)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
        s->channel = 0;
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
        free(s);
        
        SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
        free(s2);
        
        SMsgAVIoctrlTimeZone s3={0};
        s3.cbSize = sizeof(s3);
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
        self.isTalkButtonAction=YES;
    }
    
    isTalking = YES;
    selectedAudioMode = AUDIO_MODE_MICROPHONE;
    [camera stopSoundToPhone:selectedChannel];
    [self unactiveAudioSession];
    [self activeAudioSession];
    [camera startSoundToDevice:selectedChannel];
}

- (IBAction)talkOff:(id)sender {
    if (isTalking){
        [camera stopSoundToDevice:selectedChannel];
        isTalking = NO;
        
        selectedAudioMode = AUDIO_MODE_SPEAKER;
        [self unactiveAudioSession];
        [self activeAudioSession];
        [camera startSoundToPhone:selectedChannel];
    }
}

- (IBAction)snapshot:(id)sender
{
    unsigned int codec_id = mCodecId;
    
    NSString *imgName;
    if (isRecording) {
        imgName =[recordFileName stringByReplacingOccurrencesOfString:@"mp4" withString:@"jpg"];

        recordFileName = nil;
        [recordFileName release];
    } else {
        imgName = [NSString stringWithFormat:@"CH%d_%f.jpg", selectedChannel, [[NSDate date] timeIntervalSince1970]];
    }
    //[[iToast makeText:NSLocalizedString(@"Snapshot saved", @"")]show];
    //return;
    UIImage *img = NULL;
    
    if (codec_id == MEDIA_CODEC_VIDEO_MPEG4 || codec_id == MEDIA_CODEC_VIDEO_H264) {
        int size = 0;
        unsigned int w = 0, h = 0;
        char *imageFrame = (char *) malloc(MAX_IMG_BUFFER_SIZE);
        size = [camera getChannel:selectedChannel Snapshot:imageFrame DataSize:MAX_IMG_BUFFER_SIZE ImageType:&codec_id   WithImageWidth:&w ImageHeight:&h];
        if (size > 0) {
            
            img = [self getUIImage:imageFrame Width:w Height:h];
            [self saveImageToFile:img :imgName];
            
            if (database != NULL) {
                if (![database executeUpdate:@"INSERT INTO snapshot(dev_uid, file_path, time) VALUES(?,?,?)", camera.uid, imgName, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]]) {
                    NSLog(@"Fail to add snapshot to database.");
                }
            }
        }
        
        free(imageFrame);
    } else {
        
        img = [self.monitorPortrait.image copy];
        [self saveImageToFile:img :imgName];
        [img release];
        
        if (database != NULL) {
            if (![database executeUpdate:@"INSERT INTO snapshot(dev_uid, file_path, time) VALUES(?,?,?)", camera.uid, imgName, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]]) {
                NSLog(@"Fail to add snapshot to database.");
            }
        }
    }
    
    if (!isRecording) {
        [[iToast makeText:NSLocalizedString(@"Snapshot saved", @"")]show];
    }
}

- (IBAction)selectAudio:(id)sender {
    
    if ([camera getAudioInSupportOfChannel:selectedChannel] && [camera getAudioOutSupportOfChannel:selectedChannel]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:NSLocalizedString(@"Mute", @""),
                                                                      NSLocalizedString(@"Listen", @""), 
                                                                      NSLocalizedString(@"Speak", @""), nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
    else if ([camera getAudioInSupportOfChannel:selectedChannel] && ![camera getAudioOutSupportOfChannel:selectedChannel]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                                 delegate:self 
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") 
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Mute", @""),
                                                                          NSLocalizedString(@"Listen", @""), nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
    else if (![camera getAudioInSupportOfChannel:selectedChannel] && [camera getAudioOutSupportOfChannel:selectedChannel]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                                 delegate:self 
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") 
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Mute", @"") ,
                                                                          NSLocalizedString(@"Speak", @""), nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                                 delegate:self 
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") 
                                                   destructiveButtonTitle:NSLocalizedString(@"Mute", @"") 
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

- (IBAction)selectChannel:(id)sender {
            
    if (self.multiStreamPopoverController == nil) {
        
        ChannelPickerContentController *controller = [[ChannelPickerContentController alloc] initWithStyle:UITableViewStylePlain delegate:self defaultContentSize:nil];
        controller.camera = camera;
        controller.selectedChannel = selectedChannel;
        
        self.multiStreamPopoverController = [[[WEPopoverController alloc] initWithContentViewController:controller] autorelease];
        
        [controller release];
    }
    else {
        
        ChannelPickerContentController *controller = (ChannelPickerContentController *)self.multiStreamPopoverController.contentViewController;
        controller.selectedChannel = selectedChannel;
    }
    
    [self.multiStreamPopoverController presentPopoverFromRect:CGRectMake(240, -140, 80, 120) inView:statusBar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)onBtnSetQVGA1:(NSInteger)tg{
    SMsgAVIoctrlSetStreamCtrlReq *s = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
    memset(s, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
    
    s->channel = 0;
    s->quality = tg;
    
    [MyCamera setCameraQVGA:tg ca:self.camera];
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
    
    free(s);
    
    scrollQVGAView.hidden = YES;
    longQVGAView.hidden = YES;
    isQVGAView = NO;
    
    [self.horizMenu reloadData];
    [self.longHorizMenu reloadData];
    
    [self initQVGAMode:tg];
    
    [NSThread sleepForTimeInterval:2];
}


- (IBAction)onBtnSetQVGA:(id)sender {
    
    NSInteger tag=[(UIView*)sender tag];
    [self onBtnSetQVGA1:tag];
}

- (IBAction)onBtnSetEMode:(id)sender {
    
    SMsgAVIoctrlSetEnvironmentReq *s = (SMsgAVIoctrlSetEnvironmentReq *)malloc(sizeof(SMsgAVIoctrlSetEnvironmentReq));
    memset(s, 0, sizeof(SMsgAVIoctrlSetEnvironmentReq));
    
    s->channel = 0;
    s->mode = [(UIView*)sender tag]-1;
    emode=s->mode;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_SET_ENVIRONMENT_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlSetEnvironmentReq)];
    
    free(s);
    
    scrollEModeView.hidden = YES;
    longEModeView.hidden = YES;
    isEModeView = NO;
    
    [self.horizMenu reloadData];
    [self.longHorizMenu reloadData];
    
    [self initViewEmode];
    
    [NSThread sleepForTimeInterval:2];
}
//获取设备的EMode
-(void)getEMode{
    SMsgAVIoctrlGetEnvironmentReq *s = (SMsgAVIoctrlGetEnvironmentReq *)malloc(sizeof(SMsgAVIoctrlGetEnvironmentReq));
    memset(s, 0, sizeof(SMsgAVIoctrlGetEnvironmentReq));
    
    s->channel = 0;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GET_ENVIRONMENT_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlGetEnvironmentReq)];
    
    free(s);
}

//获取设备的contrast
-(void)getContrast{
    SMsgAVIoctrlGetContrastReq *s = (SMsgAVIoctrlGetContrastReq *)malloc(sizeof(SMsgAVIoctrlGetContrastReq));
    memset(s, 0, sizeof(SMsgAVIoctrlGetContrastReq));
    
    s->channel = 0;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_HICHIP_GETCONTRAST_REQ 
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlGetContrastReq)];
    
    free(s);
}

//获取设备的亮度
-(void)getBright{
    SMsgAVIoctrlGetBrightReq *s = (SMsgAVIoctrlGetBrightReq *)malloc(sizeof(SMsgAVIoctrlGetBrightReq));
    memset(s, 0, sizeof(SMsgAVIoctrlGetBrightReq));
    
    s->channel = 0;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_HICHIP_GETBRIGHT_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlGetBrightReq)];
    
    free(s);
}
//获取设备的红外开关状态
-(void)getLEDLight{
    SMsgAVIoctrlExGetLEDReq *s = (SMsgAVIoctrlExGetLEDReq *)malloc(sizeof(SMsgAVIoctrlExGetLEDReq));
    memset(s, 0, sizeof(SMsgAVIoctrlExGetLEDReq));
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USEREX_IPCAM_GET_LED_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlExGetLEDReq)];
    
    free(s);
}

- (void)onBtnSetCamera {
    EditCameraDefaultController *controller = [[EditCameraDefaultController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.camera = camera;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)onBtnRecording {
    if( 0 < msizeOrgVideoResolution.width && msizeOrgVideoResolution.width <= 1920 &&
       0 < msizeOrgVideoResolution.height && msizeOrgVideoResolution.height <= 1080 ) {
        
        if (isRecording && self.videoGenerator != nil && self.videoGenerator.isRecording) {
            
            //[UIAlertView alertViewWithTitle: @"Error" message: @"Still recording video"];
            
            [self.videoGenerator stopRecordingWithCompletionHandler:nil];
            return;
        }
        
        uint64_t freespace = [VideoGenerator freeDiskspace];
        NSLog(@"Freespace %llu", freespace);
        if (freespace < 314572800) { // 300Mb
            
            [UIAlertView alertViewWithTitle: NSLocalizedString(@"Warning",@"") message: NSLocalizedString(@"Not enough space to save video",@"")];
            
        }
        
        else if (mCodecId != MEDIA_CODEC_VIDEO_H264) {
            
            [UIAlertView alertViewWithTitle: NSLocalizedString(@"Warning",@"") message: NSLocalizedString(@"Camera's video type is not supported recording",@"")];
            
#if defined(MAJESTICIPCAMP)
            self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",@"psd_bright",@"psd_contrast",nil];
            self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked", @"psd_bright_clicked",@"psd_contrast_clicked",nil];
#else
            self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",@"f+Btn", @"f-Btn",nil];
            self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",@"f+Btn_Click", @"f-Btn_Click",nil];
            
#endif


#if defined(BayitCam)
            self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",nil];
            self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",nil];
#endif
            
            [self.horizMenu reloadData];
            [self.longHorizMenu reloadData];
            
        }
        
        else {
            
            //camera.isRecordForAlex = YES;
            
            //會備存至CameraRoll
            recordFileName = [[NSString stringWithFormat:@"CEO_Record_CH%d_%f.mp4", (int)selectedChannel, [[NSDate date] timeIntervalSince1970]] retain];
            NSString *path= [self pathForDocumentsResource:recordFileName];
            NSURL* url = [NSURL fileURLWithPath:path];
            
            camera.isShowInLiveView = YES;
            camera.isRecording = YES;
            
            if( self.videoGenerator ) {
                [self.videoGenerator release];
            }
            
            self.videoGenerator = [[VideoGenerator alloc] initWithDestinationURL:url andCamera:camera];
            self.videoGenerator.size = msizeOrgVideoResolution;
            int nRECDuration = 180;
            NSLog(@"**[REC start <1>]***************************************");
            NSLog(@" local recording to %@", [url absoluteString]);
            NSLog(@" recordingChannel:%d",(int)selectedChannel);
            NSLog(@" duration: %d", nRECDuration);
            
            [self.videoGenerator startRecordingForChannel:selectedChannel withDuration:nRECDuration];
            
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reTryVideoREC:) userInfo:nil repeats:NO];
            
#if defined(MAJESTICIPCAMP)
            self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off_disable", @"ceo_recordstop", @"leo_snapshot_disable", @"leo_mirror_ud_disable", @"leo_mirror_rl_disable", @"leo_qvga_disable", @"leo_emode_disable",@"psd_bright",@"psd_contrast",nil];
            self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_off_disable", @"ceo_recordstop", @"leo_snapshot_disable", @"leo_mirror_ud_disable", @"leo_mirror_rl_disable", @"leo_qvga_disable", @"leo_emode_disable",@"psd_bright_clicked",@"psd_contrast_clicked",nil];
#else
            self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off_disable", @"ceo_recordstop", @"leo_snapshot_disable",@"ceo_presetting_enable_disable.png", @"leo_mirror_ud_disable", @"leo_mirror_rl_disable", @"leo_qvga_disable", @"leo_emode_disable", @"f+Btn_disable", @"f-Btn_disable",nil];
            self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_off_disable", @"ceo_recordstop", @"leo_snapshot_disable",@"ceo_presetting_enable_disable.png", @"leo_mirror_ud_disable", @"leo_mirror_rl_disable", @"leo_qvga_disable", @"leo_emode_disable",@"f+Btn_disable", @"f-Btn_disable",nil];
#endif
            
#if defined(BayitCam)
            self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off_disable", @"ceo_recordstop", @"leo_snapshot_disable",@"ceo_presetting_enable_disable.png", @"leo_mirror_ud_disable", @"leo_mirror_rl_disable", @"leo_qvga_disable", @"leo_emode_disable",nil];
            self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_off_disable", @"ceo_recordstop", @"leo_snapshot_disable",@"ceo_presetting_enable_disable.png", @"leo_mirror_ud_disable", @"leo_mirror_rl_disable", @"leo_qvga_disable", @"leo_emode_disable",nil];
#endif
            
            [self.horizMenu reloadData];
            [self.longHorizMenu reloadData];
            
        }
#if defined(QIEAPP)
        [self.qieVideoBtn setBackgroundImage:[UIImage imageNamed:@"video-stop.png"] forState:UIControlStateNormal];
        self.qieWenduBtn.enabled=NO;
        self.qieMonitorBtn.enabled=NO;
        self.qieHuaZhiBtn.enabled=NO;
        self.qiePhoneBtn.enabled=NO;
        self.qieSnapshotBtn.enabled=NO;
        
        [self.qieLandVideoBtn setBackgroundImage:[UIImage imageNamed:@"video-stop.png"] forState:UIControlStateNormal];
        self.qieLandWenduBtn.enabled=NO;
        self.qieLandMonitorBtn.enabled=NO;
        self.qieLandHuaZhiBtn.enabled=NO;
        self.qieLandPhoneBtn.enabled=NO;
        self.qieLandSnapshotBtn.enabled=NO;
#endif
    }
    else {
        NSLog(@"Ignore local REC function... due to the msizeOrgVideoResolution value invalid!!!");
    }
}
- (void)reTryVideoREC:(NSTimer*)aTimer
{
    if( !isRecording ) {
        
        NSLog(@"**[REC start <reTry>]***************************************");
        [self onBtnRecording];
        
    }
}

-(void)recordingStarted:(NSNotification*)notif {

    isRecording = YES;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = NSLocalizedString(@"Recording Started",@"");
    [hud hide: YES afterDelay: 0.5];
}

-(void)recordingStopped:(NSNotification*)notif {

    [self snapshot:nil];
    camera.isShowInLiveView = NO;
    isRecording = NO;
    
    if (notif.userInfo[@"error"]) {
        NSException* exception = notif.userInfo[@"exception"];
        if (exception) {
            [UIAlertView alertViewWithTitle: NSLocalizedString(@"ERROR!",@"") message: exception.description];
        } else {
            [UIAlertView alertViewWithTitle: NSLocalizedString(@"ERROR!",@"") message: NSLocalizedString(@"Error recording video",@"")];
        }
    } else {
        
        /***
         
         VIDEO-RECORDING Note:
         
         Can use the saveToAlbumWithCompletionHandler: to save the video to the user's
         photo albums, so he can share / view it easily.
         
         ***/
        
        [self.videoGenerator saveToAlbumWithCompletionHandler: ^(NSError* error) {
            if (!error) {
#if defined(MAJESTICIPCAMP)
                self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",@"psd_bright",@"psd_contrast",nil];
                self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked", @"psd_bright_clicked",@"psd_contrast_clicked",nil];
#else
                self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode", @"f+Btn", @"f-Btn",nil];
                self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",@"f+Btn_Click", @"f-Btn_Click",nil];
#endif
#if defined(BayitCam)
                self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",nil];
                self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",nil];
#endif
#if defined(QIEAPP)
                [self.qieVideoBtn setBackgroundImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
                self.qieWenduBtn.enabled=YES;
                self.qieMonitorBtn.enabled=YES;
                self.qieHuaZhiBtn.enabled=YES;
                self.qiePhoneBtn.enabled=YES;
                self.qieSnapshotBtn.enabled=YES;
                
                [self.qieLandVideoBtn setBackgroundImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
                self.qieLandWenduBtn.enabled=YES;
                self.qieLandMonitorBtn.enabled=YES;
                self.qieLandHuaZhiBtn.enabled=YES;
                self.qieLandPhoneBtn.enabled=YES;
                self.qieLandSnapshotBtn.enabled=YES;
#endif
                
                [self.horizMenu reloadData];
                [self.longHorizMenu reloadData];
                
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
                hud.detailsLabelText = NSLocalizedString(@"Recording Saved to Album",@"");
                [hud hide: YES afterDelay: 0.5];
            } else {
                [UIAlertView alertViewWithTitle: NSLocalizedString(@"ERROR!",@"") message: NSLocalizedString(@"Error saving video",@"")];
            }
        }];
    }
}

- (IBAction)back:(id)sender
{
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        //强制竖屏
        if([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)]) {
            [[UIDevice currentDevice]performSelector:@selector(setOrientation:)
                                          withObject:(id)UIInterfaceOrientationPortrait];
        }
        return;
    }
    
    [self getAppDelegate].allowRotation=NO;
    
    /* save last frame to local storage */
    unsigned int codec_id = mCodecId;
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", camera.uid];
    UIImage *img = NULL;
    
    if (codec_id == MEDIA_CODEC_VIDEO_MPEG4 || codec_id == MEDIA_CODEC_VIDEO_H264) {
        int size = 0;
        unsigned int w = 0, h = 0;
        char *imageFrame = (char *) malloc(MAX_IMG_BUFFER_SIZE);
        size = [camera getChannel:selectedChannel Snapshot:imageFrame DataSize:MAX_IMG_BUFFER_SIZE ImageType:&codec_id   WithImageWidth:&w ImageHeight:&h];
        if (size > 0) {
            
            img = [self getUIImage:imageFrame Width:w Height:h];
            [self saveImageToFile:img :imgName];
            
            if (database != NULL) {
                if (![database executeUpdate:@"INSERT INTO snapshot(dev_uid, file_path, time) VALUES(?,?,?)", camera.uid, imgName, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]]) {
                    NSLog(@"Fail to add snapshot to database.");
                }
            }
        }
        
        free(imageFrame);
    } else {
        img = [self.monitorPortrait.image copy];
        [self saveImageToFile:img :imgName];
        [img release];
        
        if (database != NULL) {
            if (![database executeUpdate:@"INSERT INTO snapshot(dev_uid, file_path, time) VALUES(?,?,?)", camera.uid, imgName, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]]) {
                NSLog(@"Fail to add snapshot to database.");
            }
        }
    }
    
    [self.monitorLandscape deattachCamera];
    [self.monitorPortrait deattachCamera];
    
    if ([self.camera isKindOfClass:[MyCamera class]]) {
        MyCamera *cam = (MyCamera *)camera;
        cam.lastChannel = selectedChannel;
    }        

    if (camera != nil) {
//        [camera stopShow:selectedChannel];
//		[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [camera stopSoundToDevice:selectedChannel];
        [camera stopSoundToPhone:selectedChannel];
        
        [self unactiveAudioSession];
        
        //將資料回步回手機
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:selectedChannel forKey:[[[NSString alloc] autorelease] initWithFormat:@"ChannelMultiSetting_%@",viewTag]];
        [userDefaults synchronize];
        
        [self.delegate didReStartCamera:camera cameraChannel:[NSNumber numberWithInteger:camera.lastChannel] withView:viewTag];
        
        camera = nil;
        camera.delegate2 = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
                        //公版，下行可能需要註解掉
						bRemoved = TRUE;
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
                         //公版，下行可能需要註解掉
						bRemoved = TRUE;
						break;
					}
				}
			}
		}
	}	
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.prePositionView.frame=CGRectMake(0, self.view.frame.size.height-self.prePositionView.frame.size.height-self.horizMenu.frame.size.height, self.prePositionView.frame.size.width, self.prePositionView.frame.size.height);
    
    CGFloat marginW=50.0f;
    CGFloat leftW=(self.view.frame.size.width-[preBtnArr count]*24-([preBtnArr count]-1)*marginW)/2;
    NSInteger i=0;
    for (UIButton *btn in preBtnArr) {
        btn.frame=CGRectMake(leftW+i*24+i*marginW, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
        i++;
    }
    
    //修复语音的位置
    /***横屏*/
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        NSString *audioTitleStr=longAudioTitle.titleLabel.text;
        CGSize audioTitleStrSize=[audioTitleStr sizeWithFont:longAudioTitle.titleLabel.font];
        
        CGFloat offsetW=25;
        CGFloat viewW=audioTitleStrSize.width+self.longTalkButtonBtn.frame.size.width+offsetW;
        
        longTalkButton.frame=CGRectMake(self.view.frame.size.width-viewW, self.view.frame.size.height-self.longHorizMenu.frame.size.height-longTalkButton.frame.size.height, viewW, longTalkButton.frame.size.height);
        longAudioTitle.frame=CGRectMake(0, longTalkButton.frame.size.height/2-audioTitleStrSize.height/2+15, audioTitleStrSize.width+offsetW, audioTitleStrSize.height);
        [longAudioTitle setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.longTalkButtonBtn.frame=CGRectMake(longAudioTitle.frame.origin.x+longAudioTitle.frame.size.width, longTalkButton.frame.size.height-self.longTalkButtonBtn.frame.size.height, self.longTalkButtonBtn.frame.size.width, self.longTalkButtonBtn.frame.size.height);
    }
    else{ /**竖屏**/
        NSString *audioTitleStr=AudioTitle.titleLabel.text;
        CGSize audioTitleStrSize=[audioTitleStr sizeWithFont:AudioTitle.titleLabel.font];
        
        CGFloat offsetW=25;
        CGFloat viewW=audioTitleStrSize.width+self.talkButtonBtn.frame.size.width+offsetW;
        
        talkButton.frame=CGRectMake(self.view.frame.size.width-viewW, self.view.frame.size.height-self.horizMenu.frame.size.height-talkButton.frame.size.height, viewW, talkButton.frame.size.height);
        AudioTitle.frame=CGRectMake(0, talkButton.frame.size.height/2-audioTitleStrSize.height/2+15, audioTitleStrSize.width+offsetW, audioTitleStrSize.height);
        [AudioTitle setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        self.talkButtonBtn.frame=CGRectMake(AudioTitle.frame.origin.x+AudioTitle.frame.size.width, talkButton.frame.size.height-self.talkButtonBtn.frame.size.height, self.talkButtonBtn.frame.size.width, self.talkButtonBtn.frame.size.height);
    }
}
#pragma mark - 转屏时调用 (attach相机；刷新界面，重载水平按钮)
- (void)changeOrientation:(UIInterfaceOrientation)orientation {
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        
        if(isActive&&isHiddenTopNav){
            isHiddenTopNav=NO;
        }
        
        [monitorPortrait deattachCamera];
        [monitorLandscape attachCamera:camera];
    
		[self removeGLView:FALSE];
        self.view = self.landscapeView;
#if defined(CamLineProTarget) //2015 -12 -27 jay
        self.items = nil;
        
<<<<<<< HEAD
        self.items = [NSMutableArray arrayWithObjects:@"psd_contrast",@"psd_bright",@"infrared",@"restore",nil];
        self.selectItems = [NSMutableArray arrayWithObjects: @"psd_contrast_clicked",@"psd_bright_clicked",@"infrared_click",@"restore_click",nil];
#endif
=======
        
>>>>>>> 5d317abc7f51115e806da5ad5442697d0702c42a
        [self.longHorizMenu reloadData];
        [self checkLongBTN];
#if defined(QIEAPP)
        if(![[self.view subviews]containsObject:swipCameraPopView]){
            [self.view addSubview:swipCameraPopView];
        }
        self.navigationItem.rightBarButtonItem=nil;
#endif
		NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorLandscape.frame.origin.x, (int)self.monitorLandscape.frame.origin.y, (int)self.monitorLandscape.frame.size.width, (int)self.monitorLandscape.frame.size.height);
        
        //动态布局
//        NSString *audioTitleStr=longAudioTitle.titleLabel.text;
//        CGSize audioTitleStrSize=[audioTitleStr sizeWithFont:longAudioTitle.titleLabel.font];
//        longTalkButton.frame=CGRectMake(self.view.frame.size.width-audioTitleStrSize.width-self.longTalkButtonBtn.frame.size.width-25, self.view.frame.size.height-self.longHorizMenu.frame.size.height-longTalkButton.frame.size.height, audioTitleStrSize.width+self.longTalkButtonBtn.frame.size.width, longTalkButton.frame.size.height);
//        longAudioTitle.frame=CGRectMake(0, longTalkButton.frame.size.height-audioTitleStrSize.height, audioTitleStrSize.width+25, audioTitleStrSize.height);
//        [longAudioTitle setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//        self.longTalkButtonBtn.frame=CGRectMake(longAudioTitle.frame.origin.x+longAudioTitle.frame.size.width, longTalkButton.frame.size.height-self.longTalkButtonBtn.frame.size.height, self.longTalkButtonBtn.frame.size.width, self.longTalkButtonBtn.frame.size.height);
        
        //15 ->30jay
        longQVGAView.frame=CGRectMake(self.view.frame.size.width/2-longQVGAView.frame.size.width/2, self.view.frame.size.height-self.longHorizMenu.frame.size.height-longQVGAView.frame.size.height-30, longQVGAView.frame.size.width, longQVGAView.frame.size.height);
        
        self.landBrightView.frame=CGRectMake(self.view.frame.size.width/2-self.landBrightView.frame.size.width/2, self.view.frame.size.height-self.longHorizMenu.frame.size.height-self.landBrightView.frame.size.height-30, self.landBrightView.frame.size.width, self.landBrightView.frame.size.height);
        NSLog(@"y值为：%f",self.landBrightView.frame.origin.y);
        self.landConstrastView.frame=CGRectMake(self.view.frame.size.width/2-self.landConstrastView.frame.size.width/2, self.view.frame.size.height-self.longHorizMenu.frame.size.height-self.landConstrastView.frame.size.height-30, self.landConstrastView.frame.size.width, self.landConstrastView.frame.size.height);
        
        longEModeView.frame=CGRectMake(self.view.frame.size.width/2-longEModeView.frame.size.width/2, self.view.frame.size.height-self.longHorizMenu.frame.size.height-longEModeView.frame.size.height, longEModeView.frame.size.width, longEModeView.frame.size.height);
        self.loadingViewLandscape.frame=CGRectMake(self.view.frame.size.width/2-self.loadingViewLandscape.frame.size.width/2, self.view.frame.size.height/2-self.loadingViewLandscape.frame.size.height/2, self.loadingViewLandscape.frame.size.width, self.loadingViewLandscape.frame.size.height);
        
        if(![[self.view subviews]containsObject:self.prePositionView]){
            [self.view addSubview:self.prePositionView];
        }
        //self.prePositionView.frame=CGRectMake(0, self.view.frame.size.height-self.prePositionView.frame.size.height-self.longHorizMenu.frame.size.height-30, self.prePositionView.frame.size.width, self.prePositionView.frame.size.height);
        
		if( glView == nil ) {
			glView = [[CameraShowGLView alloc] initWithFrame:self.monitorLandscape.frame];
            self.glView.parentFrame = self.monitorLandscape.frame;
			[glView setMinimumGestureLength:100 MaximumVariance:50];
			glView.delegate = self;
			[glView attachCamera:camera];
		}
		else {
			[self.glView destroyFramebuffer];
            self.glView.initFrame = self.monitorLandscape.frame;
            self.glView.parentFrame = self.monitorLandscape.frame;
			self.glView.frame = self.monitorLandscape.frame;
		}
		[self.scrollViewLandscape addSubview:glView];
		self.scrollViewLandscape.zoomScale = 1.0;
        [self.scrollViewLandscape setContentSize:self.glView.frame.size];
		
		if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
			[self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
		}
		else {
			[self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
		}
		
        [[UIApplication sharedApplication] setStatusBarHidden:isHiddenTopNav withAnimation:UIStatusBarAnimationNone];
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        [self.navigationController setNavigationBarHidden:isHiddenTopNav animated:NO];
        
#if defined(QIEAPP)
        self.longHorizMenu.hidden=YES;
        self.qieLandActionView.hidden=YES;
        [self.view bringSubviewToFront:self.qieLandActionView];
        self.qieLandActionView.frame=CGRectMake(0, self.view.frame.size.height-self.qieLandActionView.frame.size.height, self.qieLandActionView.frame.size.width, self.qieLandActionView.frame.size.height);
        if(![[self.view subviews] containsObject:self.qieWenDuLbl]){
            [self.view addSubview:self.qieWenDuLbl];
            self.qieWenDuLbl.frame=CGRectMake(0, self.qieLandActionView.frame.origin.y-self.qieWenDuLbl.frame.size.height-self.navigationController.navigationBar.frame.size.height-20, self.qieWenDuLbl.frame.size.width, self.qieWenDuLbl.frame.size.height);
        }
        self.qieWenDuLbl.hidden=YES;
#endif
        
    }
    else {
        
        isHiddenTopNav=YES;
        
        [monitorLandscape deattachCamera];
        [monitorPortrait attachCamera:camera];
        
		[self removeGLView:TRUE];
        self.view = self.portraitView;
#if defined(CamLineProTarget) //2015 -12 -27 jay
        self.items = nil;
        
        self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",@"f+Btn", @"f-Btn",nil];
        self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_recordstop", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",@"f+Btn_Click", @"f-Btn_Click",nil];
#endif
        
        [self.horizMenu reloadData];
        [self checkBTN];
        
#if defined(QIEAPP)
        if(![[self.view subviews]containsObject:swipCameraPopView]){
            [self.view addSubview:swipCameraPopView];
        }
        self.navigationItem.rightBarButtonItem=listButtonItem;
#endif
        static CGFloat py=-1;
        if(py==-1){
            py=self.scrollViewPortrait.frame.origin.y;
        }
        //动态布局
        self.scrollViewPortrait.frame=CGRectMake(0, py+5, self.view.frame.size.width, self.view.frame.size.width/4*3);
        self.scrollViewPortrait.contentSize=self.scrollViewPortrait.frame.size;
        self.monitorPortrait.frame=CGRectMake(0, 0, self.scrollViewPortrait.frame.size.width, self.scrollViewPortrait.frame.size.height);
        statusBar.frame=CGRectMake(0, 0, self.view.frame.size.width, statusBar.frame.size.height);
        
//        NSString *audioTitleStr=AudioTitle.titleLabel.text;
//        CGSize audioTitleStrSize=[audioTitleStr sizeWithFont:AudioTitle.titleLabel.font];
//        talkButton.frame=CGRectMake(self.view.frame.size.width-audioTitleStrSize.width-self.talkButtonBtn.frame.size.width-25, self.view.frame.size.height-self.horizMenu.frame.size.height-talkButton.frame.size.height, audioTitleStrSize.width+self.talkButtonBtn.frame.size.width, talkButton.frame.size.height);
//        AudioTitle.frame=CGRectMake(0, talkButton.frame.size.height-audioTitleStrSize.height, audioTitleStrSize.width+20, audioTitleStrSize.height);
//        [AudioTitle setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

        self.talkButtonBtn.frame=CGRectMake(AudioTitle.frame.origin.x+AudioTitle.frame.size.width, talkButton.frame.size.height-self.talkButtonBtn.frame.size.height, self.talkButtonBtn.frame.size.width, self.talkButtonBtn.frame.size.height);
        
        CGFloat moreScrollViewFunHeight=self.view.frame.size.height-self.scrollViewPortrait.frame.size.height-self.scrollViewPortrait.frame.origin.y-self.horizMenu.frame.size.height;
        
        scrollQVGAView.frame=CGRectMake(self.view.frame.size.width/2-scrollQVGAView.frame.size.width/2, self.view.frame.size.height-self.horizMenu.frame.size.height-moreScrollViewFunHeight, scrollQVGAView.frame.size.width, moreScrollViewFunHeight);
        //亮度对比度
        self.portraitBrightScrollView.frame=CGRectMake(self.view.frame.size.width/2-self.portraitBrightScrollView.frame.size.width/2, self.view.frame.size.height-self.horizMenu.frame.size.height-moreScrollViewFunHeight, self.portraitBrightScrollView.frame.size.width, moreScrollViewFunHeight);
        
        self.portraitConstrastScrollView.frame=CGRectMake(self.view.frame.size.width/2-self.portraitConstrastScrollView.frame.size.width/2, self.view.frame.size.height-self.horizMenu.frame.size.height-moreScrollViewFunHeight, self.portraitConstrastScrollView.frame.size.width, moreScrollViewFunHeight);
        
        
        scrollEModeView.frame=CGRectMake(self.view.frame.size.width/2-scrollEModeView.frame.size.width/2, self.view.frame.size.height-self.horizMenu.frame.size.height-moreScrollViewFunHeight, scrollEModeView.frame.size.width,moreScrollViewFunHeight);
        
        self.loadingViewPortrait.frame=CGRectMake(self.scrollViewPortrait.frame.size.width/2-self.loadingViewPortrait.frame.size.width/2, self.scrollViewPortrait.frame.origin.y+self.scrollViewPortrait.frame.size.height/2-self.loadingViewPortrait.frame.size.height/2, self.loadingViewPortrait.frame.size.width, self.loadingViewPortrait.frame.size.height);
        
        if(![[self.view subviews]containsObject:self.prePositionView]){
            [self.view addSubview:self.prePositionView];
        }
        
		NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorPortrait.frame.origin.x, (int)self.monitorPortrait.frame.origin.y, (int)self.monitorPortrait.frame.size.width, (int)self.monitorPortrait.frame.size.height);
		if( glView == nil ) {
			glView = [[CameraShowGLView alloc] initWithFrame:self.monitorPortrait.frame];
            self.glView.parentFrame = self.monitorPortrait.frame;
			[glView setMinimumGestureLength:100 MaximumVariance:50];
			glView.delegate = self;
			[glView attachCamera:camera];
		}
		else {
			[self.glView destroyFramebuffer];
            self.glView.initFrame = self.monitorPortrait.frame;
            self.glView.parentFrame = self.monitorPortrait.frame;
			self.glView.frame = self.monitorPortrait.frame;
		}
		[self.scrollViewPortrait addSubview:glView];
		self.scrollViewPortrait.zoomScale = 1.0;
        [self.scrollViewPortrait setContentSize:self.glView.frame.size];
		
		if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
			[self.scrollViewPortrait bringSubviewToFront:monitorPortrait/*self.glView*/];
		}
		else {
#ifndef DEF_Using_APLEAGLView
            [self.scrollViewPortrait bringSubviewToFront:/*monitorPortrait*/self.glView];
            
            [[self test] setHidden:TRUE];
#else
            [self.scrollViewPortrait bringSubviewToFront:[self test]];
#endif
		}

        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
#if defined(QIEAPP)
        self.myPtzView.hidden=YES;
        self.horizMenu.hidden=YES;
        //self.statusLabel.hidden=YES;
        //statusBar.hidden=YES;
        //frameInfoLabel.hidden=YES;
        //videoInfoLabel.hidden=YES;
        //_qualityLabel.hidden=YES;
        self.scrollViewPortrait.frame=CGRectMake(0, self.scrollViewPortrait.frame.origin.y, self.scrollViewPortrait.frame.size.width, self.scrollViewPortrait.frame.size.height);
        self.loadingViewPortrait.frame=CGRectMake(self.scrollViewPortrait.frame.size.width/2-self.loadingViewPortrait.frame.size.width/2, self.scrollViewPortrait.frame.origin.y+self.scrollViewPortrait.frame.size.height/2-self.loadingViewPortrait.frame.size.height/2, self.loadingViewPortrait.frame.size.width, self.loadingViewPortrait.frame.size.height);
        self.view.backgroundColor=HexRGB(0xe1e1e1);
        self.qieActionView.hidden=NO;
        self.qieActionView.frame=CGRectMake(0, self.view.frame.size.height-self.qieActionView.frame.size.height, self.qieActionView.frame.size.width, self.qieActionView.frame.size.height);
        //self.qieWenDuLbl.hidden=NO;
        self.qieWenDuLbl.frame=CGRectMake(0, self.scrollViewPortrait.frame.size.height-self.qieWenDuLbl.frame.size.height, self.qieWenDuLbl.frame.size.width, self.qieWenDuLbl.frame.size.height);
        self.qieWenDuLbl.backgroundColor=[UIColor clearColor];
        if(![[self.view subviews] containsObject:self.qieWenDuLbl]){
            [self.view addSubview:self.qieWenDuLbl];
        }
#endif
        
    }
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}
#pragma mark  屏幕旋转2
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
    //2
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


#pragma mark - View lifecycle

- (void)dealloc 
{
    [self.statusLabel release];
    [self.modeLabel release];
    [self.videoInfoLabel release];
    [self.frameInfoLabel release];
    [self.monitorPortrait release];
    [self.monitorLandscape release];
    [self.scrollViewPortrait release];
    [self.scrollViewLandscape release];
    [self.portraitView release];
    [self.landscapeView release];
    [self.loadingViewPortrait release];
    [self.loadingViewLandscape release];
    [self.connModeImageView release];
    [self.camera release];
    [self.multiStreamPopoverController release];
    [self.directoryPath release];
    
	[_qualityLabel release];
	[btnPlaySwitcher_Landscpae release];
	[btnPlaySwitcher_Portrait release];
    [_myPtzView release];
    [_myPTZDownBtn release];
    [_myPtzUpBtn release];
    [_myPtzLeftBtn release];
    [_myPtzRightBtn release];
    [_landBackBtn release];
    [_longBtn50HZ release];
    [_longBtn60HZ release];
    [_talkButtonBtn release];
    [_longTalkButtonBtn release];
    [_portraitConstrastScrollView release];
    [_portraitContrastView release];
    [_portraitContrastTitle release];
    [_portaitContrastHigest release];
    [_portaitContrastHigt release];
    [_portaitContrastMiddle release];
    [_portaitContrastLow release];
    [_portaitContrastLowest release];
    [_portraitBrightScrollView release];
    [_portraitBrightView release];
    [_portraitBrightTitle release];
    [_portraitBrightHigh release];
    [_portraitBrightHighLow release];
    [_portraitBrightMiddle release];
    [_portraitBrightLow release];
    [_portraitBrightLowest release];
    [_landConstrastView release];
    [_landConstrastTitle release];
    [_landContrastHighest release];
    [_landContrastHigh release];
    [_landContrastMiddle release];
    [_landContrastLow release];
    [_landContrastLowest release];
    [_landBrightView release];
    [_landBrightTitle release];
    [_landBrightHighest release];
    [_landBrightHigh release];
    [_landBrightMiddle release];
    [_landBrightLow release];
    [_landBrightLowest release];
    [_prePositionView release];
    [_prePositionTitleLbl release];
    [_prePositionTipsLbl release];
    [preBtnArr release];
    [_preBtn1 release];
    [_preBtn2 release];
    [_preBtn3 release];
    [_preBtn4 release];
    [_preNumView release];
    [_test release];
<<<<<<< HEAD
    [_longInfraredView release];
    [_longInfraredOpen release];
    [_longInfraredClose release];
    [_longInfraredAuto release];
    [_longInfraredTitle release];
=======
    [_qieActionView release];
    [_qieSnapshotBtn release];
    [_qieMonitorBtn release];
    [_qieWenduBtn release];
    [_qieVideoBtn release];
    [_qieHuaZhiBtn release];
    [_qiePhoneBtn release];
    [_qieWenDuLbl release];
    [swipCameraPopView release];
    [swipCameraBtns release];
    [_qieLandActionView release];
    [_qieLandMonitorBtn release];
    [_qieLandWenduBtn release];
    [_qieLandVideoBtn release];
    [_qieLandSnapshotBtn release];
    [_qieLandHuaZhiBtn release];
    [_qieLandPhoneBtn release];
    [listButtonItem release];
    if(wenDuLblTimer){
        if([wenDuLblTimer isValid]){
            [wenDuLblTimer invalidate];
        }
        [wenDuLblTimer release];
        wenDuLblTimer  =nil;
    }
>>>>>>> 5d317abc7f51115e806da5ad5442697d0702c42a
    [super dealloc];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"SCROLL!");
}
-(void)swipCamera:(UIButton *)btn{
    swipCameraPopView.frame=CGRectMake(self.view.frame.size.width-swipCameraPopView.frame.size.width, 0, swipCameraPopView.frame.size.width, swipCameraPopView.frame.size.height);
    swipCameraPopView.hidden=!swipCameraPopView.hidden;
    [self.view bringSubviewToFront:swipCameraPopView];
}
- (void)viewDidLoad {
    
#if defined(QIEAPP)
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    listButton.frame = CGRectMake(20, 0, 44, 44);
    [listButton setBackgroundImage:[UIImage imageNamed:@"list-btn.png"] forState:UIControlStateNormal];
    [listButton setBackgroundImage:[UIImage imageNamed:@"list-btn-click.png"] forState:UIControlStateHighlighted];
    [listButton addTarget:self action:@selector(swipCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    listButtonItem = [[UIBarButtonItem alloc] initWithCustomView:listButton];
    
    self.navigationItem.rightBarButtonItem=listButtonItem;
    
    self.qieLandActionView.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bk"]];
#endif
    
    //button长按事件
    UILongPressGestureRecognizer *longPress1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(preBtnLongTouch1:)];
    [self.preBtn1 addGestureRecognizer:longPress1];
    
    UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(preBtnLongTouch2:)];
    [self.preBtn2 addGestureRecognizer:longPress2];
    
    UILongPressGestureRecognizer *longPress3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(preBtnLongTouch3:)];
    [self.preBtn3 addGestureRecognizer:longPress3];
    
    UILongPressGestureRecognizer *longPress4 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(preBtnLongTouch4:)];
    [self.preBtn4 addGestureRecognizer:longPress4];
    
    [longPress1 release];
    [longPress2 release];
    [longPress3 release];
    [longPress4 release];
#pragma mark 初始化ui
    self.prePositionTitleLbl.text=NSLocalizedString(@"Preset", @"");
    self.prePositionTipsLbl.text=NSLocalizedString(@"Click to move preset, Longpress to save", @"");
    
#if defined(MKCEYE)
    self.prePositionTitleLbl.backgroundColor=HexRGB(0x92adb5);
    self.preNumView.backgroundColor=HexRGB(0x92adb5);
#endif
    
    
    preBtnArr=@[self.preBtn1,self.preBtn2,self.preBtn3,self.preBtn4];
    [preBtnArr retain];
    
    camera.isShowInMultiView = NO;
    isChangeChannel = NO;
    self.isCanSendSetCameraCMD=YES;
    
    self.prePositionView.hidden=YES;
    
#if defined(BayitCam)
    [AudioTitle setTitle:NSLocalizedStringFromTable(@"Push to talk", @"bayitcam", nil) forState:UIControlStateNormal];
    [longAudioTitle setTitle:NSLocalizedStringFromTable(@"Push to talk", @"bayitcam", nil) forState:UIControlStateNormal];
#else
    [AudioTitle setTitle:NSLocalizedString(@"Press to talk", @"") forState:UIControlStateNormal];
    [longAudioTitle setTitle:NSLocalizedString(@"Press to talk", @"") forState:UIControlStateNormal];
#endif
    
    [QVGATitle setTitle:NSLocalizedString(@"Video Quality", @"") forState:UIControlStateNormal];
    [EModeTitle setTitle:NSLocalizedString(@"Environment Mode", @"") forState:UIControlStateNormal];
    [longQVGATitle setTitle:NSLocalizedString(@"Video Quality", @"") forState:UIControlStateNormal];
    [longEModeTitle setTitle:NSLocalizedString(@"Environment Mode", @"") forState:UIControlStateNormal];
    
    [setHighest setTitle:NSLocalizedString(@"Highest", @"") forState:UIControlStateNormal];
    [setHigh setTitle:NSLocalizedString(@"High", @"") forState:UIControlStateNormal];
    [setMedium setTitle:NSLocalizedString(@"Medium", @"") forState:UIControlStateNormal];
    [setLow setTitle:NSLocalizedString(@"Low", @"") forState:UIControlStateNormal];
    [setLowest setTitle:NSLocalizedString(@"Lowest", @"") forState:UIControlStateNormal];
    
    
    
    [setOutDoor setTitle:NSLocalizedString(@"Outdoor Mode", @"") forState:UIControlStateNormal];
    [setNight setTitle:NSLocalizedString(@"Night Mode", @"") forState:UIControlStateNormal];
    
#if defined(EasynPTarget)
    [set50Hz setTitle:NSLocalizedString(@"Indoor Mode(50Hz)", @"") forState:UIControlStateNormal];
    [_longBtn50HZ setTitle:NSLocalizedString(@"Indoor Mode(50Hz)", @"") forState:UIControlStateNormal];
    [set60Hz setTitle:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Outdoor Mode", @""),NSLocalizedString(@"60HZ", @"")] forState:UIControlStateNormal];
    [_longBtn60HZ setTitle:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Outdoor Mode", @""),NSLocalizedString(@"60HZ", @"")] forState:UIControlStateNormal];
#else
    [set50Hz setTitle:[NSString stringWithFormat:@"%@(50HZ)",NSLocalizedString(@"Night Mode", @"")] forState:UIControlStateNormal];
    [_longBtn50HZ setTitle:[NSString stringWithFormat:@"%@(50HZ)",NSLocalizedString(@"Night Mode", @"")] forState:UIControlStateNormal];
    [set60Hz setTitle:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Outdoor Mode", @""),NSLocalizedString(@"60HZ", @"")] forState:UIControlStateNormal];
    [_longBtn60HZ setTitle:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"Outdoor Mode", @""),NSLocalizedString(@"60HZ", @"")] forState:UIControlStateNormal];
#endif
#if defined(IDHDCONTROL)
    [set50Hz setTitle:[NSString stringWithFormat:@"%@ 50Hz",NSLocalizedString(@"Night Mode", @"")] forState:UIControlStateNormal];
    [_longBtn50HZ setTitle:[NSString stringWithFormat:@"%@ 50Hz",NSLocalizedString(@"Night Mode", @"")] forState:UIControlStateNormal];
    [set60Hz setTitle:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Outdoor Mode", @""),NSLocalizedString(@"60Hz", @"")] forState:UIControlStateNormal];
    [_longBtn60HZ setTitle:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Outdoor Mode", @""),NSLocalizedString(@"60Hz", @"")] forState:UIControlStateNormal];
#endif
    
    
    
    [longSetHighest setTitle:NSLocalizedString(@"Highest", @"") forState:UIControlStateNormal];
    [longSetHigh setTitle:NSLocalizedString(@"High", @"") forState:UIControlStateNormal];
    [longSetMedium setTitle:NSLocalizedString(@"Medium", @"") forState:UIControlStateNormal];
    [longSetLow setTitle:NSLocalizedString(@"Low", @"") forState:UIControlStateNormal];
    [longSetLowest setTitle:NSLocalizedString(@"Lowest", @"") forState:UIControlStateNormal];
    [longSetOutDoor setTitle:NSLocalizedString(@"Outdoor Mode", @"") forState:UIControlStateNormal];
    [longSetNight setTitle:NSLocalizedString(@"Night Mode", @"") forState:UIControlStateNormal];
    
    
    /*****亮度、对比度***********/
    [self.portraitContrastTitle setTitle:NSLocalizedString(@"Contrast", @"") forState:UIControlStateNormal];
    [self.portraitBrightTitle setTitle:NSLocalizedString(@"Bright", @"") forState:UIControlStateNormal];
    [self.landConstrastTitle setTitle:NSLocalizedString(@"Contrast", @"") forState:UIControlStateNormal];
    [self.landBrightTitle setTitle:NSLocalizedString(@"Bright", @"") forState:UIControlStateNormal];
    
    [self.portraitBrightHigh setTitle:NSLocalizedString(@"Highest", @"") forState:UIControlStateNormal];
    [self.portraitBrightHighLow setTitle:NSLocalizedString(@"High", @"") forState:UIControlStateNormal];
    [self.portraitBrightMiddle setTitle:NSLocalizedString(@"Medium", @"") forState:UIControlStateNormal];
    [self.portraitBrightLow setTitle:NSLocalizedString(@"Low", @"") forState:UIControlStateNormal];
    [self.portraitBrightLowest setTitle:NSLocalizedString(@"Lowest", @"") forState:UIControlStateNormal];
    
    [self.portaitContrastHigest setTitle:NSLocalizedString(@"Highest", @"") forState:UIControlStateNormal];
    [self.portaitContrastHigt setTitle:NSLocalizedString(@"High", @"") forState:UIControlStateNormal];
    [self.portaitContrastMiddle setTitle:NSLocalizedString(@"Medium", @"") forState:UIControlStateNormal];
    [self.portaitContrastLow setTitle:NSLocalizedString(@"Low", @"") forState:UIControlStateNormal];
    [self.portaitContrastLowest setTitle:NSLocalizedString(@"Lowest", @"") forState:UIControlStateNormal];
    //横屏对比度亮度
    [self.landBrightHighest setTitle:NSLocalizedString(@"Highest", @"") forState:UIControlStateNormal];
    [self.landBrightHigh setTitle:NSLocalizedString(@"High", @"") forState:UIControlStateNormal];
    [self.landBrightMiddle setTitle:NSLocalizedString(@"Medium", @"") forState:UIControlStateNormal];
    [self.landBrightLow setTitle:NSLocalizedString(@"Low", @"") forState:UIControlStateNormal];
    [self.landBrightLowest setTitle:NSLocalizedString(@"Lowest", @"") forState:UIControlStateNormal];
    
    [self.landContrastHighest setTitle:NSLocalizedString(@"Highest", @"") forState:UIControlStateNormal];
    [self.landContrastHigh setTitle:NSLocalizedString(@"High", @"") forState:UIControlStateNormal];
    [self.landContrastMiddle setTitle:NSLocalizedString(@"Medium", @"") forState:UIControlStateNormal];
    [self.landContrastLow setTitle:NSLocalizedString(@"Low", @"") forState:UIControlStateNormal];
    [self.landContrastLowest setTitle:NSLocalizedString(@"Lowest", @"") forState:UIControlStateNormal];
    
    /*****亮度、对比度***********/
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        scrollQVGAView.height -= 88;
        scrollQVGAView.y += 88;
        scrollEModeView.height -= 88;
        scrollEModeView.y += 88;
        talkButton.y -=70;
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    
#ifndef MacGulp
    self.navigationItem.title = NSLocalizedString(@"Live View", @"");
#else
    self.title = camera.name;
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
    [negativeSpacer release];
    
    [self.monitorPortrait setMinimumGestureLength:100 MaximumVariance:50];
    [self.monitorPortrait setUserInteractionEnabled:YES];
    self.monitorPortrait.contentMode = UIViewContentModeScaleToFill;
    self.monitorPortrait.backgroundColor = [UIColor blackColor];
    self.monitorPortrait.delegate = self;
    
    [self.monitorLandscape setMinimumGestureLength:100 MaximumVariance:50];
    [self.monitorLandscape setUserInteractionEnabled:YES];
    self.monitorLandscape.contentMode = UIViewContentModeScaleAspectFit;
    self.monitorLandscape.backgroundColor = [UIColor blackColor];
    self.monitorLandscape.delegate = self;
    
    self.scrollViewPortrait.minimumZoomScale = ZOOM_MIN_SCALE;
    self.scrollViewPortrait.maximumZoomScale = ZOOM_MAX_SCALE;
    self.scrollViewPortrait.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollViewPortrait.contentSize = self.scrollViewPortrait.frame.size;
    
    self.scrollViewLandscape.minimumZoomScale = ZOOM_MIN_SCALE;
    self.scrollViewLandscape.maximumZoomScale = ZOOM_MAX_SCALE;
    self.scrollViewLandscape.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollViewLandscape.contentSize = self.scrollViewLandscape.frame.size;
    
    self.loadingViewLandscape.hidesWhenStopped = YES;
    self.loadingViewPortrait.hidesWhenStopped = YES;
    
    [scrollQVGAView setContentSize:qvgaView.frame.size];
    [scrollQVGAView setClipsToBounds:YES];
    scrollQVGAView.delegate = self;
    
    [scrollEModeView setContentSize:emodeView.frame.size];
    [scrollEModeView setClipsToBounds:YES];
    scrollEModeView.delegate = self;
    
    [self.portraitConstrastScrollView setContentSize:self.portraitContrastView.frame.size];
    [self.portraitConstrastScrollView setClipsToBounds:YES];
    self.portraitConstrastScrollView.delegate=self;
    
    [self.portraitBrightScrollView setContentSize:self.portraitBrightView.frame.size];
    [self.portraitBrightScrollView setClipsToBounds:YES];
    self.portraitBrightScrollView.delegate=self;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.scrollViewLandscape addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];

#if defined(SVIPCLOUD)
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HexRGB(0x3d3c3c),NSForegroundColorAttributeName,nil]];
    statusLabel.textColor=HexRGB(0x3d3c3c);
    modeLabel.textColor=HexRGB(0x3d3c3c);
    videoInfoLabel.textColor=HexRGB(0x3d3c3c);
    frameInfoLabel.textColor=HexRGB(0x3d3c3c);
    [_qualityLabel setTextColor:HexRGB(0x3d3c3c)];
    [AudioTitle setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longAudioTitle setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    
    [QVGATitle setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setHighest setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setHigh setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setMedium setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setLow setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setLowest setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    
    [longQVGATitle setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetHighest setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetHigh setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetMedium setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetLow setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetLowest setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    
    [set50Hz setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [set60Hz setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setOutDoor setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [setNight setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [EModeTitle setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetOutDoor setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longSetNight setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [longEModeTitle setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
#endif
//addjay 2015 12 28
    /*** 红外开关 ****/
#ifdef CamLineProTarget
    [self.longInfraredTitle setTitle:NSLocalizedString(@"Led Light", @"") forState:UIControlStateNormal];
    [self.longInfraredOpen setTitle:NSLocalizedString(@"Open", @"") forState:UIControlStateNormal];
    [self.longInfraredClose setTitle:NSLocalizedString(@"Close", @"") forState:UIControlStateNormal];
    [self.longInfraredAuto setTitle:NSLocalizedString(@"Auto", @"") forState:UIControlStateNormal];
#endif
    
#pragma mark 初始化数据
    
#if defined(MAJESTICIPCAMP)
    self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",@"psd_bright",@"psd_contrast",nil];
    self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_recordstop", @"leo_snapshot_clicked", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked", @"psd_bright_clicked",@"psd_contrast_clicked",nil];
#else
    self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",@"f+Btn", @"f-Btn",nil];
    self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_recordstop", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",@"f+Btn_Click", @"f-Btn_Click",nil];
#endif
#if defined(BayitCam)
    self.items = [NSMutableArray arrayWithObjects:@"leo_speaker_off", @"ceo_record", @"leo_snapshot",@"ceo_presetting_enable.png", @"leo_mirror_ud", @"leo_mirror_rl", @"leo_qvga", @"leo_emode",nil];
    self.selectItems = [NSMutableArray arrayWithObjects:@"leo_speaker_on_clicked", @"ceo_record", @"leo_snapshot_clicked",@"ceo_presetting_clicked.png", @"leo_mirror_ud_clicked", @"leo_mirror_rl_clicked", @"leo_qvga_clicked", @"leo_emode_clicked",nil];
#endif
    
    isListening = NO;
    isTalking = NO;
    isQVGAView = NO;
    isVerticalFlip = NO;
    isHorizontalFlip = NO;
    isEModeView = NO;
    isActive = NO;
    
#pragma mark 增加对应通知
   
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(recordingStarted:) name: kNOTF_RECORDING_STARTED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(recordingStopped:) name: kNOTF_RECORDING_STOPPED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];
	
    
    popoverClass = [WEPopoverController class];
    
    //selectedChannel = 0;
    wrongPwdRetryTime = 0;
    
    //self.library = [[ALAssetsLibrary alloc] init];
    //设置app状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

	camera.delegate2 = self;
    
//    [self initQVGAMode:[MyCamera getCameraQVGA:self.camera]];
    
    
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.statusLabel = nil;
    self.modeLabel = nil;
    self.videoInfoLabel = nil;
    self.frameInfoLabel = nil;
    self.monitorPortrait = nil;
    self.monitorLandscape = nil;
    self.scrollViewPortrait = nil;
    self.scrollViewLandscape = nil;
    self.portraitView = nil;
    self.landscapeView = nil;
    self.loadingViewLandscape = nil;
    self.loadingViewPortrait = nil;
    self.connModeImageView = nil;
    self.camera = nil;
    [self.multiStreamPopoverController dismissPopoverAnimated:NO];
    self.multiStreamPopoverController = nil;
    self.directoryPath = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationDidBecomeActiveNotification];
    
	[self setQualityLabel:nil];
	if(glView) {
    	[self.glView tearDownGL];
		[self.glView release];
	}
	CVPixelBufferRelease(mPixelBuffer);
	CVPixelBufferPoolRelease(mPixelBufferPool);
	[btnPlaySwitcher_Portrait release];
	btnPlaySwitcher_Portrait = nil;
	[btnPlaySwitcher_Landscpae release];
	btnPlaySwitcher_Landscpae = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self changeOrientation:self.interfaceOrientation];
    //[self getEMode]; //modif by jay
    
    camera.isChangeChannel = YES;
#ifdef DEF_Using_APLEAGLView
    [[self test] setupGL];
#endif
    
    [self getAppDelegate].allowRotation=YES;
#if defined(QIEAPP)
    [self initSwipView];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    //camera.isSupportMultiRecording = NO;
    [self getAppDelegate].allowRotation=NO;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    if (camera != nil) {
        
        //camera.isSupportMultiRecording = YES;
        
        camera.delegate2 = self;
        
        
        /*SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
        s->channel = 0;
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
        free(s);
        
        SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
        free(s2);
        
        SMsgAVIoctrlTimeZone s3={0};
        s3.cbSize = sizeof(s3);
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];*/

        
        

        if ([camera getMultiStreamSupportOfChannel:0] && [[camera getSupportedStreams] count] > 1) {            
            if (self.navigationItem.rightBarButtonItem == nil) {
                
                UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
                customButton.frame = CGRectMake(0, 0, 60, 49);
                [customButton setBackgroundImage:[UIImage imageNamed:@"live_chicon_clicke" ] forState:UIControlStateNormal];
                [customButton addTarget:self action:@selector(selectChannel:) forControlEvents:UIControlEventTouchUpInside];
                [customButton setTitle:[NSString stringWithFormat:@"CH%d", selectedChannel + 1]
                              forState:UIControlStateNormal];
                customButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
                customButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                customButton.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 1, 0);
                
                UIBarButtonItem *streamButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                   target:nil action:nil];
                negativeSpacer.width = -10;

                self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, streamButton, nil];
                [streamButton release];
                [negativeSpacer release];
            }
            
            self.navigationItem.title = [NSString stringWithFormat:@"%@ - CH%d", camera.name, selectedChannel + 1];
            
        } else {
            self.navigationItem.title = camera.name;
            //self.navigationItem.rightBarButtonItem = nil;
        }
        
        [self verifyConnectionStatus];
        if (camera.sessionState == CONNECTION_STATE_CONNECTED) {
            //add by jay
            [self getEMode];
            [self getContrast];
            [self getBright];
            [self getLEDLight];
        }else if(camera.sessionState != CONNECTION_STATE_CONNECTED)
            [camera connect:camera.uid];
       
        if ([camera getConnectionStateOfChannel:0] != CONNECTION_STATE_CONNECTED) {
            [camera start:0];
            
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);

			SMsgAVIoctrlTimeZone s3={0};
			s3.cbSize = sizeof(s3);
			[camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
        }
        
        if ( selectedChannel != 0 && [camera getConnectionStateOfChannel:selectedChannel] != CONNECTION_STATE_CONNECTED) {
            [camera start:selectedChannel];
        }
        
        [camera startShow:selectedChannel ScreenObject:self];
        
        
        SMsgAVIoctrlSetSoundReq *quality = (SMsgAVIoctrlSetSoundReq*)malloc(sizeof(SMsgAVIoctrlSetSoundReq));
        memset(quality, 0, sizeof(SMsgAVIoctrlSetSoundReq));
        quality->SoundIn=95;
        quality->SoundOut=95;
        [camera sendIOCtrlToChannel:0
                                Type:0x224E
                                Data:(char *)quality
                            DataSize:sizeof(SMsgAVIoctrlSetSoundReq)];
        
        free(quality);
        
        [loadingViewLandscape setHidden:NO];
        [loadingViewPortrait setHidden:NO];
        [loadingViewPortrait startAnimating];
        [loadingViewLandscape startAnimating];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(loadCameraQVGAStatus) userInfo:nil repeats:NO];
        
#if defined(Aztech)
#else
        if(![MyCamera getCameraLoadQVGA:camera.uid]) {
            //[self loadCameraQVGAStatus];
//            [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(setCameraQVGAFPS) userInfo:nil repeats:NO];
        }
#endif
        
        [self activeAudioSession];
    }
    
    //界面动态布局
    CGSize emodeSize=[EModeTitle.titleLabel.text textSize:EModeTitle.font];
    if(EModeTitle.frame.size.width<emodeSize.width){
        EModeTitle.frame=CGRectMake(emodeView.frame.size.width/2-(emodeSize.width+15)/2, EModeTitle.frame.origin.y, emodeSize.width+15, EModeTitle.frame.size.height);
    }
    if(longEModeTitle.frame.size.width<emodeSize.width){
        longEModeTitle.frame=CGRectMake(longEModeView.frame.size.width/2-(emodeSize.width+15)/2, longEModeTitle.frame.origin.y, emodeSize.width+15, longEModeTitle.frame.size.height);
    }
    
}
-(void)setCameraQVGAFPS{
#if defined(Aztech)
#else
    if(self.isCanSendSetCameraCMD){
//        [MyCamera loadCameraQVGA:camera];
    }
    else{
//        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(setCameraQVGAFPS) userInfo:nil repeats:NO];
    }
#endif
}
-(void)loadCameraQVGAStatus{
    SMsgAVIoctrlGetStreamCtrlReq *quality = (SMsgAVIoctrlGetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    memset(quality, 0, sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    
    quality->channel=0;
    
    [camera sendIOCtrlToChannel:0
                       Type:IOTYPE_USER_IPCAM_GETSTREAMCTRL_REQ
                       Data:(char *)quality
                   DataSize:sizeof(SMsgAVIoctrlGetStreamCtrlReq)];
    
    free(quality);
}

#pragma mark - MyCamera Delegate Methods

- (void)camera:(MyCamera *)camera_ _didChangeSessionStatus:(NSInteger)status
{    
    if (camera_ == camera) {
    
        [self verifyConnectionStatus];
        
        if (status == CONNECTION_STATE_TIMEOUT) {
            
            [camera stopShow:selectedChannel];
			[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
            [camera stopSoundToDevice:selectedChannel];
            [camera stopSoundToPhone:selectedChannel];
            [camera disconnect];
            [self unactiveAudioSession];
            
            [camera connect:camera.uid];
            [camera start:0];
            [camera startShow:selectedChannel ScreenObject:self];
            
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
            
			SMsgAVIoctrlTimeZone s3={0};
			s3.cbSize = sizeof(s3);
			[camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
			
            [loadingViewLandscape setHidden:NO];
            [loadingViewPortrait setHidden:NO];
            [loadingViewPortrait startAnimating];
            [loadingViewLandscape startAnimating];
            
            [self activeAudioSession];
            
            if (selectedAudioMode == AUDIO_MODE_SPEAKER) [camera startSoundToPhone:selectedChannel];
            if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [camera startSoundToDevice:selectedChannel];
        }
//        }else if (status == CONNECTION_STATE_CONNECTED)
//            {
//                //add by jay
//                [self getEMode];
//                [self getContrast];
//                [self getBright];
//                [self getLEDLight];
//            }
    }
}

- (void)camera:(MyCamera *)camera_ _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{        
    if (camera_ == camera) {
        
        if (channel == selectedChannel) {                   
            
            [self verifyConnectionStatus];
            
            if (status == CONNECTION_STATE_WRONG_PASSWORD) {

				[camera stopShow:selectedChannel];
				[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [camera stop:selectedChannel];
                
                if (wrongPwdRetryTime++ < 3) {
                
                    // show change password dialog
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Correct the wrong password", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), NSLocalizedString(@"OK", nil), nil];
                    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                    [alert show];
                    [alert release];
                }
                
            } else if (status == CONNECTION_STATE_CONNECTED) {
                
                // self.statusLabel.text = NSLocalizedString(@"Connected", nil);
                //add by jay
                [self getEMode];
                [self getContrast];
                [self getBright];
                [self getLEDLight];
                //
            } else if (status == CONNECTION_STATE_CONNECTING) {
                
                // self.statusLabel.text = NSLocalizedString(@"Connecting...", nil);
                
            } else if (status == CONNECTION_STATE_TIMEOUT) {
                
                // self.statusLabel.text = NSLocalizedString(@"Timeout", @"");
                
                [camera stopShow:selectedChannel];
				[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [camera stopSoundToDevice:selectedChannel];
                [camera stopSoundToPhone:selectedChannel];
                [camera disconnect];
                [self unactiveAudioSession];
                
                [camera connect:camera.uid];
                [camera start:0];
                [camera startShow:selectedChannel ScreenObject:self];
                
                SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
                s->channel = 0;
                [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
                free(s);
                
                SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
                [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
                free(s2);

				SMsgAVIoctrlTimeZone s3={0};
				s3.cbSize = sizeof(s3);
				[camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
				
                [loadingViewLandscape setHidden:NO];
                [loadingViewPortrait setHidden:NO];
                [loadingViewPortrait startAnimating];
                [loadingViewLandscape startAnimating];
                
                [self activeAudioSession];
                
                if (selectedAudioMode == AUDIO_MODE_SPEAKER) [camera startSoundToPhone:selectedChannel];
                if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [camera startSoundToDevice:selectedChannel];
                
            } else {
                
                // self.statusLabel.text = NSLocalizedString(@"Off line", nil);
                
                [self.loadingViewPortrait stopAnimating];
                [self.loadingViewLandscape stopAnimating];
            }
        }
    }
}

- (void)camera:(MyCamera *)camera _didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size
{
    [loadingViewPortrait stopAnimating];
    [loadingViewLandscape stopAnimating];
}

- (void)camera:(MyCamera *)camera_ _didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height
{
    
    if (![loadingViewPortrait isAnimating] || ![loadingViewLandscape isAnimating]) {
        return;
    }
    
	self.qualityLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Quality", @""), [camera_ getOverAllQualityString]];
	self.qualityLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
#if defined(SVIPCLOUD)
    [_qualityLabel setTextColor:HexRGB(0x3d3c3c)];
#endif
	
    [loadingViewPortrait stopAnimating];
    [loadingViewLandscape stopAnimating];
}

- (void)camera:(MyCamera *)camera_ _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount {
    
    if (camera_ == camera) {
		if( videoWidth > 1920 || videoHeight > 1080 ) {
			NSLog( @"!!!!!!!! ERROR !!!!!!!!" );
			return;
		}
        
        msizeOrgVideoResolution.width = videoWidth;
        msizeOrgVideoResolution.height = videoHeight;
		
		CGSize maxZoom = CGSizeMake((videoWidth*2.0 > 1920)?1920:videoWidth*2.0, (videoHeight*2.0 > 1080)?1080:videoHeight*2.0);
		if( glView && videoWidth > 0 && videoHeight > 0 ) {
			[self recalcMonitorRect:CGSizeMake(videoWidth, videoHeight)];
            self.glView.videoSize = CGSizeMake(videoWidth, videoHeight) ;
            self.glView.frame = self.glView.frame;
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
		
#ifndef MacGulp
		if( g_bDiagnostic ) {
			self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d / FPS: %d / BPS: %d Kbps", videoWidth, videoHeight, fps, (videoBps + audioBps) / 1024];
			self.frameInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %d / Frame ratio: %d / %d", @"Used for display channel information"), onlineNm, incompleteFrameCount, frameCount];
		}
		else {
			self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d", videoWidth, videoHeight ];
			self.frameInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %d", @""), onlineNm];
		}
#else
        
        if (onlineNm >= 5) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CAM P" message:NSLocalizedString(@"Exceed multiple viewer limitation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];

            [camera stopShow:selectedChannel];
			[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
            [camera stopSoundToDevice:selectedChannel];
            [camera stopSoundToPhone:selectedChannel];
            
            monitorPortrait.image = nil;
            monitorLandscape.image = nil;
            
            self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d @ %d fps", videoWidth, videoHeight, 0];
            self.frameInfoLabel.text = [NSString stringWithFormat:@"x%d", onlineNm];  
        }
        else {
            self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d @ %d fps", videoWidth, videoHeight, fps];
            self.frameInfoLabel.text = [NSString stringWithFormat:@"x%d", onlineNm];    
        }
#endif
		self.qualityLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Quality", @""), [camera getOverAllQualityString]];
		self.qualityLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
#if defined(SVIPCLOUD)
        [_qualityLabel setTextColor:HexRGB(0x3d3c3c)];
#endif
    }
}

- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size
{
    if (type == IOTYPE_USER_IPCAM_GET_EnParam_RESP) {
        /* do something you want */
        SMsgAVIoctrlGetEnParamResp *resp=(SMsgAVIoctrlGetEnParamResp *)data;
        memcpy(resp, data, size);
        NSLog(@"%d",resp->channel);
        
        self.qieWenDuLbl.hidden=NO;
        self.qieWenDuLbl.text=[NSString stringWithFormat:@"%@%d℃ %@%d%@",NSLocalizedString(@"WenDu", nil),resp->tempreture,NSLocalizedString(@"ShiDu", nil),resp->humidity,@"%"];
        [self.scrollViewPortrait bringSubviewToFront:self.qieWenDuLbl];
    }
    if(type==(int)IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP){
        SMsgAVIoctrlGetStreamCtrlResp* pResult=(SMsgAVIoctrlGetStreamCtrlResp*)data;
        [self initQVGAMode:pResult->quality];
//        if(pResult->quality!=[MyCamera getCameraQVGA:camera]){
////            [MyCamera loadCameraQVGA:camera];
//        }
    }
    
    if (type == (int)IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_RESP) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    
    if (type == (int)IOTYPE_USER_IPCAM_SETSTREAMCTRL_RESP) {
    
        SMsgAVIoctrlSetStreamCtrlResp* pResult=(SMsgAVIoctrlSetStreamCtrlResp*)data;
        NSLog(@"IOTYPE_USER_IPCAM_SETSTREAMCTRL_RESP result=%d",pResult->result);
        [self initQVGAMode:[MyCamera getCameraQVGA:camera]];
        [MyCamera setcameraLoadAVGA:camera.uid withIsLoad:YES];
        if (camera_==camera) {
            [loadingViewPortrait startAnimating];
            [loadingViewLandscape startAnimating];
			[camera reStartShow:selectedChannel withCompleteBlock:^(void){
				
				// UI need to forbiden User invoke reStartShow again before program runs to here!
				//
				[loadingViewPortrait stopAnimating];
				[loadingViewLandscape stopAnimating];
                
				
			}];


        }
    } else if (type == (int)IOTYPE_USER_IPCAM_SET_ENVIRONMENT_RESP) {
        SMsgAVIoctrlSetEnvironmentResp* pResult=(SMsgAVIoctrlSetEnvironmentResp*)data;
        NSLog(@"IOTYPE_USER_IPCAM_SET_ENVIRONMENT_RESP result=%d",pResult->result);
        if (camera_==camera) {
            [loadingViewPortrait startAnimating];
            [loadingViewLandscape startAnimating];
			[camera reStartShow:selectedChannel withCompleteBlock:^(void){
				
				// UI need to forbiden User invoke reStartShow again before program runs to here!
				//
				[loadingViewPortrait stopAnimating];
				[loadingViewLandscape stopAnimating];
				
			}];
            

        }

    }
    else if(type==(int)IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP){
        SMsgAVIoctrlGetEnvironmentResp* pResult=(SMsgAVIoctrlGetEnvironmentResp*)data;
        if(camera_==camera){
            emode=pResult->mode;
            [self initViewEmode];
        }
    }
    else if (type==IOTYPE_USER_IPCAM_GETPRESET_RESP){
        SMsgAVIoctrlGetPresetResp* pResult=(SMsgAVIoctrlGetPresetResp*)data;
        NSLog(@"%d",pResult->nPresetIdx);
    }
    else if(type==IOTYPE_USER_IPCAM_SETPRESET_RESP){
        SMsgAVIoctrlSetPresetResp *pResult=(SMsgAVIoctrlSetPresetResp*)data;
        if(pResult->result==0){
            NSLog(@"OK");
            [[iToast makeText:NSLocalizedString(@"Saving successful", @"")]show];
        }
        else{
            NSLog(@"ERROR");
        }
    }
    else if(type==0x224F){//IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_RESP		= 0x224F,
        SMsgAVIoctrlSetSoundResp *d=(SMsgAVIoctrlSetSoundResp*)data;
        //NSLog(@"%@",d);
    }
#pragma mark - 接收参数jays TODO：
    else if (type == (int) IOTYPE_HICHIP_GETCONTRAST_RESP)
        {
            SMgAVIoctrlGetContrastResp * d = (SMgAVIoctrlGetContrastResp *)data;
            [self initSettingFiveStatus:NSInteger(d->contrast) withpView:self.landConstrastView];
             NSLog(@"****++=:%ld",NSInteger(d->contrast));//5 4 3 
        }else if (type == (int) IOTYPE_HICHIP_GETBRIGHT_RESP)
            {
                SMgAVIoctrlGetBrightResp * d = (SMgAVIoctrlGetBrightResp *)data;
                
                [self initSettingFiveStatus:NSInteger(d->bright) withpView:self.landBrightView];
                NSLog(@"****++=:%ld",NSInteger(d->bright)); //5 4 3
            }else if (type == (int)IOTYPE_USEREX_IPCAM_SET_LED_RESP)//16401
                {
                    [loadingViewLandscape stopAnimating];
                SMsgAVIoctrlExSetLEDResp *ledRespond = (SMsgAVIoctrlExSetLEDResp *)data;
//                NSLog(@"LED 设置result:%d隐藏HUd个数%ld",ledRespond->result,(long)cout);
//                if (ledRespond->result == 0) {
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                }
                }else if (type == (int)IOTYPE_USEREX_IPCAM_GET_LED_RESP)
                    {
                        SMsgAVIoctrlExGetLEDResp * d = (SMsgAVIoctrlExGetLEDResp *)data;
                        [self initSettingFiveStatus:NSInteger(d->sSwitch) withpView:self.longInfraredView];
                    }

    
            else if (type == (int)IOTYPE_USER_IPCAM_SET_IMAGE_PARAM_RESP)//复位 32769
            {

                SMsgAVIoctrlSetImageParamResp * respond = (SMsgAVIoctrlSetImageParamResp *)data;
                NSLog(@"复位处理结果：%d",respond->result); // 0: success; otherwise: failed.
                if (respond -> result == 0) {
                    [self initSettingFiveStatus:3 withpView:self.landBrightView];
                     [self initSettingFiveStatus:3 withpView:self.landConstrastView];
                    
                }
            }
}
#pragma mark - 初始化ViewEmode选中状态
-(void)initViewEmode{
    if(emode==0){
        
        [set50Hz setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [set60Hz setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        
        [_longBtn50HZ setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_longBtn60HZ setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        
#if defined(SVIPCLOUD)
        [set50Hz setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
        [set60Hz setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
        [_longBtn50HZ setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
        [_longBtn60HZ setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
#endif
    }
    if(emode==1){
        [set60Hz setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [set50Hz setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        [_longBtn60HZ setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_longBtn50HZ setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    }
}
#pragma mark - 初始化ViewEmode选中状态
-(void)initQVGAMode:(NSInteger)tg{
    for (UIButton *b in [longQVGAView subviews]) {
        if(b.tag==0) continue;
        if(b.tag==tg){
            [b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        else{
            [b setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
#if defined(SVIPCLOUD)
            [b setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
#endif
        }
    }
    for (UIButton *b in [qvgaView subviews]) {
        if(b.tag==0) continue;
        if(b.tag==tg){
            [b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        else{
            [b setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
#if defined(SVIPCLOUD)
            [b setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
#endif
        }
    }
    self.cameraQVGANumber=tg;
}
#pragma mark - 设置对应按钮字体颜色（对比度，亮度，红外开关）
-(void)initSettingFiveStatus:(NSInteger)tg withpView:(UIView *)pview{
    for (UIButton *b in [pview subviews]) {
#ifndef CamLineProTarget
        if(b.tag==0 ) continue;
#endif
        if (b.tag == 99) continue; //just for Camline Pro  add jay
        if(b.tag==tg){
            [b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        else{
            [b setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] 
             URLsForDirectory:NSDocumentDirectory 
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - MonitorTouchDelegate Methods
- (void)monitor:(Monitor *)monitor gesturePinched:(CGFloat)scale 
{
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		
		NSLog( @"CameraLiveViewController - Pinched [Landscape] scale:%f/%f", scale, self.scrollViewLandscape.maximumZoomScale );
        //if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
		if( scale <= self.scrollViewLandscape.maximumZoomScale ) {
        	[self.scrollViewLandscape setZoomScale:scale animated:YES];
        } else {
            [self.scrollViewLandscape setContentSize:self.glView.frame.size];
            NSLog( @"glView.frame width:%f height:%f" ,self.glView.frame.size.width, self.glView.frame.size.height );
        }
        
    }
    else {
		NSLog( @"CameraLiveViewController - Pinched scale:%f/%f", scale, self.scrollViewPortrait.maximumZoomScale );
        //if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
		if( scale <= self.scrollViewPortrait.maximumZoomScale ) {
			[self.scrollViewPortrait setZoomScale:scale animated:YES];
        } else {
            [self.scrollViewPortrait setContentSize:self.glView.frame.size];
        }
    }
}


#pragma mark - ChannelPickerDelegate Methods
- (void)didChannelSelected:(NSInteger)channelIndex {
    
    isChangeChannel = YES;
    
    [self.multiStreamPopoverController dismissPopoverAnimated:YES];
    
	if( selectedChannel != channelIndex ) {
	
		[camera stopShow:selectedChannel];
		[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
		[camera stopSoundToDevice:selectedChannel];
		[camera stopSoundToPhone:selectedChannel];
        //[camera stop:selectedChannel];
        //[camera disconnect];
		
		[self unactiveAudioSession];
		
		selectedChannel = channelIndex;

        self.navigationItem.title = [NSString stringWithFormat:@"%@ - CH%d", camera.name, selectedChannel + 1];
        
        self.navigationItem.rightBarButtonItems = nil;
        
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customButton.frame = CGRectMake(0, 0, 60, 49);
        [customButton setBackgroundImage:[UIImage imageNamed:@"live_chicon_clicke" ] forState:UIControlStateNormal];
        [customButton addTarget:self action:@selector(selectChannel:) forControlEvents:UIControlEventTouchUpInside];
        [customButton setTitle:[NSString stringWithFormat:@"CH%d", selectedChannel + 1]
                      forState:UIControlStateNormal];
        customButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        customButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        customButton.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 1, 0);
        
        UIBarButtonItem *streamButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, streamButton, nil];
        [streamButton release];
        [negativeSpacer release];
        
        bIsChangeChannnel = YES;
        camera.isChangeChannel = YES;
        
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cameraStartShow:) userInfo:nil repeats:NO];
	}
}

- (void) cameraReStartShow {
    [camera startShow:selectedChannel ScreenObject:self];
    
    [loadingViewLandscape setHidden:NO];
    [loadingViewPortrait setHidden:NO];
    [loadingViewPortrait startAnimating];
    [loadingViewLandscape startAnimating];
    
    [self activeAudioSession];
    
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) [camera startSoundToPhone:selectedChannel];
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [camera startSoundToDevice:selectedChannel];
}

#pragma mark - WEPopoverControllerDelegate implementation
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	thePopoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return NO;
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
                        atScale:(CGFloat)scale
{
	if( glView ) {
		glView.frame = CGRectMake( 0, 0, scrollView.frame.size.width*scale, scrollView.frame.size.height*scale );
		NSLog( @"{0,0,%d,%d}", (int)(scrollView.frame.size.width*scale), (int)(scrollView.frame.size.height*scale) );
	}
}

#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSString *acc = @"admin";
        NSString *pwd = textField.text;
                
        if (database != NULL) {            
            if (![database executeUpdate:@"UPDATE device SET view_pwd=? WHERE dev_uid=?", pwd, camera.uid]) {
                NSLog(@"Fail to update device to database.");
            }
        }
        
        if (camera.sessionState != CONNECTION_STATE_CONNECTED)
            [camera connect:camera.uid];
		
        [camera setViewAcc:acc];
        [camera setViewPwd:pwd];
        [camera start:selectedChannel];
        [camera startShow:selectedChannel ScreenObject:self];
        
        [loadingViewLandscape setHidden:NO];
        [loadingViewPortrait setHidden:NO];
        [loadingViewPortrait startAnimating];
        [loadingViewLandscape startAnimating];
        
        [self activeAudioSession];
    }
}


#pragma mark - AudioSession implementations
- (void)activeAudioSession 
{
    
#if 0
    OSStatus error;  
    
    UInt32 category = kAudioSessionCategory_LiveAudio;
    
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        category = kAudioSessionCategory_LiveAudio; 
        NSLog(@"kAudioSessionCategory_LiveAudio");
    }
    
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE) { 
        category = kAudioSessionCategory_PlayAndRecord;
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
    }
    
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);  
    if (error) printf("couldn't set audio category!");  
    
    error = AudioSessionSetActive(true);  
    if (error) printf("AudioSessionSetActive (true) failed");
    
#else
    
    NSString *audioMode = nil;
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        NSLog(@"kAudioSessionCategory_LiveAudio");
        audioMode = AVAudioSessionCategoryPlayback;
    }
    
    else if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {;
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
        audioMode = AVAudioSessionCategoryPlayAndRecord;
    }
    
    if ( nil == audioMode){
        return ;
    }
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:audioMode error:&error];
    
    if (!success)  NSLog(@"AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:&error];
    if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"AVAudioSession error activating: %@",error);
    else NSLog(@"audioSession active");
    
    
#endif
}

- (void)unactiveAudioSession {
    
#if 0
    AudioSessionSetActive(false);
#else
    BOOL success;
    NSError* error;
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //activate the audio session
    success = [session setActive:NO error:&error];
    if (!success) NSLog(@"AVAudioSession error deactivating: %@",error);
    else NSLog(@"audioSession deactive");
    
#endif
}

#pragma mark - UIApplication Delegate
- (void)applicationWillResignActive:(NSNotification *)notification
{
    [camera stopShow:selectedChannel];
	[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
    [camera stopSoundToDevice:selectedChannel];
    [camera stopSoundToPhone:selectedChannel];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [camera startShow:selectedChannel ScreenObject:self];
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE)
        [camera startSoundToDevice:selectedChannel];
    if (selectedAudioMode == AUDIO_MODE_SPEAKER)
        [camera startSoundToPhone:selectedChannel];
}

- (void)updateToScreen:(NSValue*)pointer
{
    LPSIMAGEBUFFINFO pScreenBmpStore = (LPSIMAGEBUFFINFO)[pointer pointerValue];
    
    //	[glView renderVideo:pScreenBmpStore->pixelBuff];
    
    int width = (int)CVPixelBufferGetWidth(pScreenBmpStore->pixelBuff);
    int height = (int)CVPixelBufferGetHeight(pScreenBmpStore->pixelBuff);
    mSizePixelBuffer = CGSizeMake( width, height );
#ifndef DEF_Using_APLEAGLView
    [glView renderVideo:pScreenBmpStore->pixelBuff];
#else
    self.test.presentationRect = mSizePixelBuffer;
    [[self test] displayPixelBuffer:pScreenBmpStore->pixelBuff withRelease:FALSE];
#endif
}

- (void)recalcMonitorRect:(CGSize)videoframe
{
	CGFloat fRatioFrame = videoframe.width / videoframe.height;
	CGFloat fRatioMonitor;
	UIScrollView* viewMonitor;
	UIView* viewCanvas;
	
    if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		
        CGRect screenRect = [[UIScreen mainScreen] bounds];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ) {
			CGFloat fTmp = screenRect.size.height;
			screenRect.size.height = screenRect.size.width;
			screenRect.size.width = fTmp;
		}
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        screenRect.size.height =screenWidth ;
        screenRect.size.width = screenHeight;
        self.scrollViewLandscape.frame = screenRect;
        //self.scrollViewLandscape.contentSize=self.scrollViewLandscape.frame.size;
        self.monitorLandscape.frame = screenRect;
        
        viewMonitor = self.scrollViewLandscape;
		viewCanvas = self.monitorLandscape;
        
        //公版
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
//        CGFloat screenHeight = screenRect.size.height;
//        
//        screenRect.size.height =screenWidth ;
//        screenRect.size.width = screenHeight;
//        self.scrollViewLandscape.frame = screenRect;
//        self.monitorLandscape.frame = screenRect;
	}
	else {
		viewMonitor = self.scrollViewPortrait;
		viewCanvas = self.monitorPortrait;
	}
    //self.scrollViewPortrait.contentSize=self.scrollViewPortrait.frame.size;
	fRatioMonitor = viewMonitor.frame.size.width/viewMonitor.frame.size.height;
		
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if( fRatioMonitor > fRatioFrame) {
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
    }
    else{
        if( fRatioMonitor < fRatioFrame) {
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
    }
	
	if( self.glView ) {
        self.glView.parentFrame = viewCanvas.frame;
		//self.glView.frame = viewCanvas.frame;
		//NSLog( @"GLView scale:%.1f/%.1f {%d,%d}%dx%d/%dx%d", viewMonitor.zoomScale, viewMonitor.maximumZoomScale, (int)self.glView.frame.origin.x, (int)self.glView.frame.origin.y, (int)self.glView.frame.size.width, (int)self.glView.frame.size.height, (int)viewMonitor.frame.size.width, (int)viewMonitor.frame.size.height);
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
    
    CGSize size = self.glView.frame.size;
    CGFloat fScale  = [[UIScreen mainScreen] scale];
    size.height *= fScale;
    size.width *= fScale;
    *pglFrameSize_Scaling = size ;
    
    static CGFloat s_nLastFrameWidth = 0;
    static CGFloat s_nLastFrameHeight = 0;
    if( s_nLastFrameWidth != size.width || s_nLastFrameHeight != size.height ) {
        
        s_nLastFrameWidth = size.width;
        s_nLastFrameHeight = size.height;
    }
    
    //公版
//    CGSize size = self.glView.frame.size;
//    float fScale  = [[UIScreen mainScreen] scale];
//    size.height *= fScale;
//    size.width *= fScale;
//    *pglFrameSize_Scaling = size ;
//    
//    
//    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        [self.scrollViewLandscape setContentSize:self.glView.frame.size];
//    }
//    else {
//        [self.scrollViewPortrait setContentSize:self.glView.frame.size];
//    }
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
			NSLog( @"CameraLiveViewController - waitStopShowCompleted !!!TIMEOUT!!!" );
            [NSThread sleepForTimeInterval:4];
            [camera startShow:selectedChannel ScreenObject:self];
			break;
		}
	}
}

- (void)cameraStopShowCompleted:(NSNotification *)notification
{
	bStopShowCompletedLock = TRUE;
}

- (void)cameraStartShow:(NSTimer*)theTimer
{
    [camera connect:camera.uid];
    [camera start:selectedChannel];
    
	[camera startShow:selectedChannel ScreenObject:self];
	
	[loadingViewLandscape setHidden:NO];
	[loadingViewPortrait setHidden:NO];
	[loadingViewPortrait startAnimating];
	[loadingViewLandscape startAnimating];
	
	[self activeAudioSession];
	
	if (selectedAudioMode == AUDIO_MODE_SPEAKER) [camera startSoundToPhone:selectedChannel];
	if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [camera startSoundToDevice:selectedChannel];
}


- (IBAction)onPlaySwitcher:(id)sender {
	
	UIButton* btn = (UIButton*)sender;
	
	BOOL bValue = [btn isSelected];
	
	if( bValue ) {
		if (camera != nil) {
			
			[camera startShow:selectedChannel ScreenObject:self];
						
			[self activeAudioSession];
			
			if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
				[camera startSoundToPhone:selectedChannel];
			}
			
			if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
				[camera startSoundToDevice:selectedChannel];
			}
		}
	}
	else {
		if (camera != nil) {
			[camera stopShow:selectedChannel];
			[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
			[camera stopSoundToDevice:selectedChannel];
			[camera stopSoundToPhone:selectedChannel];
			
			[self unactiveAudioSession];
			
		}
	}
	
	[btnPlaySwitcher_Portrait setSelected:!bValue];
	[btnPlaySwitcher_Landscpae setSelected:!bValue];
	
}

#pragma mark - EditCameraDefaultDelegate Methods
- (void)didRemoveDevice:(MyCamera *)removedCamera {
    
    [camera stopSoundToDevice:selectedChannel];
    [camera stopSoundToPhone:selectedChannel];

    [self unactiveAudioSession];

    [self.delegate didRemoveDevice:camera];
    
    camera = nil;
    camera.delegate2 = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark HorizMenu Data Source
- (NSString*) selectedItemImageForMenu:(MKHorizMenu*) tabMenu itemAtIndex:(NSUInteger)index
{
    return [self.selectItems objectAtIndex:index];
}

- (UIColor*) backgroundColorForMenu:(MKHorizMenu *)tabView
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bk"]];
}

- (int) numberOfItemsForMenu:(MKHorizMenu *)tabView
{
#if defined(BayitCam)
    return [self.items count];
#endif
#if defined(MoveDF)
    return [self.items count]-2;
#endif
#if defined(EasynPTarget) || defined(IPCAMP) || defined(QTAIDT) || defined(MAJESTICIPCAMP) || defined(CamLineProTarget)
    return [self.items count];
#else
    return [self.items count]-2;
#endif
}

- (NSString*) horizMenu:(MKHorizMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    return [self.items objectAtIndex:index];
}

#pragma mark -
#pragma mark HorizMenu Delegate
-(void) horizMenu:(MKHorizMenu *)horizMenu itemTouchDownAtIndex:(NSUInteger)index{
    NSInteger offsetCount=0;
    
#if defined(CamLineProTarget) //jay add
    if (isLandscape) {
        index += LANDSCAPE_GAP  ;
    }
     if (index == RESTRORE) //15
    {
        NSLog(@"复位！！！！");
        //发送复位命令
        SMsgAVIoctrlSetImageParamReq *s = (SMsgAVIoctrlSetImageParamReq *)malloc(sizeof(SMsgAVIoctrlSetImageParamReq));
        memset(s , 0, sizeof(SMsgAVIoctrlSetImageParamReq));
        s->todefault = 1 ;/*value : if set !0 ,image to default value*/
        [camera sendIOCtrlToChannel:0
                               Type:IOTYPE_USER_IPCAM_SET_IMAGE_PARAM_REQ
                               Data:(char *)s
                           DataSize:sizeof(SMsgAVIoctrlSetImageParamReq)];
    }
#endif
    
#if defined(MAJESTICIPCAMP)
#else
    if(index==8-offsetCount){
        [self myPtzAction:AVIOCTRL_LENS_ZOOM_IN];
        //[self.horizMenu setSelectedIndex:8 animated:YES];
        //[self.longHorizMenu setSelectedIndex:8 animated:YES];
        
        //[self.horizMenu setUnselectedIndex:8 animated:YES];
        //[self.longHorizMenu setUnselectedIndex:8 animated:YES];
    }
    else if(index==9-offsetCount){
        [self myPtzAction:AVIOCTRL_LENS_ZOOM_OUT];
        //[self.horizMenu setSelectedIndex:9 animated:YES];
        //[self.longHorizMenu setSelectedIndex:9 animated:YES];
        
        //[self.horizMenu setUnselectedIndex:9 animated:YES];
        //[self.longHorizMenu setUnselectedIndex:9 animated:YES];
    }
#endif
}
-(void) horizMenu:(MKHorizMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    selectIdex = index ;
#if defined(CamLineProTarget)//jay add
    if (isLandscape) {
        index += LANDSCAPE_GAP + 1 ;
    }
#endif
    NSLog(@"按了第%ld按钮",index);
    //1.隐藏其他按钮
    self.prePositionView.hidden=YES;
    self.myPtzView.hidden=NO;
    
    NSInteger offsetCount=0;
    talkButton.hidden = YES;
    scrollQVGAView.hidden = YES;
    scrollEModeView.hidden = YES;
    
    self.portraitBrightScrollView.hidden=YES;
    self.portraitConstrastScrollView.hidden=YES;
    self.landBrightView.hidden=YES;
    self.landConstrastView.hidden=YES;
    self.longInfraredView.hidden = YES; //add for camline pro
    longTalkButton.hidden = YES;
    longQVGAView.hidden = YES;
    longEModeView.hidden = YES;
    //
    isActive = YES;
    
#if defined(BayitCam)
    if(index==3){
        index=7;
    }
    else if(index>=4)
    {
        index=index-1;
    }
#else
#if defined(MAJESTICIPCAMP)
#else
    if(index!=3){
        isPrePosition=NO;
    }
    if(index==3){
        if(!isRecording){
            if(isPrePosition){
                self.prePositionView.hidden=YES;
                self.myPtzView.hidden=NO;
                isPrePosition=NO;
                
                [self.horizMenu setUnselectedIndex:3 animated:YES];
                [self.longHorizMenu setUnselectedIndex:3 animated:YES];
            }
            else{
                self.prePositionView.hidden=NO;
                self.myPtzView.hidden=YES;
                isPrePosition=YES;
                
                [self.horizMenu setSelectedIndex:3 animated:YES];
                [self.longHorizMenu setUnselectedIndex:3 animated:YES];
                
            }
        }
        return;
    }
    if(index>=4){
        index=index-1;
    }
#endif
#endif
    if(index==9-offsetCount){

    }
    else if(index==10-offsetCount)
    {

    }
    else if(index==7-offsetCount){
        
#if defined(BayitCam)
        if(!isRecording){
            if(isPrePosition){
                self.prePositionView.hidden=YES;
                self.myPtzView.hidden=NO;
                isPrePosition=NO;
            }
            else{
                self.prePositionView.hidden=NO;
                self.myPtzView.hidden=YES;
                isPrePosition=YES;
            }
        }
        return;
#endif
        
#if defined(MAJESTICIPCAMP)
        if(isBright){
            isBright=NO;
            isActive=NO;
        }
        else{
            self.portraitBrightScrollView.hidden=NO;
            self.landBrightView.hidden=NO;
            //[self.horizMenu setUnselectedIndex:7 animated:YES];
            //[self.longHorizMenu setUnselectedIndex:7 animated:YES];
            isBright=YES;
            
            isContrast=NO;
            isQVGAView=NO;
            isEModeView=NO;
        }
#else
        isActive=NO;
        [self stopPT];
        [self.horizMenu setUnselectedIndex:8 animated:YES];
        [self.longHorizMenu setUnselectedIndex:8 animated:YES];
#endif
    }
    else if(index==8-offsetCount){
#if defined(MAJESTICIPCAMP)
        if(isContrast){
            isContrast=NO;
            isActive=NO;
        }
        else{
            self.portraitConstrastScrollView.hidden=NO;
            self.landConstrastView.hidden=NO;
            //[self.horizMenu setUnselectedIndex:8 animated:YES];
            //[self.longHorizMenu setUnselectedIndex:8 animated:YES];
            isContrast=YES;
            
            isBright=NO;
            isQVGAView=NO;
            isEModeView=NO;
        }
#else
        isActive=NO;
        [self stopPT];
        [self.horizMenu setUnselectedIndex:9 animated:YES];
        [self.longHorizMenu setUnselectedIndex:9 animated:YES];
#endif
    }
    else if (index == SOUND_CONTROL && !isRecording) {
        
        if (isListening==NO && isTalking==NO){

            isQVGAView = NO;
            isEModeView = NO;
            self.isCanSendSetCameraCMD=NO;
            
            selectedAudioMode = AUDIO_MODE_SPEAKER;
            [self activeAudioSession];
            [camera startSoundToPhone:selectedChannel];
            
            talkButton.hidden = NO;
            longTalkButton.hidden = NO;
            
            isListening = YES;
            
            self.myPtzView.hidden=YES;
            
            [self.horizMenu setSelectedIndex:SOUND_CONTROL animated:YES];
            [self.longHorizMenu setSelectedIndex:SOUND_CONTROL animated:YES];
            
        } else if (isListening==YES && isTalking==NO){
            
            selectedAudioMode = AUDIO_MODE_OFF;
            [camera stopSoundToPhone:selectedChannel];
            [self unactiveAudioSession];
            
            isListening = NO;
            isActive = NO;
            
            self.myPtzView.hidden=NO;
            self.isCanSendSetCameraCMD=YES;
            
            [self.horizMenu setUnselectedIndex:SOUND_CONTROL animated:YES];
            [self.longHorizMenu setUnselectedIndex:SOUND_CONTROL animated:YES];
        }
        
    } else if (index == RECORDING) {
    
        isQVGAView = NO;
        isEModeView = NO;
        isActive = NO;
        
        isListening = NO;
        selectedAudioMode = AUDIO_MODE_OFF;
        [camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];

        [self onBtnRecording];
        
    } else if (index == SNAPSHOT-offsetCount  && !isRecording) {

        isQVGAView = NO;
        isEModeView = NO;
        isActive = NO;
        
        isListening = NO;
        selectedAudioMode = AUDIO_MODE_OFF;
        [camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];
        
        [self snapshot:nil];
        
        [self.horizMenu setUnselectedIndex:SNAPSHOT animated:YES];
        [self.longHorizMenu setUnselectedIndex:SNAPSHOT animated:YES];
        
    } else if (index == MIRROR_UP_DOWN-offsetCount  && !isRecording) {
        
        [self.horizMenu reloadData];
        [self.longHorizMenu reloadData];
        
        isListening = NO;
        selectedAudioMode = AUDIO_MODE_OFF;
        [camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];

        isQVGAView = NO;
        isEModeView = NO;
        isActive = NO;
        
        if (isVerticalFlip == NO) {
            
            SMsgAVIoctrlSetVideoModeReq *s = (SMsgAVIoctrlSetVideoModeReq *)malloc(sizeof(SMsgAVIoctrlSetVideoModeReq));
            memset(s, 0, sizeof(SMsgAVIoctrlSetVideoModeReq));
            
            s->channel = 0;
            s->mode = isHorizontalFlip?3:1;
            
            [camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ
                                   Data:(char *)s
                               DataSize:sizeof(SMsgAVIoctrlSetVideoModeReq)];
            
            free(s);
            
            isVerticalFlip = YES;
            //isHorizontalFlip = NO;
            
        } else {
            
            SMsgAVIoctrlSetVideoModeReq *s = (SMsgAVIoctrlSetVideoModeReq *)malloc(sizeof(SMsgAVIoctrlSetVideoModeReq));
            memset(s, 0, sizeof(SMsgAVIoctrlSetVideoModeReq));
            
            s->channel = 0;
            s->mode = isHorizontalFlip?2:0;
            
            [camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ
                                   Data:(char *)s
                               DataSize:sizeof(SMsgAVIoctrlSetVideoModeReq)];
            
            free(s);
            
            isVerticalFlip = NO;
        }
        
    } else if (index == MIRROR_LEFT_RIGHT-offsetCount && !isRecording) {
        
        [self.horizMenu reloadData];
        [self.longHorizMenu reloadData];
        
        isListening = NO;
        selectedAudioMode = AUDIO_MODE_OFF;
        [camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];

        isQVGAView = NO;
        isEModeView = NO;
        isActive = NO;
        
        if (isHorizontalFlip == NO) {
            
            SMsgAVIoctrlSetVideoModeReq *s = (SMsgAVIoctrlSetVideoModeReq *)malloc(sizeof(SMsgAVIoctrlSetVideoModeReq));
            memset(s, 0, sizeof(SMsgAVIoctrlSetVideoModeReq));
            
            s->channel = 0;
            s->mode = isVerticalFlip?3:2;
            
            [camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ
                                   Data:(char *)s
                               DataSize:sizeof(SMsgAVIoctrlSetVideoModeReq)];
            
            free(s);
            
            isHorizontalFlip = YES;
            //isVerticalFlip = NO;
            
        } else {
            
            SMsgAVIoctrlSetVideoModeReq *s = (SMsgAVIoctrlSetVideoModeReq *)malloc(sizeof(SMsgAVIoctrlSetVideoModeReq));
            memset(s, 0, sizeof(SMsgAVIoctrlSetVideoModeReq));
            
            s->channel = 0;
            s->mode = isVerticalFlip?1:0;
            
            [camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ
                                   Data:(char *)s
                               DataSize:sizeof(SMsgAVIoctrlSetVideoModeReq)];
            
            free(s);
            
            isHorizontalFlip = NO;
        }
        
//    } else if (index == GO_CAMERA_SET) {
//        [self onBtnSetCamera];
//        
//        [self.horizMenu setUnselectedIndex:4 animated:YES];
    } else if (index == QVGA-offsetCount && !isRecording) {
        
        if (isQVGAView == NO) {
            isListening = NO;
            selectedAudioMode = AUDIO_MODE_OFF;
            [camera stopSoundToPhone:selectedChannel];
            [self unactiveAudioSession];

            isEModeView = NO;
            
            scrollQVGAView.hidden = NO;
            longQVGAView.hidden = NO;
            isQVGAView = YES;
            
            isContrast=NO;
            isBright=NO;
            isEModeView=NO;

        } else {
            
            isQVGAView = NO;
            isActive = NO;
        }
        
        
    } else if (index == EMODE-offsetCount && !isRecording) {
        
        if (isEModeView == NO) {
            isListening = NO;
            selectedAudioMode = AUDIO_MODE_OFF;
            [camera stopSoundToPhone:selectedChannel];
            [self unactiveAudioSession];
            
            isQVGAView = NO;
            
            scrollEModeView.hidden = NO;
            longEModeView.hidden = NO;
            isEModeView = YES;
            
            isQVGAView=NO;
            isContrast=NO;
            isBright=NO;
            
        } else {
            
            isEModeView = NO;
            isActive = NO;
            if (isLandscape){
                self.hideToolBarTimer = [self setupHideToolBarTimer];
            }
        }
    }
#pragma mark add for Camline Pro landscape
    /***** add by jay ******/
   else if (index == CONTRAST) //12 landscape
        {
#if defined(CamLineProTarget)
            if(isContrast){
                isContrast=NO;
                isActive=NO;
            }
            else{
               // self.portraitConstrastScrollView.hidden=NO; //modif by jay
                self.landConstrastView.hidden=NO;
                //[self.horizMenu setUnselectedIndex:8 animated:YES];
                //[self.longHorizMenu setUnselectedIndex:8 animated:YES];
                isContrast=YES;
                isBright=NO;
                isInfrared = NO ;
                isQVGAView=NO;
                isEModeView=NO;
            }
#endif
        
        }else if (index == BRIGHT) //13
            {
#if defined(CamLineProTarget)
                if(isBright){
                    isBright=NO;
                    isActive=NO;
                }
                else{
                    //self.portraitBrightScrollView.hidden=NO;
                    self.landBrightView.hidden=NO;
                    //[self.horizMenu setUnselectedIndex:7 animated:YES];
                    //[self.longHorizMenu setUnselectedIndex:7 animated:YES];
                    isBright=YES;
                    
                    isContrast=NO;
                    isInfrared = NO ;
                    isQVGAView=NO;
                    isEModeView=NO;
                }
#endif
            }else if (index == INFRARED) //14
                {
#if defined(CamLineProTarget)
                    
                    if(isInfrared){
                        isInfrared=NO;
                        isActive=NO;
                    }
                    else{
                        //self.portraitBrightScrollView.hidden=NO;
                        self.longInfraredView.hidden=NO;
                        //[self.horizMenu setUnselectedIndex:7 animated:YES];
                        //[self.longHorizMenu setUnselectedIndex:7 animated:YES];
                        isInfrared=YES;
                        
                        isContrast=NO;
                        isBright = NO;
                        isQVGAView=NO;
                        isEModeView=NO;
                    }
#endif

        
                }else if (index == RESTRORE)
                {
                    isContrast = NO;
                    isBright = NO ;
                    isInfrared = NO ;
                    [self.longHorizMenu setUnselectedIndex: 3 animated:YES];
                }


}
#pragma mark - 转到竖屏时设置按钮的状态
- (void)checkBTN {
    if (isListening) {
        [self.horizMenu setSelectedIndex:SOUND_CONTROL animated:YES];
    } else {
        [self.horizMenu setUnselectedIndex:SOUND_CONTROL animated:YES];
    }
    
    if (isQVGAView) {
        [self.horizMenu setSelectedIndex:QVGA animated:YES];
    } else {
        [self.horizMenu setUnselectedIndex:QVGA animated:YES];
    }
    
    if (isEModeView) {
        [self.horizMenu setSelectedIndex:EMODE animated:YES];
    } else {
        [self.horizMenu setUnselectedIndex:EMODE animated:YES];
    }
    //
   
}
#pragma mark - 转到横屏时设置按钮的状态
- (void)checkLongBTN {
    if (isListening) {
        [self.longHorizMenu setSelectedIndex:SOUND_CONTROL animated:YES];
    } else {
        [self.longHorizMenu setUnselectedIndex:SOUND_CONTROL animated:YES];
    }
    
    if (isQVGAView) {
        [self.longHorizMenu setSelectedIndex:QVGA animated:YES];
    } else {
        [self.longHorizMenu setUnselectedIndex:QVGA animated:YES];
    }
    
    if (isEModeView) {
        [self.longHorizMenu setSelectedIndex:EMODE animated:YES];
    } else {
        [self.longHorizMenu setUnselectedIndex:EMODE animated:YES];
    }
    if (!isContrast) {
        [self.longHorizMenu setUnselectedIndex:0 animated:YES];
    }
    if (!isBright) {
        [self.longHorizMenu setUnselectedIndex:1 animated:YES];
    }
    if (isInfrared == NO) {
        [self.longHorizMenu setUnselectedIndex:2 animated:YES];
    }
}

#pragma mark Rotate Delegate 屏幕旋转2
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
#ifdef CamLineProTarget
//    isListening = NO;
//    isTalking = NO ;
    isEModeView = NO;
    isQVGAView = NO;
    isRecording = NO;
    isContrast = NO;
    isBright= NO ;
    isInfrared = NO ;
#endif
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        //畫面傾置
        isLandscape = YES;
#ifndef CamLineProTarget
        if (isActive == NO) {
            self.longHorizMenu.hidden = YES;
            [self checkLongBTN];
            
        } else {
            self.longHorizMenu.hidden = NO;
            [self checkLongBTN];
        }
#else
        isActive = NO;
        //talkButton.hidden = YES;
        longTalkButton.hidden = YES;
        longQVGAView.hidden = YES;
        longEModeView.hidden = YES;
        self.landConstrastView.hidden = YES;
        self.landBrightView.hidden = YES;
        self.prePositionView.hidden=YES;
        
        self.longInfraredView.hidden = YES;
         //self.portraitView.hidden = YES;
        self.longHorizMenu.hidden = YES;
        [self checkLongBTN];

#endif
    }
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //畫面直立
        isLandscape = NO;
        self.longHorizMenu.hidden = YES;
        //self.portraitView.hidden = NO ; //add jay
        [self checkBTN];
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if (isActive == NO) {
        // Disable scroll
        UIScrollView *_scrollView = (UIScrollView *)gestureRecognizer.view;
        [_scrollView setScrollEnabled:NO];
        

        
        // Re-enable scroll after navigation hidden.
        double delayInSeconds = UINavigationControllerHideShowBarDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_scrollView setScrollEnabled:YES];
        });
        
        [self.hideToolBarTimer invalidate];
        self.hideToolBarTimer = nil;
        
        BOOL hidden = self.longHorizMenu.hidden;
        isHiddenTopNav=!hidden;
        
        [self.longHorizMenu setHidden:!hidden];
        
#if defined(QIEAPP)
        hidden=self.qieLandActionView.hidden;
        self.qieLandActionView.hidden=!hidden;
        self.qieWenDuLbl.hidden=!hidden;
        isHiddenTopNav=!hidden;
#endif
        
        [[UIApplication sharedApplication] setStatusBarHidden:isHiddenTopNav withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:isHiddenTopNav animated:YES];
        
        if (hidden) {
            self.hideToolBarTimer = [self setupHideToolBarTimer];
        }
    }
#if defined(QIEAPP)
    self.longHorizMenu.hidden=YES;
#endif
}

#define HIDE_TOOL_BAR_TIME_OUT	5

- (NSTimer *)setupHideToolBarTimer {
	return [NSTimer scheduledTimerWithTimeInterval:HIDE_TOOL_BAR_TIME_OUT target:self selector:@selector(hideToolBar) userInfo:nil repeats:NO];
}

- (void)hideToolBar {
	if (self.longHorizMenu.hidden == NO && isActive == NO) {
        [self.longHorizMenu setHidden:YES];
        isHiddenTopNav=YES;
        self.qieLandActionView.hidden=YES;
        self.qieWenDuLbl.hidden=YES;
        [[UIApplication sharedApplication] setStatusBarHidden:isHiddenTopNav withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:isHiddenTopNav animated:YES];
	}
}

- (IBAction)myPtzDownAction:(id)sender {
    [self myPtzAction:AVIOCTRL_PTZ_DOWN];
}
- (IBAction)myPtzUpAction:(id)sender {
    [self myPtzAction:AVIOCTRL_PTZ_UP];
}
- (IBAction)myPtzLeftAction:(id)sender {
    [self myPtzAction:AVIOCTRL_PTZ_LEFT];
}
- (IBAction)myPtzRightAction:(id)sender {
    [self myPtzAction:AVIOCTRL_PTZ_RIGHT];
}
-(void)myPtzAction:(ENUM_PTZCMD)cmd{
    SMsgAVIoctrlPtzCmd *request = (SMsgAVIoctrlPtzCmd *)malloc(sizeof(SMsgAVIoctrlPtzCmd));
    request->channel = 0;
    request->control = cmd;
    request->speed = PT_SPEED;
    request->point = 0;
    request->limit = 0;
    request->aux = 0;
    
#if defined(EasynPTarget)
    if(cmd==AVIOCTRL_LENS_ZOOM_IN||cmd==AVIOCTRL_LENS_ZOOM_OUT){
        request->reserve[1]=10;
    }
#endif
    
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_PTZ_COMMAND Data:(char *)request DataSize:sizeof(SMsgAVIoctrlPtzCmd)];
    
    free(request);
    if(cmd==AVIOCTRL_LENS_ZOOM_IN||cmd==AVIOCTRL_LENS_ZOOM_OUT){
#ifndef EasynPTarget
        [self performSelector:@selector(stopPT) withObject:nil afterDelay:0.1];
#endif
    }
    else{
        [self performSelector:@selector(stopPT) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)landBackAction:(id)sender {
}
#pragma mark - 发送对比度
- (IBAction)onContrastClicked:(id)sender {
    SMsgAVIoctrlSetContrastReq *s = (SMsgAVIoctrlSetContrastReq *)malloc(sizeof(SMsgAVIoctrlSetContrastReq));
    memset(s, 0, sizeof(SMsgAVIoctrlSetContrastReq));
    
    s->channel = 0;
    s->contrast = [(UIView*)sender tag];
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_HICHIP_SETCONTRAST_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlSetContrastReq)];
    
    
    
    self.landConstrastView.hidden=YES;
    self.portraitConstrastScrollView.hidden=YES;
    
    isContrast=NO;
    
    [self.horizMenu reloadData];
    [self.longHorizMenu reloadData];
    
    //
    [self initSettingFiveStatus:s->contrast withpView:self.portraitContrastView];
    [self initSettingFiveStatus:s->contrast withpView:self.landConstrastView];
    
    free(s);
    
}
#pragma mark - 设置ptz亮度
- (IBAction)onBrightClicked:(id)sender {
    SMsgAVIoctrlSetBrightReq *s = (SMsgAVIoctrlSetBrightReq *)malloc(sizeof(SMsgAVIoctrlSetBrightReq));
    memset(s, 0, sizeof(SMsgAVIoctrlSetBrightReq));
    
    s->channel = 0;
    s->bright = [(UIView*)sender tag];
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_HICHIP_SETBRIGHT_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlSetBrightReq)];
    
    
    
    self.landBrightView.hidden=YES;
    self.portraitBrightScrollView.hidden=YES;
    
    isBright=NO;
    //[self.horizMenu reloadData];
    [self.longHorizMenu reloadData];
//设置对应按钮字体颜色
    [self initSettingFiveStatus:s->bright withpView:self.landBrightView];
    [self initSettingFiveStatus:s->bright withpView:self.portraitBrightView];
    
    free(s);
}
#pragma mark - 设置ptz红外开关
- (IBAction)onlongInfraredClicked:(id)sender {
    //1.发送命令
    SMsgAVIoctrlExSetLEDReq *s = (SMsgAVIoctrlExSetLEDReq *)malloc(sizeof(SMsgAVIoctrlExSetLEDReq));
    memset(s , 0, sizeof(SMsgAVIoctrlExSetLEDReq));
    s->sSwitch = int([(UIView *)sender tag]);/*0:auto 1:open  2:close*/
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USEREX_IPCAM_SET_LED_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlExSetLEDReq)];
    
    
    //2.设置对应的UI
    self.longInfraredView.hidden = YES;
    isInfrared = NO;
    [self.horizMenu reloadData];
    [self.longHorizMenu reloadData];
    //设置对应按钮字体颜色
    [self initSettingFiveStatus:[(UIView*)sender tag] withpView:self.longInfraredView];
    
    free(s);
    
}

- (IBAction)preAction:(UIButton *)sender {
    NSInteger index=sender.tag;
    SMsgAVIoctrlGetPresetReq *s = (SMsgAVIoctrlGetPresetReq *)malloc(sizeof(SMsgAVIoctrlGetPresetReq));
    memset(s, 0, sizeof(SMsgAVIoctrlGetPresetReq));
    
    s->channel = 0;
    s->nPresetIdx=(int)index;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETPRESET_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlGetPresetReq)];
    free(s);
    /*for (UIButton *btn in preBtnArr) {
        btn.selected=NO;
        if(btn.tag==sender.tag){
            btn.selected=YES;
        }
    }*/
}
-(void)preBtnLongTouch1:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer state] != UIGestureRecognizerStateBegan){
        return;
    }
    [self setPreAction:0];
}
-(void)preBtnLongTouch2:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer state] != UIGestureRecognizerStateBegan){
        return;
    }
    [self setPreAction:1];
}
-(void)preBtnLongTouch3:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer state] != UIGestureRecognizerStateBegan){
        return;
    }
    [self setPreAction:2];
}
-(void)preBtnLongTouch4:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer state] != UIGestureRecognizerStateBegan){
        return;
    }
    [self setPreAction:3];
}
-(void)setPreAction:(NSInteger)index{
    SMsgAVIoctrlSetPresetReq *s = (SMsgAVIoctrlSetPresetReq *)malloc(sizeof(SMsgAVIoctrlSetPresetReq));
    memset(s, 0, sizeof(SMsgAVIoctrlSetPresetReq));
    
    s->channel = 0;
    s->nPresetIdx=(int)index;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_SETPRESET_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlSetPresetReq)];
    free(s);
    
    /*for (UIButton *btn in preBtnArr) {
        btn.selected=NO;
        if(btn.tag==index){
            btn.selected=YES;
        }
    }*/
}
<<<<<<< HEAD

=======
- (IBAction)qieSnapshot:(id)sender {
    self.qieWenDuLbl.hidden=YES;
    [self snapshot:sender];
}
- (IBAction)qiemonito:(id)sender {
    self.qieWenDuLbl.hidden=YES;
    if(isTalking){
        [camera stopSoundToDevice:selectedChannel];
        isTalking = NO;
    }
    if (isListening==NO && isTalking==NO){
        
        isQVGAView = NO;
        isEModeView = NO;
        self.isCanSendSetCameraCMD=NO;
        
        selectedAudioMode = AUDIO_MODE_SPEAKER;
        [self activeAudioSession];
        [camera startSoundToPhone:selectedChannel];
        
        
        isListening = YES;
        
        self.qieMonitorBtn.selected=YES;
        self.qiePhoneBtn.selected=NO;
        
        self.qieLandMonitorBtn.selected=YES;
        self.qieLandPhoneBtn.selected=NO;
        
    } else if (isListening==YES && isTalking==NO){
        
        selectedAudioMode = AUDIO_MODE_OFF;
        [camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];
        
        isListening = NO;
        isActive = NO;
        
        self.isCanSendSetCameraCMD=YES;
        self.qieMonitorBtn.selected=NO;
        self.qieLandMonitorBtn.selected=NO;
        
    }
}
- (IBAction)qieWendu:(id)sender {
    SMsgAVIoctrlGetEnParamReq *s2 = (SMsgAVIoctrlGetEnParamReq *)malloc(sizeof(SMsgAVIoctrlGetEnParamReq));
    s2->channel=0;
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_EnParam_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetEnParamReq)];
    free(s2);
    if(wenDuLblTimer){
        if([wenDuLblTimer isValid]){
            [wenDuLblTimer invalidate];
        }
        [wenDuLblTimer release];
        wenDuLblTimer  =nil;
    }
    wenDuLblTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(hiddenWenDuLabl) userInfo:nil repeats:NO];
    [wenDuLblTimer retain];
}
-(void)hiddenWenDuLabl{
    self.qieWenDuLbl.hidden=YES;
}
- (IBAction)qieVideo:(id)sender {
    self.qieWenDuLbl.hidden=YES;
    isQVGAView = NO;
    isEModeView = NO;
    isActive = NO;
    
    isListening = NO;
    selectedAudioMode = AUDIO_MODE_OFF;
    [camera stopSoundToPhone:selectedChannel];
    [self unactiveAudioSession];
    
    [self onBtnRecording];
}
- (IBAction)qieHuaZhi:(id)sender {
    self.qieWenDuLbl.hidden=YES;
    UIActionSheet *sheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:NSLocalizedString(@"高清",nil)  otherButtonTitles:NSLocalizedString(@"标清",nil),NSLocalizedString(@"流畅",nil)  , nil];
    
    
    NSInteger i=self.cameraQVGANumber;
    
    if(self.cameraQVGANumber>0){
        if(self.cameraQVGANumber%2==0){
            i=self.cameraQVGANumber-1;
        }
    }
    
    if(i==1){
        sheet.destructiveButtonIndex=0;
    }
    else if(i==3)
    {
        sheet.destructiveButtonIndex=1;
    }
    else if(i==5){
        sheet.destructiveButtonIndex=2;
    }
    
    [sheet showInView:self.view];
    [sheet release];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSInteger i=buttonIndex;
    if(buttonIndex==0){
        i=1;
    }
    else if(buttonIndex==1)
    {
        i=3;
    }
    else if(buttonIndex==2){
        i=5;
    }
    else{
        return;
    }
    [self onBtnSetQVGA1:i];
    self.cameraQVGANumber=i;
}
- (IBAction)qiePhone:(id)sender {
    self.qieWenDuLbl.hidden=YES;
    if(!isTalking){
        if(!self.isTalkButtonAction)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
            
            SMsgAVIoctrlTimeZone s3={0};
            s3.cbSize = sizeof(s3);
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
            self.isTalkButtonAction=YES;
        }
        
        isTalking = YES;
        isListening=NO;
        selectedAudioMode = AUDIO_MODE_MICROPHONE;
        [camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];
        [self activeAudioSession];
        [camera startSoundToDevice:selectedChannel];
        self.qieMonitorBtn.selected=NO;
        self.qiePhoneBtn.selected=YES;
        
        self.qieLandMonitorBtn.selected=NO;
        self.qieLandPhoneBtn.selected=YES;
    }
    else{
        [camera stopSoundToDevice:selectedChannel];
        isTalking = NO;
        
        selectedAudioMode = AUDIO_MODE_SPEAKER;
        [self unactiveAudioSession];
        self.qiePhoneBtn.selected=NO;
        self.qieLandPhoneBtn.selected=NO;
    }
}
#pragma mark --构建切换界面
-(void)initSwipView{
    if(swipCameraPopView) return;
    swipCameraBtns=[[NSMutableArray alloc]init];
    
    swipCameraPopView=[[UIView alloc]init];
    swipCameraPopView.hidden=YES;
    [self.view addSubview:swipCameraPopView];
    
    //120*27
    NSInteger marginW=10;
    swipCameraPopView.frame=CGRectMake(self.view.frame.size.width-(120+marginW*2), 0, 120+marginW*2, marginW*2+[camera_list count]*27+10);
    UIImageView *bgImagevIew=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-box.png"]];
    [swipCameraPopView addSubview:bgImagevIew];
    [bgImagevIew release];
    bgImagevIew.frame=swipCameraPopView.bounds;
    
    UIButton *lastBtn=nil;
    NSInteger i=0;
    for (MyCamera *ca in camera_list) {
        UIButton *btn=[[UIButton alloc]init];
        [swipCameraPopView addSubview:btn];
        [swipCameraBtns addObject:btn];
        [btn release];
        if(lastBtn){
            btn.frame=CGRectMake(marginW, lastBtn.frame.origin.y+27+marginW, 120, 27);
        }
        else{
            btn.frame=CGRectMake(marginW, marginW, 120, 27);
        }
        btn.tag=i;
        i++;
        [btn addTarget:self action:@selector(selectCameraAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"camera_list_background.png"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"camera_list_background.png"] forState:UIControlStateHighlighted];
        [btn setTitle:ca.uid forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if([ca.uid isEqualToString:self.camera.uid]){
            btn.selected=YES;
        }
        lastBtn=btn;
    }
    lastBtn=nil;
}
-(void)selectCameraAction:(UIButton *)btn{
    
    swipCameraPopView.hidden=YES;
    
    MyCamera *ca=[camera_list objectAtIndex:btn.tag];
    for (UIButton *b in swipCameraBtns) {
        b.selected=NO;
        if(b.tag==btn.tag){
            b.selected=YES;
        }
    }
    if([self.camera.uid isEqualToString:ca.uid]) return;
    
    
    
    self.camera.delegate2=nil;
    [self.camera stopShow_block:0];
    [self.camera stopSoundToDevice:0];
    [self.camera stopSoundToPhone:0];
    [self.camera release];
    
    self.camera=ca;
    //开始
    if (camera != nil) {
        
        
        camera.delegate2 = self;
        
        if (camera.sessionState != CONNECTION_STATE_CONNECTED)
            [camera connect:camera.uid];
        
        if ([camera getConnectionStateOfChannel:0] != CONNECTION_STATE_CONNECTED) {
            [camera start:0];
            
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
            
            SMsgAVIoctrlTimeZone s3={0};
            s3.cbSize = sizeof(s3);
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
        }
        
        if ( selectedChannel != 0 && [camera getConnectionStateOfChannel:selectedChannel] != CONNECTION_STATE_CONNECTED) {
            [camera start:selectedChannel];
        }
        
        [camera startShow:selectedChannel ScreenObject:self];
        
        SMsgAVIoctrlSetSoundReq *quality = (SMsgAVIoctrlSetSoundReq*)malloc(sizeof(SMsgAVIoctrlSetSoundReq));
        memset(quality, 0, sizeof(SMsgAVIoctrlSetSoundReq));
        quality->SoundIn=95;
        quality->SoundOut=95;
        [camera sendIOCtrlToChannel:0
                               Type:0x224E
                               Data:(char *)quality
                           DataSize:sizeof(SMsgAVIoctrlSetSoundReq)];
        
        free(quality);
        [loadingViewLandscape setHidden:NO];
        [loadingViewPortrait setHidden:NO];
        [loadingViewPortrait startAnimating];
        [loadingViewLandscape startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(loadCameraQVGAStatus) userInfo:nil repeats:NO];
        [self activeAudioSession];
    }
}
>>>>>>> 5d317abc7f51115e806da5ad5442697d0702c42a
@end

@implementation UINavigationController (autorotation)

-(BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end

