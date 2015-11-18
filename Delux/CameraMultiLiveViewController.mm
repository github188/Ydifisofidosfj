//
//  CameraMultiLiveViewController.m
//  IOTCamViewer
//
//  Created by tutk on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import <IOTCamera/GLog.h>
#import <IOTCamera/GLogZone.h>
#import "CameraMultiLiveViewController.h"
#import "PhotoTableViewController.h"
#import "iToast.h"
#import <IOTCamera/AVFRAMEINFO.h>
#import <IOTCamera/ImageBuffInfo.h>
#import <sys/time.h>
#import <AVFoundation/AVFoundation.h>
#import "EventListController.h"
#import "AppDelegate.h"
#import "AppInfoController.h"
#import "StartViewController.h"
#import "cCustomNavigationController.h"
#import "AppGuidViewController.h"

#if defined(BayitCam)
#import "BayitCamViewController.h"
#endif

#if defined(IDHDCONTROL)
#import "AccountInfo.h"
#import "HttpTool.h"
#endif

#ifndef P2PCAMLIVE
#define SHOW_SESSION_MODE
#endif
#define DEF_WAIT4STOPSHOW_TIME	250
#define DEF_SplitViewNum		4
#define DEF_ReTryConnectInterval 25*1000
#define DEF_ReTryTimes			10

extern unsigned int _getTickCount() ;

@interface CameraMultiLiveViewController() {
	MyCamera* mDummyCam;
	
	NSMutableArray* marrBtn_Default;
	NSMutableArray* marrImg_Vdo;
	NSMutableArray* marrBtn_ReConnt;
	NSMutableArray* marrImg_Connt;
	NSMutableArray* marrLabel_Status;
	NSMutableArray* marrBtn_MoreFunc;
	NSMutableArray* marrLabel_Name;
	int mnReTryTimesArray[DEF_SplitViewNum];
	unsigned int mnLastReTryTickArray[DEF_SplitViewNum];
}

@end

@implementation CameraMultiLiveViewController

@synthesize bStopShowCompletedLock;
@synthesize mCodecId;
@synthesize glView;
@synthesize mPixelBufferPool;
@synthesize mPixelBuffer;
@synthesize mSizePixelBuffer;
@synthesize connModeImageView;
@synthesize selectedAudioMode;
@synthesize camNeedReconnect;
@synthesize directoryPath;
@synthesize selectCameraArray;
@synthesize cameraArray;
@synthesize channelArray;
@synthesize moreFunctionTag;

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
    
    [imgData writeToFile:imgFullName atomically:YES];   
}

- (NSString *)directoryPath {
    
	if (!directoryPath) {
        
		//directoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Library"];
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directoryPath = [[dirs objectAtIndex:0] retain];
    }
    
	return [directoryPath stringByAppendingPathComponent:NOTBACKUPDIR];
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}
-(void)alertInfo:(NSString *)message withTitle:(NSString *)title{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}
#if defined(IDHDCONTROL)
-(void)loadDeviceFromServer{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic=@{@"id":[NSString stringWithFormat:@"%ld",(long)[AccountInfo getUserId]]};
    HttpTool *httpTool=[HttpTool shareInstance];
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=getUuid" parameters:dic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        if(code==1){
            [self alertInfo:msg withTitle:@"提示"];
        }
        else{
            //解析列表
            NSMutableArray *arr=responseObject[@"list"];
            for (NSInteger j=0; j<[arr count]; j++) {
                NSString *uuid=arr[j][@"uuid"];
                //UnBox
                NSArray *uuidArr=[MyCamera unBoxUUID:uuid];
                
                NSString *uid = [uuidArr objectAtIndex:0];
                NSString *name = [uuidArr objectAtIndex:3];
                NSString *view_acc = @"admin";
                NSString *view_pwd = [uuidArr objectAtIndex:1];
                NSInteger channel = 0;
                NSInteger isSync = NO;
                NSInteger isFromCloud = NO;
                NSLog(@"Load Camera(%@, %@, %@, %@, %d, ch:%d)", name, uid, view_acc, view_pwd, (int)isFromCloud, (int)channel);
                
                MyCamera *tempCamera = [[MyCamera alloc] initWithName:name viewAccount:view_acc viewPassword:view_pwd];
                [tempCamera setLastChannel:channel];
                [tempCamera connect:uid];
                [tempCamera setSync:isSync];
                [tempCamera setCloud:isFromCloud];
                [tempCamera start:0];
                
                
                //[tempCamera startShow:channel ScreenObject:self];
                
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
                
                SMsgAVIoctrlSetStreamCtrlReq *ss = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
                memset(ss, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
                
                ss->channel = 0;
                ss->quality = AVIOCTRL_QUALITY_MIN;
                [tempCamera sendIOCtrlToChannel:0
                                           Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                                           Data:(char *)ss
                                       DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
                free(ss);
            }
            [self checkStatus];
            [self reStartShow];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        [self alertInfo:error.localizedDescription withTitle:@"提示"];
    }];
}
#endif
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
            
            
            //[tempCamera startShow:channel ScreenObject:self];
            
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
            
            //[MyCamera loadCameraQVGA:tempCamera];
			
            [camera_list addObject:tempCamera];
            [tempCamera release];
            
#if defined(Aztech)
#else
            
            SMsgAVIoctrlSetStreamCtrlReq *ss = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
            memset(ss, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
            
            ss->channel = 0;
            ss->quality = AVIOCTRL_QUALITY_MIN;
            [tempCamera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                                   Data:(char *)ss
                               DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
            free(ss);
#endif
        }
        
        [rs close];
    }
}

- (void)camStopShow:(int)aIgnoreIdx {
    
    isCamStopShow = YES;
    
    for (int i=0;i<DEF_SplitViewNum;i++){
		
		if(i == aIgnoreIdx) {
			GLog( tUI, (@"---------------------"));
			GLog( tUI, (@"-- Ignore index:%02d --", i) );
			GLog( tUI, (@"---------------------"));
			continue;
		}
		
        MyCamera *testCamera = [cameraArray objectAtIndex:i];
        
        if (testCamera.uid != nil && ![testCamera.uid isEqualToString:@"(null)"]){
            
            NSNumber *tempChannel = [channelArray objectAtIndex:i];
            
            if (testCamera.sessionState == CONNECTION_STATE_CONNECTED && [testCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
                testCamera.isShowInMultiView=NO;
                [testCamera stopShow:[tempChannel intValue]];
            }
        }
    }
	
	for( UIImageView* img in marrImg_Vdo ) {
		img.image = nil;
	}
}

- (void)reStartShow {
    
    isCamStopShow = NO;
    
    for (int i=0;i<DEF_SplitViewNum;i++){
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid != nil && ![tempCamera.uid isEqualToString:@"(null)"]){
            
            NSNumber *tempChannel = [channelArray objectAtIndex:i];
            
            if (tempCamera.sessionState == CONNECTION_STATE_CONNECTED && [tempCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
                if(!isGoPlayEvent){
                    tempCamera.isShowInMultiView = YES;
                    [tempCamera startShow:[tempChannel integerValue] ScreenObject:self];
                }
            }
        }
    }
}

- (void)reConnectAndShow {
    for (int i=0;i<DEF_SplitViewNum;i++){
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid != nil && ![tempCamera.uid isEqualToString:@"(null)"]){
            
            [channelArray objectAtIndex:i];
            
            [self disconnectCamera:tempCamera.uid];
			[tempCamera disconnect];
            
            [tempCamera connect:tempCamera.uid];
            [tempCamera start:0];
            
	if(!isGoPlayEvent){
            tempCamera.isShowInMultiView = YES;
            //[tempCamera startShow:0 ScreenObject:self];
	}
            tempCamera.delegate2 = self;
        }
    }
}

- (void)hideMoreSet {
    
    isMoreSetOpen = !isMoreSetOpen;
    
    moreSet.hidden = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (isMoreSetOpen) {
        [button setBackgroundImage:[UIImage imageNamed:@"moreset_clicked"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"moreset"] forState:UIControlStateHighlighted];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"moreset"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"moreset_clicked"] forState:UIControlStateHighlighted];
    }
    button.frame=CGRectMake(0.0, 0.0, 44.0, 44.0);
    [button addTarget:self action:@selector(showMoreSet) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *moreSetButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, moreSetButton, nil];
    [moreSetButton release];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch =  [touches anyObject];
    if (isMoreSetOpen && [touch.view isKindOfClass:moreSet.class]){
        
        [self hideMoreSet];
    }
}

- (void)showMoreSet {
    
    [self hideMoreFunctionView:nil];
    
    isMoreSetOpen = !isMoreSetOpen;
    
    moreSet.hidden = !moreSet.hidden;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (isMoreSetOpen) {
        [button setBackgroundImage:[UIImage imageNamed:@"moreset_clicked"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"moreset"] forState:UIControlStateHighlighted];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"moreset"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"moreset_clicked"] forState:UIControlStateHighlighted];
    }
    button.frame=CGRectMake(0.0, 0.0, 44.0, 44.0);
    [button addTarget:self action:@selector(showMoreSet) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *moreSetButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, moreSetButton, nil];
    [moreSetButton release];
    
}

#pragma mark Functions of buttons
- (IBAction)goDropboxRec:(id)sender {
    NSInteger tag=0;
    for (NSInteger i=0; i<[cameraArray count]; i++) {
        MyCamera *ca=[cameraArray objectAtIndex:i];
        if(ca.uid==nil){
            tag=i;
            break;
        }
    }
    
    dropboxRec.tag=tag;
    [self camStopShow:-1];
    [self goAddCamera:sender];
    
    return;
    [self camStopShow];
    
}

- (IBAction)goInfo:(id)sender {
    
	[self camStopShow:-1];
	
    AppInfoController *controller = [[AppInfoController alloc]  initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)logOut:(id)sender {
    
    [self hideMoreSet];
    
    AppGuidViewController *appInfo=[[AppGuidViewController alloc]initWithNibName:@"AppGuidViewController" bundle:nil];
    [self.navigationController pushViewController:appInfo animated:YES];
    [appInfo release];
    
    return;
    
    if ([logInOut.titleLabel.text isEqualToString:NSLocalizedString(@"Log out",@"")]) {
        NSString *msg = NSLocalizedString(@"Once you log out, the devices will no longer sync with your cloud account. You can tick “Sync with your cloud account” in the device “Settings” page after next login. Are you sure to log out?", @"");
        NSString *caution = NSLocalizedString(@"Caution!", @"");
        NSString *ok = NSLocalizedString(@"OK", @"");
        NSString *cancel = NSLocalizedString(@"Cancel", @"");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:caution message:msg delegate:self cancelButtonTitle:cancel otherButtonTitles:ok,nil];
        [alert show];
        [alert release];
        
        isLogOut = YES;
        
    } else {
        NSString *msg = NSLocalizedString(@"Are you sure to log in?", @"");
        NSString *caution = NSLocalizedString(@"Caution!", @"");
        NSString *ok = NSLocalizedString(@"OK", @"");
        NSString *cancel = NSLocalizedString(@"Cancel", @"");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:caution message:msg delegate:self cancelButtonTitle:cancel otherButtonTitles:ok,nil];
        [alert show];
        [alert release];
        
        isLogOut = NO;
    }
}

- (IBAction)goAddCamera:(id)sender {
    if(moreFunCViewIsOpen) return;

	mnViewTag = (int)[(UIView*)sender tag];
	GLog( tUI, (@"+++CameraMultiLiveViewController - goLiveView: [%d]", mnViewTag));
	
	[self camStopShow:-1];
	
    CameraListForLiveViewController *controller = [[CameraListForLiveViewController alloc] initWithNibName:@"CameraList" bundle:nil];
    
	controller.viewTag = [NSNumber numberWithInt:mnViewTag];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    [self hideMoreFunctionView:nil];
}

- (void)disconnectCamera:(NSString*)strUID {
	for( int i=0 ; i<DEF_SplitViewNum ; i++ ) {
		MyCamera *cam = [cameraArray objectAtIndex:i];
		NSNumber *numChannel = [channelArray objectAtIndex:i];
		
		if( [cam.uid isEqualToString:strUID] ) {
			[cam stop:[numChannel intValue]];
		}
	}
}

- (IBAction)reConnect:(id)sender {
    
    MyCamera *tempCamera = [cameraArray objectAtIndex:[(UIView*)sender tag]];
    NSNumber *tempChannel = [channelArray objectAtIndex:[(UIView*)sender tag]];

	if( tempCamera.uid != nil && ![tempCamera.uid isEqualToString:@"(null)"] ) {
		[self disconnectCamera:tempCamera.uid];
		[tempCamera disconnect];
		
		[tempCamera connect:tempCamera.uid];
		[tempCamera start:[tempChannel intValue]];
		
		//[tempCamera startShow:[tempChannel intValue] ScreenObject:self];
		tempCamera.delegate2 = self;
	}
}

- (IBAction)moreFunction:(id)sender {
    
    moreFunCViewIsOpen=YES;
    
    moreFunctionTag = [NSNumber numberWithInt:(int)[(UIView*)sender tag]];
    [moreFunctionView setHidden:NO];
    
    CGAffineTransform newTransform = CGAffineTransformScale(moreFunctionView.transform, 0.1, 0.1);
    [moreFunctionView setTransform:newTransform];
    
    [self performSelector:@selector(bigAnimation)];
}

- (void)bigAnimation {
    
    [UIView beginAnimations:@"imageViewBig" context:nil];
    [UIView setAnimationDuration:0.2];
    [moreFunctionView setAlpha:1.0];
    CGAffineTransform newTransform = CGAffineTransformConcat(moreFunctionView.transform,  CGAffineTransformInvert(moreFunctionView.transform));
    [moreFunctionView setTransform:newTransform];
    [UIView commitAnimations];
    
    [self performSelector:@selector(smallAnimation) withObject:nil afterDelay:0.2];
}

- (void)bigAnimation2 {
    
    
    [UIView beginAnimations:@"imageViewBig" context:nil];
    [UIView setAnimationDuration:0.1];
    CGAffineTransform newTransform = CGAffineTransformConcat(moreFunctionView.transform,  CGAffineTransformInvert(moreFunctionView.transform));
    [moreFunctionView setTransform:newTransform];
    [UIView commitAnimations];
}

- (void)smallAnimation {
    
    [UIView beginAnimations:@"imageViewSmall" context:nil];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform newTransform2 =  CGAffineTransformScale(moreFunctionView.transform, 0.9, 0.9);
    [moreFunctionView setTransform:newTransform2];
    [UIView commitAnimations];
    
    [self performSelector:@selector(bigAnimation2) withObject:nil afterDelay:0.2];
}

- (IBAction)hideMoreFunctionView:(id)sender {
    moreFunCViewIsOpen=NO;
    [UIView beginAnimations:@"imageViewSmall" context:nil];
    [UIView setAnimationDuration:0.2];
    [moreFunctionView setAlpha:0.0];
    CGAffineTransform newTransform =  CGAffineTransformScale(moreFunctionView.transform, 1.0, 1.0);
    [moreFunctionView setTransform:newTransform];
    [UIView commitAnimations];
    
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:0.2];
}

- (void)hideAnimation{
    
    moreFunctionView.hidden = YES;
}


- (IBAction)goLiveView:(id)sender {
    if(moreFunCViewIsOpen) return;

	int nIdx = (int)[(UIView*)sender tag];

	MyCamera *tempCamera = [cameraArray objectAtIndex:nIdx];
	if( tempCamera.uid != nil && ![tempCamera.uid isEqualToString:@"(null)"]) {
		int channel = (int)[[channelArray objectAtIndex:nIdx] intValue];
		
		GLog( tUI, (@"+++CameraMultiLiveViewController - goLiveView [%d] UID:%@ ch:%d", nIdx, tempCamera.uid, channel) );
		
		[self camStopShow:nIdx];
		
		UIImageView* vdoXX = [marrImg_Vdo objectAtIndex:nIdx];
		if( vdoXX ) {
			vdoXX.image = nil;
		}
		
		CameraLiveViewController *controller = [[CameraLiveViewController alloc] initWithNibName:@"CameraLiveView" bundle:nil];
		controller.camera = tempCamera;
		controller.viewTag = [NSNumber numberWithInt:(int)[(UIView*)sender tag]];
		controller.delegate = self;
		controller.selectedChannel = channel;
		
		UINavigationController *customNavController = [[cCustomNavigationController alloc] init];
		[self presentViewController:customNavController animated:YES completion:nil];
		[customNavController pushViewController:controller animated:YES];
		
		[controller release];
		[customNavController release];
		
	}
	else {
		GLog( tUI, (@"+++CameraMultiLiveViewController - goLiveView [%d] !!!Ignore!!!", nIdx) );
	}
    [self hideMoreFunctionView:nil];
}

- (IBAction)changeViewSetting:(id)sender {
	GLog( tUI, (@"+++CameraMultiLiveViewController - changeViewSetting: [%d]", [moreFunctionTag intValue]));
	[self camStopShow:-1];
	
    CameraListForLiveViewController *controller = [[CameraListForLiveViewController alloc] initWithNibName:@"CameraList" bundle:nil];
    controller.viewTag = moreFunctionTag;
    controller.delegate = self;
    controller->isFromChange = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    [self hideMoreFunctionView:nil];
}

- (IBAction)goEventList:(id)sender {
	GLog( tUI, (@"+++CameraMultiLiveViewController - goEventList: [%d]", [moreFunctionTag intValue]));
	isGoPlayEvent=YES;
	[self camStopShow:-1];
	
    EventListController *controller = [[EventListController alloc] initWithStyle:UITableViewStylePlain];
    NSLog(@"TAG:%@",moreFunctionTag);
    MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag intValue]];
    controller.camera = cameraIdx;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    [self hideMoreFunctionView:nil];
}

- (IBAction)goSnapshot:(id)sender {
	GLog( tUI, (@"+++CameraMultiLiveViewController - goSnapshot: [%d]", [moreFunctionTag intValue]));
	[self camStopShow:-1];
	
    MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag intValue]];
    int channel = [[channelArray objectAtIndex:[moreFunctionTag intValue]] intValue];
    
    PhotoTableViewController *photoTable = [[PhotoTableViewController alloc] init];
    photoTable.title = NSLocalizedString(@"Snapshot", @"");
    photoTable.camera = cameraIdx;
    photoTable.directoryPath = self.directoryPath;
    [photoTable filterImage:channel];
    photoTable.hidesBottomBarWhenPushed = YES;
    
    UINavigationController *customNavController = [[cCustomNavigationController alloc] init];
    [self presentViewController:customNavController animated:YES completion:nil];
    [customNavController pushViewController:photoTable animated:YES];
    [photoTable release];
	[customNavController release];
    
    [self hideMoreFunctionView:nil];
}

- (IBAction)goSetting:(id)sender {
	GLog( tUI, (@"+++CameraMultiLiveViewController - goSetting: [%d]", [moreFunctionTag intValue]));
	[self camStopShow:-1];
	
    [self hideMoreFunctionView:nil];
    
    MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag intValue]];
    
    EditCameraDefaultController *controller = [[EditCameraDefaultController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.camera = cameraIdx;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)deleteViewSetting:(id)sender {
	GLog( tUI, (@"+++CameraMultiLiveViewController - deleteViewSetting: [%d]", [moreFunctionTag intValue]));
    isDelete = YES;
    
#if defined(BayitCam)
    NSString *msg = NSLocalizedStringFromTable(@"Are you sure you want to remove this camera?",@"bayitcam", @"");
#else
    NSString *msg = NSLocalizedString(@"Sure to remove this view?", @"");
#endif
    NSString *no = NSLocalizedString(@"NO", @"");
    NSString *yes = NSLocalizedString(@"YES", @"");
    NSString *caution = NSLocalizedString(@"Caution!", @"");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:caution message:msg delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
    [alert show];
    [alert release];
}

#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	GLog( tUI, (@"+++CameraMultiLiveViewController - {UIAlertViewDelegate}alertView:@%p clickedButtonAtIndex:%d [%d]", alertView, (int)buttonIndex, [moreFunctionTag intValue]));

	if (buttonIndex == 0) {
        isDelete = NO;
        isLogOut = NO;
    } else if (buttonIndex == 1 && isDelete) {
        
        isDelete = NO;
        
        MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag intValue]];
        
        int checkRepeat = 0;
        
        for (int i=0;i<DEF_SplitViewNum;i++) {
            
            MyCamera *tempCamera = [cameraArray objectAtIndex:i];
            
            if (tempCamera.uid != nil && [cameraIdx.uid isEqualToString:tempCamera.uid] && [channelArray objectAtIndex:[moreFunctionTag intValue]]==[channelArray objectAtIndex:i]) {
                checkRepeat++;
            }
        }
        
		if( mDummyCam == nil ) {
			mDummyCam = [[MyCamera alloc] init];
		}
        MyCamera *defaultCamera = mDummyCam;
        NSNumber *defaultChannel = [NSNumber numberWithInt:-1];
        
        if (checkRepeat==1){
            [cameraIdx stopShow:[[channelArray objectAtIndex:[moreFunctionTag intValue]] intValue]];
            [cameraIdx ipcamStop:[[channelArray objectAtIndex:[moreFunctionTag intValue]] intValue]];
        }
        
        [cameraArray replaceObjectAtIndex:[moreFunctionTag intValue] withObject:defaultCamera];
        [channelArray replaceObjectAtIndex:[moreFunctionTag intValue] withObject:defaultChannel];
        
		UIImageView* vdoXX = [marrImg_Vdo objectAtIndex:[moreFunctionTag intValue]];
		if( vdoXX ) {
			vdoXX.image = nil;
		}
		UIButton* reConnectBTNXX = [marrBtn_ReConnt objectAtIndex:[moreFunctionTag intValue]];
		if( reConnectBTNXX ) {
			reConnectBTNXX.hidden = YES;
		}
		
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //將資料回步回手機
		GLog( tUI|tUserDefaults, (@"\"CameraMultiSetting_%d\" <== %@", [moreFunctionTag intValue], mDummyCam.uid ) );
		[userDefaults setObject:((mDummyCam.uid != nil)?mDummyCam.uid:@"(null)") forKey:[NSString stringWithFormat:@"CameraMultiSetting_%d",[moreFunctionTag intValue]]];
		
		GLog( tUI|tUserDefaults, (@"\"ChannelMultiSetting_%d\" <== -1", [moreFunctionTag intValue] ) );
        [userDefaults setInteger:-1 forKey:[NSString stringWithFormat:@"ChannelMultiSetting_%d",[moreFunctionTag intValue]]];
		
		[userDefaults synchronize];
        
        [self checkStatus];
        
        [self hideMoreFunctionView:nil];
    }

    else if (buttonIndex == 1 && isLogOut) {
        
        for (MyCamera *tempCam in cameraArray) {
            
            [tempCam setSync:0];
            
            if (database != NULL) {
                if (![database executeUpdate:@"UPDATE device SET sync=? WHERE dev_uid=?", [NSNumber numberWithBool:NO], tempCam.uid]) {
                    NSLog(@"Fail to update device to database.");
                }
            }
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"" forKey:@"cloudUserPassword"];
        [userDefaults synchronize];
        
        NSString *msg = NSLocalizedString(@"Log out success!", @"");
        NSString *ok = NSLocalizedString(@"OK", @"");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [logInOut setTitle:NSLocalizedString(@"用户手册",@"") forState:UIControlStateNormal];
        
        isLogOut = NO;
    
    } else if (buttonIndex == 1 && !isLogOut) {
        
        StartViewController *controller = [[StartViewController alloc] initWithNibName:@"StartView" bundle:nil];
        controller->isFromMCV = YES;
        [self.navigationController pushViewController:controller animated:YES];
		[controller release];
    }
}

#pragma mark - View lifecycle
- (void)dealloc
{
	[marrBtn_Default release];
	[marrImg_Vdo release];
	[marrBtn_ReConnt release];
	[marrImg_Connt release];
	[marrLabel_Status release];
	[marrBtn_MoreFunc release];
	[marrLabel_Name release];

	[mDummyCam release];
    [connModeImageView release];
    [directoryPath release];
	
	for(UIImageView* img in marrImg_Vdo) {
		[img release];
	}

    [_itemBgImgView1 release];
    [_itemBgImgView2 release];
    [_itemBgImgView3 release];
    [_itemBgImgView4 release];
    [_morecancel release];
    [_setupVideoBtn release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
//设置功能键位置
    //居中
    moreFunctionView.size=CGSizeMake(self.view.frame.size.width, self.view.frame.size.width*110/320);
    moreFunctionView.frame=CGRectMake(self.view.frame.size.width/2-moreFunctionView.frame.size.width/2, self.view.frame.size.height/2-moreFunctionView.frame.size.height/2, moreFunctionView.frame.size.width, moreFunctionView.frame.size.height);
    self.morecancel.origin=CGPointMake(moreFunctionView.size.width-self.morecancel.size.width, 0);
    CGFloat moreBtnW,moreBtnH;
    moreBtnH=moreBtnW=moreFunctionView.size.height/2.5;
    if(moreBtnW>100){
        moreBtnW=moreBtnH=100;
    }
    CGFloat marginW=(moreFunctionView.size.width-moreBtnW*5)/6;
    changeView.frame=CGRectMake(marginW, moreFunctionView.frame.size.height/2-moreBtnH/2, moreBtnW, moreBtnH);
    cameraEvent.frame=CGRectMake(changeView.frame.origin.x+moreBtnW+marginW, changeView.frame.origin.y, moreBtnW, moreBtnH);
    cameraSnapshot.frame=CGRectMake(cameraEvent.frame.origin.x+moreBtnW+marginW, cameraEvent.frame.origin.y, moreBtnW, moreBtnH);
    cameraSetting.frame=CGRectMake(cameraSnapshot.frame.origin.x+moreBtnW+marginW, cameraSnapshot.frame.origin.y, moreBtnW, moreBtnH);
    deleteView.frame=CGRectMake(cameraSetting.frame.origin.x+moreBtnW+marginW, cameraSetting.frame.origin.y, moreBtnW, moreBtnH);
    /******动态布局B******/
    CGFloat itemMarginW=2;
    CGFloat itemW=(self.view.frame.size.width-itemMarginW)/2;
    CGFloat itemH=itemW/4*3;
    CGFloat itemStatusH=20;
    CGFloat itemAllShowW=self.view.frame.size.width;
    CGFloat itemAllShowH=(itemH+itemStatusH)*2;
    
    self.vdo1.frame=CGRectMake(0, self.view.frame.size.height/2-itemAllShowH/2+self.view.frame.origin.y, itemW, itemH);
    statusBar1.frame=CGRectMake(0, self.vdo1.frame.origin.y+self.vdo1.frame.size.height, itemW, itemStatusH);
    self.vdo2.frame=CGRectMake(self.vdo1.frame.origin.x+itemMarginW+itemW, self.vdo1.frame.origin.y, itemW, itemH);
    statusBar2.frame=CGRectMake(statusBar1.frame.origin.x+itemW+itemMarginW, statusBar1.frame.origin.y, itemW, itemStatusH);
    self.vdo3.frame=CGRectMake(0, statusBar1.frame.origin.y+itemStatusH, itemW, itemH);
    statusBar3.frame=CGRectMake(0, self.vdo3.frame.origin.y+itemH, itemW, itemStatusH);
    self.vdo4.frame=CGRectMake(self.vdo3.frame.origin.x+itemW+itemMarginW, self.vdo3.frame.origin.y, itemW, itemH);
    statusBar4.frame=CGRectMake(statusBar3.frame.origin.x+itemW+itemMarginW, statusBar3.frame.origin.y, itemW, itemStatusH);
    
    cameraStatus1.frame=CGRectMake(statusBar1.frame.size.width-cameraStatus1.frame.size.width, 0, cameraStatus1.frame.size.width, statusBar1.frame.size.height);
    
    
    fullScreenButton1.frame=self.vdo1.frame;
    fullScreenButton2.frame=self.vdo2.frame;
    fullScreenButton3.frame=self.vdo3.frame;
    fullScreenButton4.frame=self.vdo4.frame;
    defaultButton1.frame=self.vdo1.frame;
    defaultButton2.frame=self.vdo2.frame;
    defaultButton3.frame=self.vdo3.frame;
    defaultButton4.frame=self.vdo4.frame;
    reConnectBTN1.frame=self.vdo1.frame;
    reConnectBTN2.frame=self.vdo2.frame;
    reConnectBTN3.frame=self.vdo3.frame;
    reConnectBTN4.frame=self.vdo4.frame;
    
    moreFunction1.frame=CGRectMake(self.vdo1.frame.origin.x+self.vdo1.frame.size.width-moreFunction1.frame.size.width, self.vdo1.frame.origin.y+5, moreFunction1.frame.size.width, moreFunction1.frame.size.height);
    moreFunction2.frame=CGRectMake(self.vdo2.frame.origin.x+self.vdo2.frame.size.width-moreFunction2.frame.size.width, self.vdo2.frame.origin.y+5, moreFunction2.frame.size.width, moreFunction2.frame.size.height);
    moreFunction3.frame=CGRectMake(self.vdo3.frame.origin.x+self.vdo3.frame.size.width-moreFunction3.frame.size.width, self.vdo3.frame.origin.y+5, moreFunction3.frame.size.width, moreFunction3.frame.size.height);
    moreFunction4.frame=CGRectMake(self.vdo4.frame.origin.x+self.vdo4.frame.size.width-moreFunction4.frame.size.width, self.vdo4.frame.origin.y+5, moreFunction4.frame.size.width, moreFunction4.frame.size.height);
    self.itemBgImgView1.frame=self.vdo1.frame;
    self.itemBgImgView2.frame=self.vdo2.frame;
    self.itemBgImgView3.frame=self.vdo3.frame;
    self.itemBgImgView4.frame=self.vdo4.frame;
    /******动态布局N******/
    

	GLog( tUI, (@"MultiView: +viewWillAppear") );
	
	if( 0<= mnViewTag && mnViewTag < DEF_SplitViewNum) {
		MyCamera* tempCamera = [cameraArray objectAtIndex:mnViewTag];
		NSNumber* tempChannel = [channelArray objectAtIndex:mnViewTag];
		if( tempCamera.sessionState == CONNECTION_STATE_CONNECTED && [tempCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED ) {
			//[tempCamera connect:tempCamera.uid];
			//[tempCamera start:[tempChannel intValue]];
			[tempCamera startShow:[tempChannel intValue] ScreenObject:self];
			tempCamera.delegate2 = self;
			
			[self camera:tempCamera _didChangeSessionStatus:CONNECTION_STATE_CONNECTED];
		}
	}
	
    if(isGoPlayEvent){
        isGoPlayEvent=NO;
    }
    if (isCamStopShow) {
        [self reStartShow];
    }
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
    
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_logo"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
    
    if (cameraArray!=nil){
        for ( MyCamera *tempCamera in cameraArray){
            tempCamera.delegate2 = self;
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]||[userDefaults objectForKey:@"cloudUserPassword"]==nil){
        [logInOut setTitle:NSLocalizedString(@"用户手册", @"") forState:UIControlStateNormal];
    } else {
        [logInOut setTitle:NSLocalizedString(@"Log out", @"") forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reConnectAndShow) name:@"WiFiChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:kApplicationDidEnterBackground object:nil];
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Re try connection mechanism
	//
	memset( mnLastReTryTickArray, 0, sizeof(mnLastReTryTickArray) );
	memset( mnReTryTimesArray, 0, sizeof(mnReTryTimesArray) );
	mTimerStartShowRevoke = [NSTimer scheduledTimerWithTimeInterval:3.6 target:self selector:@selector(onTimerStartShowRevoke:) userInfo:nil repeats:YES];
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	GLog( tUI, (@"MultiView: -viewWillAppear") );
}

- (void)checkStatus {
    
	GLog( tUI, (@"+++CameraMultiLiveViewController - checkStatus"));
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if( mDummyCam == nil ) {
		mDummyCam = [[MyCamera alloc] init];
	}
	MyCamera *defaultCam = mDummyCam;
    NSNumber *defaultChannel = [NSNumber numberWithInt:-1];
	
	if( cameraArray ) {
		[cameraArray release];
	}
	if( channelArray ) {
		[channelArray release];
	}
    cameraArray = [[NSMutableArray alloc] init];
    channelArray = [[NSMutableArray alloc] init];
    
    for (int i=0;i<DEF_SplitViewNum;i++) {
		NSString* strUid = (NSString*)[userDefaults objectForKey:[NSString stringWithFormat:@"CameraMultiSetting_%d",i]];
		GLog( tUI|tUserDefaults, (@"\"CameraMultiSetting_%d\" ==> %@", i, strUid ) );
        if (strUid != nil && ![strUid isEqualToString:@"(null)"]) {
            
			BOOL bHasAdd = FALSE;
			
            for (MyCamera *tempCamera in camera_list) {
				
                if ([tempCamera.uid isEqualToString:strUid]){
                    [cameraArray addObject:tempCamera];
					
					bHasAdd = TRUE;
                    break;
                }
            }
            
            if (!bHasAdd) {
                [cameraArray addObject:defaultCam];
            }
        } else {
            [cameraArray addObject:defaultCam];
        }
		
		NSNumber* numSelChannel = [userDefaults objectForKey:[NSString stringWithFormat:@"ChannelMultiSetting_%d",i]];
		GLog( tUI|tUserDefaults, (@"\"ChannelMultiSetting_%d\" ==> %d", i, [numSelChannel intValue] ) );
        if ( numSelChannel ) {
			GLog( tUI, (@"Load [%d] selChannel:%d", i, [numSelChannel intValue]) );
            [channelArray addObject:numSelChannel];
        } else {
            [channelArray addObject:defaultChannel];
        }
		GLog( tUI|tUserDefaults, (@"----------------------------------") );
    }
    
    for (int i=0;i<DEF_SplitViewNum;i++) {
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if(tempCamera.uid != nil && ![tempCamera.uid isEqualToString:@"(null)"] && [[channelArray objectAtIndex:i] intValue]!=-1){
			
			UIButton* defaultButtonXX = [marrBtn_Default objectAtIndex:i];
			if( defaultButtonXX ) {
				[defaultButtonXX setHidden:YES];
			}
			UILabel* statusBarXX = [marrLabel_Status objectAtIndex:i];
			if( statusBarXX ) {
				[statusBarXX setHidden:NO];
			}
			UIButton* moreFunctionXX = [marrBtn_MoreFunc objectAtIndex:i];
			if( moreFunctionXX ) {
				[moreFunctionXX setHidden:NO];
			}
			UILabel* cameraNameXX = [marrLabel_Name objectAtIndex:i];
			if( cameraNameXX ) {
				GLog( tUI, (@"view[%d] --> name:%@", i, tempCamera.name) );
				cameraNameXX.text = tempCamera.name;
				cameraNameXX.font = [UIFont systemFontOfSize:12.0f];
				cameraNameXX.textColor = [UIColor whiteColor];
#if defined(SVIPCLOUD)
                cameraNameXX.textColor=HexRGB(0x3d3c3c);
#endif
			}
            UIImageView* cameraConnectXX = [marrImg_Connt objectAtIndex:i];
            if( cameraConnectXX ) {
                cameraConnectXX.hidden=NO;
            }
			
			[self camera:tempCamera _didChangeChannelStatus:[(NSNumber*)[channelArray objectAtIndex:i] intValue] ChannelStatus:tempCamera.sessionState];

        } else {
			UIButton* defaultButtonXX = [marrBtn_Default objectAtIndex:i];
			if( defaultButtonXX ) {
				[defaultButtonXX setHidden:NO];
			}
			UILabel* statusBarXX = [marrLabel_Status objectAtIndex:i];
			if( statusBarXX ) {
				[statusBarXX setHidden:YES];
			}
			UIButton* moreFunctionXX = [marrBtn_MoreFunc objectAtIndex:i];
			if( moreFunctionXX ) {
				[moreFunctionXX setHidden:YES];
			}
			UILabel* cameraNameXX = [marrLabel_Name objectAtIndex:i];
			if( cameraNameXX ) {
				GLog( tUI, (@"view[%d] X --> name:(empty)", i) );
				cameraNameXX.text = @"";
			}
			UIImageView* cameraConnectXX = [marrImg_Connt objectAtIndex:i];
			if( cameraConnectXX ) {
                cameraConnectXX.hidden=YES;
				cameraConnectXX.image = [UIImage imageNamed:@"offline"];
			}
        }
    }
}

- (void)loadCamList {

	GLog( tUI, (@"+++CameraMultiLiveViewController - loadCamList") );
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    DeviceListOnCloud *dloc = [[DeviceListOnCloud alloc] init];
    dloc.delegate = self;
    
    NSString *userID = [NSString stringWithString:[userDefaults objectForKey:@"cloudUserID"]];
    NSString *userPWD = [NSString stringWithString:[userDefaults objectForKey:@"cloudUserPassword"]];
    [dloc downloadDeviceListID:userID PWD:userPWD];
	[dloc release];
	
	GLog( tUI, (@"---CameraMultiLiveViewController - loadCamList, userID@%p ==> %@, userPWD@%p ==> %@", userID, userID, userPWD, userPWD) );
}

- (void)viewDidLoad {
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    GLog( tUI, (@"MultiView: +viewDidLoad") );
	
	marrBtn_Default = [[NSMutableArray alloc] initWithObjects:defaultButton1, defaultButton2, defaultButton3, defaultButton4, nil];
	marrImg_Vdo = [[NSMutableArray alloc] initWithObjects:self.vdo1, self.vdo2, self.vdo3, self.vdo4, nil];
	marrBtn_ReConnt = [[NSMutableArray alloc] initWithObjects:reConnectBTN1, reConnectBTN2, reConnectBTN3, reConnectBTN4, nil];
	marrImg_Connt = [[NSMutableArray alloc] initWithObjects:cameraConnect1, cameraConnect2, cameraConnect3, cameraConnect4, nil];
	marrLabel_Status = [[NSMutableArray alloc] initWithObjects:cameraStatus1, cameraStatus2, cameraStatus3, cameraStatus4, nil];
	marrBtn_MoreFunc = [[NSMutableArray alloc] initWithObjects:moreFunction1, moreFunction2, moreFunction3, moreFunction4, nil];
	marrLabel_Name = [[NSMutableArray alloc] initWithObjects:cameraName1, cameraName2, cameraName3, cameraName4, nil];
	
	
	isMoreSetOpen = NO;
#if defined(IDHDCONTROL)
    [self loadDeviceFromServer];
#else
    [self loadDeviceFromDatabase];
#endif
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"cloudUserPassword"] && ![[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]){
        [self loadCamList];
    }
    
    [self checkStatus];
    
    //[self connectAndShow];
    //Elenco Camere
#if defined(MAJESTICIPCAMP)
    [dropboxRec setTitle:@"Elenco Camere" forState:UIControlStateNormal];
#else
    [dropboxRec setTitle:NSLocalizedString(@"Camera List", @"") forState:UIControlStateNormal];
#endif
    [infoBTN setTitle:NSLocalizedString(@"Information", @"") forState:UIControlStateNormal];
    
    [logInOut setTitle:NSLocalizedString(@"用户手册", @"") forState:UIControlStateNormal];
    
#if defined(SVIPCLOUD)
    //3d3c3c
    [dropboxRec setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [infoBTN setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    [logInOut setTitleColor:HexRGB(0x3d3c3c) forState:UIControlStateNormal];
    
    cameraName1.textColor=HexRGB(0x3d3c3c);
    cameraName2.textColor=HexRGB(0x3d3c3c);
    cameraName3.textColor=HexRGB(0x3d3c3c);
    cameraName4.textColor=HexRGB(0x3d3c3c);
    
    cameraStatus1.textColor=HexRGB(0x3d3c3c);
    cameraStatus2.textColor=HexRGB(0x3d3c3c);
    cameraStatus3.textColor=HexRGB(0x3d3c3c);
    cameraStatus4.textColor=HexRGB(0x3d3c3c);
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HexRGB(0x3d3c3c),NSForegroundColorAttributeName,nil]];    
#endif
    
#if defined(MAJESTICIPCAMP)
    logInOut.hidden=YES;
    infoBTN.origin=CGPointMake(infoBTN.frame.origin.x, 34);
#endif
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"moreset"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"moreset_clicked"] forState:UIControlStateHighlighted];
    button.frame=CGRectMake(0.0, 0.0, 44.0, 44.0);
    [button addTarget:self action:@selector(showMoreSet) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *moreSetButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, moreSetButton, nil];
    
    [moreSetButton release];
    
            
    wrongPwdRetryTime = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
#if defined(BayitCam)
    self.setupVideoBtn.hidden=NO;
    [self.setupVideoBtn setTitle:NSLocalizedStringFromTable(@"SetupVideo", @"bayitcam", nil) forState:UIControlStateNormal];
#endif
    
    [super viewDidLoad];

	GLog( tUI, (@"MultiView: -viewDidLoad") );
}

- (void)viewDidUnload
{
    self.connModeImageView = nil;
    self.directoryPath = nil;
    
    cameraArray = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationDidBecomeActiveNotification];
    
	if(glView) {
    	[self.glView tearDownGL];
		self.glView = nil;
	}
	CVPixelBufferRelease(mPixelBuffer);
	CVPixelBufferPoolRelease(mPixelBufferPool);
    [self setVdo1:nil];
    [self setVdo2:nil];
    [self setVdo3:nil];
    [self setVdo4:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
	GLog( tUI, (@"MultiView: +viewWillDisappear") );
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidEnterBackground
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationWillEnterForeground
												  object:nil];
	
	[mTimerStartShowRevoke invalidate];
	mTimerStartShowRevoke = nil;
	
    [super viewWillDisappear:animated];
    
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_bk"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationItem setPrompt:nil];
	
	if( isMoreSetOpen ) {
		[self hideMoreSet];
	}
	GLog( tUI, (@"MultiView: -viewWillDisappear") );
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
        
#if 0
        [monitorLandscape deattachCamera];
        [monitorLandscape attachCamera:camera];
        
        [self.glView destroyFramebuffer];
        
        [self.glView createFramebuffers];
        
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            [self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
        }
        else {
            [self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
        }

#endif    
        
    }
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
	GLog( tUI|tReStartShow, (@"++++++++++++++++++++++++++++++++++++++++++++++++++++") );
	GLog( tUI|tReStartShow, (@"+++applicationWillResignActive") );
    for (int i=0;i<DEF_SplitViewNum;i++){
        
        MyCamera *testCamera = [cameraArray objectAtIndex:i];
        GLog( tUI|tReStartShow, (@"\t{applicationWillResignActive} [%d]@%p uid:%@", i, testCamera, (testCamera.uid != nil)?testCamera.uid : @"(null)") );
        
        if (testCamera.uid != nil && ![testCamera.uid isEqualToString:@"(null)"]){
            
            NSNumber *chNum = [channelArray objectAtIndex:i];
			int ch = [chNum intValue];
            GLog( tUI|tReStartShow, (@"\t{applicationWillResignActive}\tch:%d", ch) );
			[testCamera stopShow_block:ch];
			//[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
			[testCamera stopSoundToDevice:ch];
			[testCamera stopSoundToPhone:ch];

        }
    }
	GLog( tUI|tReStartShow, (@"---applicationWillResignActive") );
	GLog( tUI|tReStartShow, (@"---------------------------------------------------") );
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	GLog( tUI|tReStartShow, (@"++++++++++++++++++++++++++++++++++++++++++++++++++++") );
	GLog( tUI|tReStartShow, (@"+++applicationDidBecomeActive") );
    for (int i=0;i<DEF_SplitViewNum;i++){
        
        MyCamera *testCamera = [cameraArray objectAtIndex:i];
        GLog( tUI|tReStartShow, (@"\t{applicationDidBecomeActive} [%d]@%p uid:%@", i, testCamera, (testCamera.uid != nil)?testCamera.uid : @"(null)") );
        if (testCamera.uid != nil && ![testCamera.uid isEqualToString:@"(null)"]){
            
            NSNumber *chNum = [channelArray objectAtIndex:i];
			int ch = [chNum intValue];
            GLog( tUI|tReStartShow, (@"\t{applicationDidBecomeActive}\tch:%d", ch) );
            if(!isGoPlayEvent){
                [testCamera startShow:ch ScreenObject:self];
            }
            if (selectedAudioMode == AUDIO_MODE_MICROPHONE)
				[testCamera startSoundToDevice:ch];
            if (selectedAudioMode == AUDIO_MODE_SPEAKER)
				[testCamera startSoundToPhone:ch];
        }
    }
	GLog( tUI|tReStartShow, (@"---applicationDidBecomeActive") );
	GLog( tUI|tReStartShow, (@"---------------------------------------------------") );
}


- (void)updateToScreen2:(NSArray*)arrs {

	static BOOL bDbg = FALSE;
    @autoreleasepool
    {
        CIImage *ciImage = [arrs objectAtIndex:0];
        NSString *uid = [arrs objectAtIndex:1];
        NSNumber *channel = [arrs objectAtIndex:2];
        
        //UIImageOrientationLeft UIImageOrientationUp UIImageOrientationRight
        //UIImage *img = [UIImage imageWithCIImage:ciImage scale:0.8 orientation:UIImageOrientationUp];
        UIImage *img = [UIImage imageWithCIImage:ciImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
		
        for (int i=0;i<DEF_SplitViewNum;i++) {
            MyCamera *cameraIdx = [cameraArray objectAtIndex:i];
            NSNumber *channelIdx = [channelArray objectAtIndex:i];
			GLogREL( bDbg, (@"%@, %d => [%d] uid:%@ channel:%d", uid, [channel intValue], i, cameraIdx.uid, (int)[channelIdx intValue]) );
            if ([cameraIdx.uid isEqualToString:uid] && [channelIdx intValue] == [channel intValue]){
				UIImageView* vdoXX = [marrImg_Vdo objectAtIndex:i];
				if( vdoXX ) {
					vdoXX.image = img ;
				}
            }
			else {
				
			}
        }
    }
}

//- (void)updateToScreen:(NSValue*)pointer
//{
//
//	LPSIMAGEBUFFINFO pScreenBmpStore = (LPSIMAGEBUFFINFO)[pointer pointerValue];
//    
//	if( mPixelBuffer == nil ||
//	    mSizePixelBuffer.width != pScreenBmpStore->nWidth ||
//	    mSizePixelBuffer.height != pScreenBmpStore->nHeight ) {
//		
//		if(mPixelBuffer) {
//			CVPixelBufferRelease(mPixelBuffer);
//			CVPixelBufferPoolRelease(mPixelBufferPool);			
//		}
//		
//		NSMutableDictionary* attributes;
//		attributes = [NSMutableDictionary dictionary];
//		[attributes setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
//		[attributes setObject:[NSNumber numberWithInt:pScreenBmpStore->nWidth] forKey: (NSString*)kCVPixelBufferWidthKey];
//		[attributes setObject:[NSNumber numberWithInt:pScreenBmpStore->nHeight] forKey: (NSString*)kCVPixelBufferHeightKey];
//		
//		CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef) attributes, &mPixelBufferPool);
//		if( err != kCVReturnSuccess ) {
//			NSLog( @"mPixelBufferPool create failed!" );
//		}
//		err = CVPixelBufferPoolCreatePixelBuffer (NULL, mPixelBufferPool, &mPixelBuffer);
//		if( err != kCVReturnSuccess ) {
//			NSLog( @"mPixelBuffer create failed!" );
//		}
//		mSizePixelBuffer = CGSizeMake(pScreenBmpStore->nWidth, pScreenBmpStore->nHeight);
//		NSLog( @"CameraMultiLiveViewController - mPixelBuffer created %dx%d nBytes_per_Row:%d", pScreenBmpStore->nWidth, pScreenBmpStore->nHeight, pScreenBmpStore->nBytes_per_Row );
//	}
//	CVPixelBufferLockBaseAddress(mPixelBuffer,0);
//	CVPixelBufferLockBaseAddress(pScreenBmpStore->pixelBuff,0);
//	
//	UInt8* baseAddress = (UInt8*)CVPixelBufferGetBaseAddress(mPixelBuffer);
//	UInt8* srcAddress = (UInt8*)CVPixelBufferGetBaseAddress(pScreenBmpStore->pixelBuff);
//	
//	memcpy(baseAddress, srcAddress, CVPixelBufferGetBytesPerRow(pScreenBmpStore->pixelBuff) * CVPixelBufferGetHeight(pScreenBmpStore->pixelBuff) );
//	
//	CVPixelBufferUnlockBaseAddress(pScreenBmpStore->pixelBuff,0);
//	CVPixelBufferUnlockBaseAddress(mPixelBuffer,0);
//    
//	[glView renderVideo:mPixelBuffer];
//
//}


// If you want to set the final frame size, just implement this delegation to given the wish frame size
//

#if 0
- (void)glFrameSize:(NSArray*)param
{
    //NSLog( @"glview:%@", self.glView);
    
	CGSize* pglFrameSize_Original = (CGSize*)[(NSValue*)[param objectAtIndex:0] pointerValue];
	CGSize* pglFrameSize_Scaling = (CGSize*)[(NSValue*)[param objectAtIndex:1] pointerValue];
	
	[self recalcMonitorRect:*pglFrameSize_Original];
    
	self.glView.maxZoom = CGSizeMake( (pglFrameSize_Original->width*2.0 > 1920)?1920:pglFrameSize_Original->width*2.0, (pglFrameSize_Original->height*2.0 > 1080)?1080:pglFrameSize_Original->height*2.0 );
	   
    CGSize size = self.glView.frame.size;
    CGFloat fScale  = [[UIScreen mainScreen] scale];
    size.height *= fScale;
    size.width *= fScale;
    *pglFrameSize_Scaling = size ;
    
	
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.scrollViewLandscape setContentSize:self.glView.frame.size];
    }
    else {
        [self.scrollViewPortrait setContentSize:self.glView.frame.size];
    }
}
#endif

- (void)waitStopShowCompleted:(unsigned int)uTimeOutInMs
{
	unsigned int uStart = _getTickCount();
	while( self.bStopShowCompletedLock == FALSE ) {
		usleep(1000);
		unsigned int now = _getTickCount();
		if( now - uStart >= uTimeOutInMs ) {
			NSLog( @"CameraMultiLiveViewController - waitStopShowCompleted !!!TIMEOUT!!!" );
			break;
		}
	}
}

- (void)cameraStopShowCompleted:(NSNotification *)notification
{
	bStopShowCompletedLock = TRUE;
}

- (void)didEnterBackground:(NSNotification*)notif {
	
	GLog( tUI|tForeBackground, (@"=======================================================") );
	GLog( tUI|tForeBackground, (@"+++CameraMultiLiveViewController - didEnterBackground") );
	GLog( tUI|tForeBackground, (@"=======================================================") );
	
	if( mTimerStartShowRevoke != nil ) {
		[mTimerStartShowRevoke invalidate];
		mTimerStartShowRevoke = nil;
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidEnterBackground
												  object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground:) name:kApplicationWillEnterForeground object:nil];
	
	for( int i=0 ; i<DEF_SplitViewNum ; i++ ) {
		MyCamera* theCamera = [cameraArray objectAtIndex:i];
		NSNumber* numChannel = [channelArray objectAtIndex:i];
		
		if( theCamera.uid != nil && ![theCamera.uid isEqualToString:@"(null)"] && [numChannel intValue] >= 0 ) {
			[theCamera stopShow:[numChannel intValue]];
			GLog( tUI|tForeBackground, (@"  [%d]theCamera:{uid:%@}@%p stopShow:%d ...", i, theCamera.uid, theCamera, [numChannel intValue]) );
		}
		else {
			GLog( tUI|tForeBackground, (@"  [%d]theCamera:@(null) IGNORE!", i) );
		}
	}
	
	GLog( tUI|tForeBackground, (@"=======================================================") );
	GLog( tUI|tForeBackground, (@"---CameraMultiLiveViewController - didEnterBackground") );
	GLog( tUI|tForeBackground, (@"=======================================================") );
}

- (void)didEnterForeground:(NSNotification*)notif {

	GLog( tUI|tForeBackground, (@"=======================================================") );
	GLog( tUI|tForeBackground, (@"+++CameraMultiLiveViewController - didEnterForeground") );
	GLog( tUI|tForeBackground, (@"=======================================================") );

	if( mTimerStartShowRevoke ) {
		[mTimerStartShowRevoke invalidate];
		mTimerStartShowRevoke = nil;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationWillEnterForeground
												  object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:kApplicationDidEnterBackground object:nil];

	for( int i=0 ; i<DEF_SplitViewNum ; i++ ) {
		MyCamera* theCamera = [cameraArray objectAtIndex:i];
		NSNumber* numChannel = [channelArray objectAtIndex:i];
		
		if( theCamera.uid != nil && ![theCamera.uid isEqualToString:@"(null)"] && [numChannel intValue] >= 0 ) {
			[theCamera startShow:[numChannel intValue] ScreenObject:self];
			GLog( tUI|tForeBackground, (@"  [%d]theCamera:{uid:%@}@%p startShow:%d ...", i, theCamera.uid, theCamera, [numChannel intValue]) );
		}
		else {
			GLog( tUI|tForeBackground, (@"  [%d]theCamera:@(null) IGNORE!", i) );
		}
	}

	GLog( tUI|tForeBackground, (@"=======================================================") );
	GLog( tUI|tForeBackground, (@"---CameraMultiLiveViewController - didEnterForeground") );
	GLog( tUI|tForeBackground, (@"=======================================================") );
}

- (void)onTimerStartShowRevoke:(NSTimer*)aTimer {
	GLog( tStartShow|tUI, (@"+++CameraMultiLiveViewController - onTimerStartShowRevoke:@%p", aTimer) );
	
	int idx = 0;
	for( MyCamera* theCamera in cameraArray ) {
		int nChannel = [(NSNumber*)[channelArray objectAtIndex:idx] intValue];
		
		if( theCamera.sessionState == CONNECTION_STATE_CONNECTED &&
		    [theCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED &&
		    ![theCamera isAVChannelStartShow:nChannel] ) {

			[theCamera startShow:nChannel ScreenObject:self];
			theCamera.delegate2 = self;
			
		}
		else if( theCamera.sessionState != CONNECTION_STATE_CONNECTING &&
				 theCamera.sessionState != CONNECTION_STATE_WRONG_PASSWORD ) {
			
			unsigned int now = _getTickCount();
			if( now - mnLastReTryTickArray[idx] > DEF_ReTryConnectInterval &&
			    mnReTryTimesArray[idx] <= DEF_ReTryTimes ) {
			
				[theCamera connect:theCamera.uid];
				[theCamera start:0];
				
				mnLastReTryTickArray[idx] = _getTickCount();
				mnReTryTimesArray[idx] += 1;
				
			}
		}
		
		idx++;
	}
}

#pragma mark - CameraDelegate
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size {
    
    switch (type) {
        case IOTYPE_USER_IPCAM_GET_SAVE_DROPBOX_RESP:
        {
            SMsgAVIoctrlGetDropbox *s = (SMsgAVIoctrlGetDropbox *)data;
            MyCamera* myCamera = camera_;
            
            myCamera.isLinkDropbox = NO;
            if ( 1 == s->nLinked){
                NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
                if ( [uuid isEqualToString:[ NSString stringWithUTF8String:s->szLinkUDID]]){
                    myCamera.isLinkDropbox = YES;
                }
            }
            
            for (int i=0;i<[camera_list count];i++) {
                MyCamera *tempCamera = [camera_list objectAtIndex:i];
                if ([tempCamera.uid isEqualToString:myCamera.uid]){
                    [camera_list replaceObjectAtIndex:i withObject:myCamera];
                }
            }
        }
        case IOTYPE_USER_IPCAM_LISTWIFIAP_RESP:
        {
            
            if (isWaitWiFiResp) {
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                SMsgAVIoctrlListWifiApResp *s = (SMsgAVIoctrlListWifiApResp *)data;
                
                for (int i = 0; i < s->number; ++i) {
                    
                    SWifiAp ap = s->stWifiAp[i];
                    
                    if ([[userDefaults objectForKey:@"apSSID"] isEqualToString:[NSString stringWithFormat:@"%s", ap.ssid]]) {
                        
                        SMsgAVIoctrlSetWifiReq *s4 = (SMsgAVIoctrlSetWifiReq *)malloc(sizeof(SMsgAVIoctrlSetWifiReq));
                        memcpy(s4->ssid, [[userDefaults objectForKey:@"apSSID"] UTF8String], 32);
                        memcpy(s4->password, [[userDefaults objectForKey:@"apPassword"] UTF8String], 32);
                        
                        s4->enctype = ap.enctype;
                        s4->mode = 1;
                        
                        [camera_ sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETWIFI_REQ Data:(char *)s4 DataSize:sizeof(SMsgAVIoctrlSetWifiReq)];
                        
                        free(s4);
                        [userDefaults setObject:@"" forKey:@"apSSID"];
                        [userDefaults setObject:@"" forKey:@"apPassword"];
                        [userDefaults setObject:@"" forKey:@"apCamUID"];
                        [userDefaults synchronize];
                        
                        isWaitWiFiResp = NO;
                        isWaitReConnect = YES;
                    }
                }
                
                if (isWaitWiFiResp) {
                    SMsgAVIoctrlSetWifiReq *s4 = (SMsgAVIoctrlSetWifiReq *)malloc(sizeof(SMsgAVIoctrlSetWifiReq));
                    memcpy(s4->ssid, [[userDefaults objectForKey:@"apSSID"] UTF8String], 32);
                    memcpy(s4->password, [[userDefaults objectForKey:@"apPassword"] UTF8String], 32);
                    
                    s4->enctype = 0;
                    s4->mode = 1;
                    
                    [camera_ sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETWIFI_REQ Data:(char *)s4 DataSize:sizeof(SMsgAVIoctrlSetWifiReq)];
                    
                    free(s4);
                    [userDefaults setObject:@"" forKey:@"apSSID"];
                    [userDefaults setObject:@"" forKey:@"apPassword"];
                    [userDefaults setObject:@"" forKey:@"apCamUID"];
                    [userDefaults synchronize];
                    
                    isWaitWiFiResp = NO;
                    isWaitReConnect = YES;
                }
                
                [self setupProgressHD:NSLocalizedString(@"Done!",@"") isDone:YES];
            }
        }
        case IOTYPE_USER_IPCAM_SETWIFI_RESP:
        {
            SMsgAVIoctrlSetWifiResp *s = (SMsgAVIoctrlSetWifiResp *)data;
            if (s->result==0) {
                camNeedReconnect = camera_;
            }
        }
    }
}



- (void)camera:(MyCamera *)camera_ _didChangeSessionStatus:(NSInteger)status {
    
    if (status == CONNECTION_STATE_CONNECTED){
        
        if (camNeedReconnect == camera_) {
            isWaitReConnect = NO;
        }
        
        for (int i=0;i<DEF_SplitViewNum;i++) {
            MyCamera *tempCamera  = [cameraArray objectAtIndex:i];
            
            if ([tempCamera.uid isEqualToString:camera_.uid]) {
                
				UIImageView* cameraConnectXX = [marrImg_Connt objectAtIndex:i];
				if( cameraConnectXX ) {
					cameraConnectXX.image = [UIImage imageNamed:@"online"];
				}
				UILabel* cameraStatusXX = [marrLabel_Status objectAtIndex:i];
				if( cameraStatusXX ) {
					cameraStatusXX.text = @"";
				}
				UIButton* reConnectBTNXX = [marrBtn_ReConnt objectAtIndex:i];
				if( reConnectBTNXX ) {
					reConnectBTNXX.hidden = YES;
				}
            }
        }
    }
	else if (status == CONNECTION_STATE_TIMEOUT && isWaitReConnect) {
        
        if (camNeedReconnect == camera_) {
            [camNeedReconnect stop:camNeedReconnect.lastChannel];
            //[camNeedReconnect disconnect];
            //[camNeedReconnect connect:camNeedReconnect.uid];
            [camNeedReconnect start:camNeedReconnect.lastChannel];
            //[camNeedReconnect startShow:camNeedReconnect.lastChannel ScreenObject:self];
            camNeedReconnect.delegate2 = self;
        }
    }
}

- (void)invokeShartShow:(NSArray*)aParam
{
	MyCamera* theCamera = (MyCamera*)[aParam objectAtIndex:0];
	NSNumber* channelNum = (NSNumber*)[aParam objectAtIndex:1];

	GLogREL( tUI, (@"[invoke startShow]--------------> UID:%@ ch:%d", theCamera.uid, [channelNum intValue] ) );
	
	[theCamera startShow:[channelNum intValue] ScreenObject:self];
}

- (void)camera:(MyCamera *)camera_ _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status {
	
	if( channel == 0 ) {
		
		switch(status) {
			case CONNECTION_STATE_CONNECTED: {
				GLogREL( tUI|tStartShow, (@"Connected! UID:%@", camera_.uid) );
//				for( int i=0 ; i<DEF_SplitViewNum ; i++ ) {
//					MyCamera* cam = [cameraArray objectAtIndex:i];
//					NSNumber* numChannel = [channelArray objectAtIndex:i];
//					
//					if( [cam.uid isEqualToString:camera_.uid] ) {
//						GLogREL( tUI, (@"--> invoke camera start: ch:%d", [numChannel intValue]) );
//						[cam start:[numChannel intValue]];
//					}
//				}
				
			}
//			case CONNECTION_STATE_TIMEOUT: {
//				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//					
//					[camera_ stop:channel];
//					
//					usleep(500 * 1000);
//					
//					[camera_ disconnect];
//				});
//			}	break;
			default: {
				
			}	break;
		}
		
	}
	
	
		if (status == CONNECTION_STATE_CONNECTED){
            
			for (int i=0;i<DEF_SplitViewNum;i++) {
				MyCamera *tempCamera  = [cameraArray objectAtIndex:i];
				
				if ([tempCamera.uid isEqualToString:camera_.uid]) {
					
					UIImageView* cameraConnectXX = [marrImg_Connt objectAtIndex:i];
					if( cameraConnectXX ) {
						cameraConnectXX.image = [UIImage imageNamed:@"online"];
					}
					UILabel* cameraStatusXX = [marrLabel_Status objectAtIndex:i];
					if( cameraStatusXX ) {
						cameraStatusXX.text = @"";
					}
					UIButton* reConnectBTNXX = [marrBtn_ReConnt objectAtIndex:i];
					if( reConnectBTNXX ) {
						reConnectBTNXX.hidden = YES;
					}
					
					int nSelChannel = [[channelArray objectAtIndex:i] intValue];
					if( nSelChannel == channel ) {
						GLog( tUI|tStartShow, (@"UID:%@ channel<%d> connected. invoke startShow after 2sec...", tempCamera.uid, nSelChannel) );
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
							[self invokeShartShow:[NSArray arrayWithObjects:tempCamera, [channelArray objectAtIndex:i], nil]];
						});
					}
					
				}
			}
			
        } else {
        
			if( status == CONNECTION_STATE_CONNECTING ) {
				GLogREL( tUI, (@"connecting... UID:%@ ch:%d", camera_.uid, (int)channel) );
			}
			
			for (int i=0;i<DEF_SplitViewNum;i++) {
				MyCamera *tempCamera = [cameraArray objectAtIndex:i];
				NSNumber* numChannel = [channelArray objectAtIndex:i];
				if ([tempCamera.uid isEqualToString:camera_.uid] &&
					[numChannel intValue] == (int)channel ){
					
					UIImageView* cameraConnectXX = [marrImg_Connt objectAtIndex:i];
					if( cameraConnectXX ) {
						cameraConnectXX.image = [UIImage imageNamed:@"offline"];
					}
					UIImageView* vdoXX = [marrImg_Vdo objectAtIndex:i];
					if( vdoXX ) {
						vdoXX.image = nil;
					}
					UILabel* cameraStatusXX = [marrLabel_Status objectAtIndex:i];
					if (status==CONNECTION_STATE_CONNECTING){
						cameraStatusXX.text = NSLocalizedString(@"Wait for connecting...", @"");
					} else {
						
						UIButton* reConnectBTNXX = [marrBtn_ReConnt objectAtIndex:i];
						if( reConnectBTNXX ) {
							reConnectBTNXX.hidden = NO;
						}
						
						if (status==CONNECTION_STATE_UNKNOWN_DEVICE){
							cameraStatusXX.text = NSLocalizedString(@"Unknown Device", @"");
						} else if (status==CONNECTION_STATE_WRONG_PASSWORD){
							cameraStatusXX.text = NSLocalizedString(@"Wrong Password", @"");
						} else if (status==CONNECTION_STATE_TIMEOUT){
							cameraStatusXX.text = NSLocalizedString(@"Timeout", @"");
						} else if (status==CONNECTION_STATE_UNSUPPORTED){
							cameraStatusXX.text = NSLocalizedString(@"Not Supported", @"");
						} else if (status==CONNECTION_STATE_CONNECT_FAILED || status== CONNECTION_STATE_DISCONNECTED){
							cameraStatusXX.text = NSLocalizedString(@"Connect Failed", @"");
						}
                        else{
                            cameraStatusXX.text = NSLocalizedString(@"Connect Failed", @"");
                        }
					}
					
				}
			}
		}
	
}

#pragma mark - CameraLive Delegate
- (void)didReStartCamera:(MyCamera *)tempCamera_ cameraChannel:(NSNumber *)channel withView:(NSNumber *)tag{
	
	int nLastIdx = [tag intValue];
	GLog( tUI, (@"+++CameraMultiLiveViewController - didReStartCamera:@%p cameraChannel:%d withView:[index:%d]", tempCamera_, [channel intValue], nLastIdx) );
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//將資料回步回手機
	GLog( tUI|tUserDefaults, (@"\"CameraMultiSetting_%d\" <== %@", nLastIdx, tempCamera_.uid ) );
	[userDefaults setObject:((tempCamera_.uid != nil)?tempCamera_.uid:@"(null)") forKey:[NSString stringWithFormat:@"CameraMultiSetting_%d",nLastIdx]];
	
	GLog( tUI|tUserDefaults, (@"\"ChannelMultiSetting_%d\" <== %d", nLastIdx, [channel intValue] ) );
	[userDefaults setInteger:[channel intValue] forKey:[NSString stringWithFormat:@"ChannelMultiSetting_%d",nLastIdx]];
	
	[userDefaults synchronize];

	[channelArray replaceObjectAtIndex:nLastIdx withObject:channel];

	
        MyCamera *tempCamera = [cameraArray objectAtIndex:nLastIdx];
        
        if (tempCamera.uid != nil && [tempCamera.uid isEqualToString:tempCamera_.uid]){
			NSNumber *tempChannel = [channelArray objectAtIndex:nLastIdx];
            GLog( tUI, (@"---+CameraMultiLiveViewController - index:%d UID:%@ ch:%d re-startShow...", nLastIdx, tempCamera_.uid, [tempChannel intValue]) );
			
			if( tempCamera.sessionState == CONNECTION_STATE_CONNECTED && [tempCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED ) {
				//[tempCamera connect:tempCamera.uid];
				//[tempCamera start:[tempChannel intValue]];
if(!isGoPlayEvent){
				[tempCamera startShow:[tempChannel intValue] ScreenObject:self];
}
				tempCamera.delegate2 = self;
				
				[self camera:tempCamera _didChangeSessionStatus:CONNECTION_STATE_CONNECTED];
			}
        }
		else {
			GLog( tUI, (@"---+CameraMultiLiveViewController - !!! Something wrong !!!") );
		}

}

#pragma mark - CameraList Delegate
- (void)didAddCamera:(MyCamera *)tempCamera cameraChannel:(NSNumber *)channel withView:(NSNumber *)tag {
    
    NSNumber *tempChannel = 0;
    
    [self checkStatus];
    if(!isGoPlayEvent){
    	[tempCamera startShow:[tempChannel intValue] ScreenObject:self];
    }
    
    tempCamera.delegate2 = self;
    
    if (tempCamera.sessionState == CONNECTION_STATE_CONNECTED && [tempCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
		
		UIImageView* cameraConnectXX = [marrImg_Connt objectAtIndex:[tag intValue]];
		if( cameraConnectXX ) {
			cameraConnectXX.image = [UIImage imageNamed:@"online"];
		}
		UILabel* cameraStatusXX = [marrLabel_Status objectAtIndex:[tag intValue]];
		if( cameraStatusXX ) {
			cameraStatusXX.text = @"";
		}
		UIButton* reConnectBTNXX = [marrBtn_ReConnt objectAtIndex:[tag intValue]];
		if( reConnectBTNXX ) {
			reConnectBTNXX.hidden = YES;
		}
		
    }
}

#pragma mark - AddCameraDelegate Methods
- (void)camera:(NSString *)UID didAddwithName:(NSString *)name password:(NSString *)password syncOnCloud:(BOOL)isSync addToCloud:(BOOL)isAdd addFromCloud:(BOOL)isFromCloud {
    

    
    MyCamera *camera_ = [[MyCamera alloc] initWithName:name viewAccount:@"admin" viewPassword:password];
    [camera_ connect:UID];
    [camera_ start:0];
    
#if defined(IDHDCONTROL)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic=@{@"id":[NSString stringWithFormat:@"%ld",(long)[AccountInfo getUserId]],@"uuid":[MyCamera boxUUID:camera_]};
    HttpTool *httpTool=[HttpTool shareInstance];
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=saveUuid" parameters:dic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        if(code==1){
            [self alertInfo:msg withTitle:@"提示"];
        }
        else{
            
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        [self alertInfo:error.localizedDescription withTitle:@"提示"];
    }];
#endif
    
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
    
    if (isAdd) {
        DeviceListOnCloud *dloc = [[DeviceListOnCloud alloc] init];
        dloc.delegate = self;
        
        [dloc addDeviceUID:UID deviceName:name userID:[userDefaults objectForKey:@"cloudUserID"] PWD:[userDefaults objectForKey:@"cloudUserPassword"]];
        [dloc release];
    }
    
    if (isSync) {
        DeviceListOnCloud *dloc = [[DeviceListOnCloud alloc] init];
        dloc.delegate = self;
        
        [dloc syncDeviceUID:UID deviceName:name userID:[userDefaults objectForKey:@"cloudUserID"] PWD:[userDefaults objectForKey:@"cloudUserPassword"]];
        [dloc release];
        
    }
    
    if ([[userDefaults objectForKey:@"wifiSetting"] integerValue]==1){
        
        SMsgAVIoctrlListWifiApReq *structListWiFi = (SMsgAVIoctrlListWifiApReq *)malloc(sizeof(SMsgAVIoctrlListWifiApReq));
        memset(structListWiFi, 0, sizeof(SMsgAVIoctrlListWifiApReq));
        
        [camera_ sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_LISTWIFIAP_REQ Data:(char *)structListWiFi DataSize:sizeof(SMsgAVIoctrlListWifiApReq)];
        free(structListWiFi);
        
        [userDefaults setInteger:0 forKey:@"wifiSetting"];
        [userDefaults setObject:camera_.uid forKey:@"apCamUID"];
        [userDefaults synchronize];
        
        [self setupProgressHD:NSLocalizedString(@"Now setting...",@"") isDone:NO];
        
        isWaitWiFiResp = YES;
    }
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
    
    //將資料回步回手機
	GLog( tUI|tUserDefaults, (@"\"CameraMultiSetting_%d\" <== %@", mnViewTag, camera_.uid ) );
	[userDefaults setObject:((camera_.uid != nil)?camera_.uid:@"(null)") forKey:[NSString stringWithFormat:@"CameraMultiSetting_%d", mnViewTag]];
	
	GLog( tUI|tUserDefaults, (@"\"ChannelMultiSetting_%d\" <== 0", mnViewTag ) );
    [userDefaults setInteger:0 forKey:[NSString stringWithFormat:@"ChannelMultiSetting_%d", mnViewTag]];
	
	[userDefaults synchronize];
    
    [self didAddCamera:camera_ cameraChannel:0 withView:[NSNumber numberWithInt:mnViewTag]];
    
    [camera_ release];
}

#pragma mark - changeCameraSettingDelegate Methods
- (void)deleteCamera:(NSString *)uid {
    
    /* delete camera lastframe snapshot file */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", uid];
    [fileManager removeItemAtPath:[self pathForDocumentsResource: imgName] error:NULL];
    
    if (database != NULL) {
        
        if (![database executeUpdate:@"DELETE FROM device where dev_uid=?", uid]) {
            NSLog(@"Fail to remove device from database.");
        }
    }
}

- (void)deleteSnapshotRecords:(NSString *)uid {
    
    if (database != NULL) {
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot WHERE dev_uid=?", uid];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while([rs next]) {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[self pathForDocumentsResource: filePath] error:NULL];
            NSLog(@"camera(%@) snapshot removed", filePath);
        }
        
        [rs close];
        
        [database executeUpdate:@"DELETE FROM snapshot WHERE dev_uid=?", uid];
    }
}

- (void)deleteSameUIDView:(NSString *)uid {
    
	if( mDummyCam == nil ) {
		mDummyCam = [[MyCamera alloc] init];
	}
    MyCamera *defaultCamera = mDummyCam;
    NSNumber *defaultChannel = [NSNumber numberWithInt:-1];
    
    for (int i=0;i<DEF_SplitViewNum;i++) {
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid != nil && [uid isEqualToString:tempCamera.uid]) {
            [tempCamera stopShow:[[channelArray objectAtIndex:i] intValue]];
            [tempCamera ipcamStop:[[channelArray objectAtIndex:i] intValue]];
            [cameraArray replaceObjectAtIndex:i withObject:defaultCamera];
            [channelArray replaceObjectAtIndex:i withObject:defaultChannel];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            //將資料回步回手機
			GLog( tUI|tUserDefaults, (@"\"CameraMultiSetting_%d\" <== %@", i, defaultCamera.uid ) );
			[userDefaults setObject:((defaultCamera.uid != nil)?defaultCamera.uid:@"(null)") forKey:[NSString stringWithFormat:@"CameraMultiSetting_%d",i]];
			
			GLog( tUI|tUserDefaults, (@"\"ChannelMultiSetting_%d\" <== 0", mnViewTag ) );
            [userDefaults setInteger:-1 forKey:[NSString stringWithFormat:@"ChannelMultiSetting_%d", i]];
			
			[userDefaults synchronize];
            
			UIImageView* vdoXX = [marrImg_Vdo objectAtIndex:i];
			if( vdoXX ) {
				vdoXX.image = nil;
			}
			UIButton* reConnectBTNXX = [marrBtn_ReConnt objectAtIndex:i];
			if( reConnectBTNXX ) {
				reConnectBTNXX.hidden = YES;
			}
        }
    }
    
    [self checkStatus];
    
    [self hideMoreFunctionView:nil];
}

#pragma mark - MBProgressHUD
-(void)setupProgressHD:(NSString *)text isDone:(BOOL)done
{
    if (HUD) {
        [HUD hide:NO];
		[HUD release];
        HUD=nil;
    }
    HUD=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate=self;
    HUD.labelText=text;
    HUD.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
    HUD.mode=done?MBProgressHUDModeCustomView:MBProgressHUDModeIndeterminate;
    HUD.removeFromSuperViewOnHide=YES;
    [HUD show:NO];
    if (done) {
        [HUD hide:NO afterDelay:1.5];
    }
}

#pragma mark - EditCameraDefaultDelegate Methods
- (void)didRemoveDevice:(MyCamera *)removedCamera {
#if defined(IDHDCONTROL)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic=@{@"id":[NSString stringWithFormat:@"%ld",(long)[AccountInfo getUserId]],@"uuid":removedCamera.uid};
    HttpTool *httpTool=[HttpTool shareInstance];
    [httpTool JsonGetRequst:@"/index.php?ctrl=app&act=delUuid" parameters:dic success:^(id responseObject) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        NSInteger code=[responseObject[@"code"]integerValue];
        NSString *msg=responseObject[@"msg"];
        if(code==1){
            [self alertInfo:msg withTitle:@"提示"];
        }
        else{
            //[self alertInfo:msg withTitle:@"提示"];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        [self alertInfo:error.localizedDescription withTitle:@"提示"];
    }];
#endif
    
    NSString *uid = removedCamera.uid;
 
    [removedCamera stop:0];
    [removedCamera disconnect];

    [camera_list removeObject:removedCamera];
    
    [self deleteSameUIDView:uid];
    
    if (uid != nil && ![uid isEqualToString:@"(null)"]) {
        
        NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
        
        // delete camera & snapshot file in db
        [self deleteCamera:uid];
        [self deleteSnapshotRecords:uid];
        
        // unregister from apns server
        dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
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
                
#ifdef DEF_APNSTest
				NSLog( @"==============================================");
				NSLog( @">>> %@", unregisterResult );
				NSLog( @"==============================================");
                if (error != NULL) {
                    NSLog(@"%@",[error localizedDescription]);
                }
#endif
            }
        });
        
        dispatch_release(queue);
    }
}

-(void) didChangeSetting:(MyCamera *)changedCamera {
    
    if (changedCamera.bIsSyncOnCloud) {
        DeviceListOnCloud *dloc = [[DeviceListOnCloud alloc] init];
        dloc.delegate = self;

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
        [dloc syncDeviceUID:changedCamera.uid deviceName:changedCamera.name userID:[userDefaults objectForKey:@"cloudUserID"] PWD:[userDefaults objectForKey:@"cloudUserPassword"]];
        [dloc release];
    }
    
	NSNumber *tempChannel = [channelArray objectAtIndex:[moreFunctionTag intValue]];
	if( changedCamera.sessionState == CONNECTION_STATE_DISCONNECTED ) {
        [changedCamera stop:0];
        [changedCamera disconnect];

        [changedCamera connect:changedCamera.uid];
        [changedCamera start:0];
    }
if(!isGoPlayEvent){
    [changedCamera startShow:[tempChannel intValue] ScreenObject:self];
}
    changedCamera.delegate2 = self;
    
    SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
    s->channel = 0;
    [changedCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
    free(s);
    
    SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
    [changedCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
    free(s2);
    
    SMsgAVIoctrlTimeZone s3={0};
    s3.cbSize = sizeof(s3);
    [changedCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
    //[MyCamera loadCameraQVGA:changedCamera];
    [self checkStatus];
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
//    NSLog(@"String sent from server %@",[NSString stringWithData:theData encoding:NSUTF8StringEncoding]);
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([dictionary valueForKey:@"status"]) {
        NSString *result = [dictionary valueForKey:@"status"];
        if ([result isEqualToString:@"insert or update failed"]) {
            NSString *msg = NSLocalizedString(@"Failed to add/sync device to your account. Please tick “Sync with your cloud account” in the device “Settings” page to add again.", @"");
            NSString *dismiss = NSLocalizedString(@"OK", @"");
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:dismiss otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    
    if ([dictionary valueForKey:@"record"] && [camera_list count]!=0) {
        NSMutableArray *tempArray = [dictionary valueForKey:@"record"];
        
        if (tempArray) {
            for (NSDictionary *tempDic in tempArray){
                NSString* cameraUID = [tempDic valueForKey:@"dev_uid"];
                NSString* cameraName = [tempDic valueForKey:@"dev_name"];
                
                for (int i=0;i<[camera_list count];i++) {
                    
                    MyCamera *tempCam = [camera_list objectAtIndex:i];
                    
                    if ([tempCam.uid isEqualToString:cameraUID] && tempCam.bIsSyncOnCloud){
                        [tempCam setName:cameraName];
                        [self checkStatus];
                    }
                }
            }
        }
    }
}
#if defined(BayitCam)
- (IBAction)goAttention:(id)sender {
    BayitCamViewController *vc=[[BayitCamViewController alloc]initWithNibName:@"BayitCamViewController" bundle:nil];
    vc.isFromFormUI=YES;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
#endif
@end
