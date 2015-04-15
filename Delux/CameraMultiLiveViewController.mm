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
#import "DropboxSettingVC.h"
#import "AppInfoController.h"
#import "StartViewController.h"
#import "cCustomNavigationController.h"

#ifndef P2PCAMLIVE
#define SHOW_SESSION_MODE
#endif
#define DEF_WAIT4STOPSHOW_TIME	250
extern unsigned int _getTickCount() ;

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

- (CGRect)zoomRectForScrollView:(UIScrollView *)_scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
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
        documentsPath = [[dirs objectAtIndex:0] retain];
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
    
	return directoryPath;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
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
            NSLog(@"Load Camera(%@, %@, %@, %@, %d)", name, uid, view_acc, view_pwd, isFromCloud);
            
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
            
            [MyCamera loadCameraQVGA:tempCamera];
			
            [camera_list addObject:tempCamera];
            [tempCamera release];
        }
        
        [rs close];
    }
}

- (void)camStopShow {
    
    isCamStopShow = YES;
    
    for (int i=0;i<4;i++){
        
        MyCamera *testCamera = [cameraArray objectAtIndex:i];
        
        if (testCamera.uid!=nil){
            
            NSNumber *tempChannel = [channelArray objectAtIndex:i];
            
            if (testCamera.sessionState == CONNECTION_STATE_CONNECTED && [testCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
                testCamera.isShowInMultiView = NO;
                [testCamera stopShow:[tempChannel integerValue]];
                //[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                //[testCamera stopSoundToDevice:0];
                //[testCamera stopSoundToPhone:0];
            }
        }
    }
    
    self.vdo1.image = nil;
    self.vdo2.image = nil;
    self.vdo3.image = nil;
    self.vdo4.image = nil;
}

- (void)reStartShow {
    
    isCamStopShow = NO;
    
    for (int i=0;i<4;i++){
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid!=nil){
            
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

- (void)connectAndShow {
    for (int i=0;i<4;i++){
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid!=nil){
            
            NSNumber *tempChannel = [channelArray objectAtIndex:i];
            
            if (tempCamera.sessionState != CONNECTION_STATE_CONNECTED && [tempCamera getConnectionStateOfChannel:0] != CONNECTION_STATE_CONNECTED) {
                [tempCamera connect:tempCamera.uid];
                [tempCamera start:[tempChannel integerValue]];
            }
            if(!isGoPlayEvent){
                tempCamera.isShowInMultiView = YES;
                [tempCamera startShow:[tempChannel integerValue] ScreenObject:self];
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
    [self goAddCamera:sender];
    
    return;
    [self camStopShow];
    
    DropboxSettingVC *controller = [[DropboxSettingVC alloc] initWithNibName:@"DropboxSettingVC" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)goInfo:(id)sender {
    
    [self camStopShow];
    
    AppInfoController *controller = [[AppInfoController alloc]  initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)logOut:(id)sender {
    
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
    
    [self camStopShow];
    
    CameraListForLiveViewController *controller = [[CameraListForLiveViewController alloc] initWithNibName:@"CameraList" bundle:nil];
    
    viewTag = [(UIView*)sender tag];
    
    controller.viewTag = [[NSNumber alloc] initWithInteger:[(UIView*)sender tag]];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)reConnect:(id)sender {
    
    MyCamera *tempCamera = [cameraArray objectAtIndex:[(UIView*)sender tag]];
    NSNumber *tempChannel = [channelArray objectAtIndex:[(UIView*)sender tag]];
    
    [tempCamera stop:[tempChannel integerValue]];
    [tempCamera disconnect];
    [tempCamera connect:tempCamera.uid];
    [tempCamera start:[tempChannel integerValue]];
    if(!isGoPlayEvent){
        [tempCamera startShow:[tempChannel integerValue] ScreenObject:self];
    }
    tempCamera.delegate2 = self;
}

- (IBAction)moreFunction:(id)sender {
    
    moreFunctionTag = [[NSNumber alloc] initWithInt:[(UIView*)sender tag]];
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
    
    [UIView beginAnimations:@"imageViewSmall" context:nil];
    [UIView setAnimationDuration:0.2];
    [moreFunctionView setAlpha:0.0];
    CGAffineTransform newTransform =  CGAffineTransformScale(moreFunctionView.transform, 0.1, 0.1);
    [moreFunctionView setTransform:newTransform];
    [UIView commitAnimations];
    
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:0.2];
}

- (void)hideAnimation{
    
    moreFunctionView.hidden = YES;
}


- (IBAction)goLiveView:(id)sender {
    
    [self camStopShow];
    
    MyCamera *tempCamera = [cameraArray objectAtIndex:[(UIView*)sender tag]];
    int channel = [[channelArray objectAtIndex:[(UIView*)sender tag]] integerValue];
    
    switch ([(UIView*)sender tag]) {
        case 0:
            self.vdo1.image = nil;
            break;
        case 1:
            self.vdo2.image = nil;
            break;
        case 2:
            self.vdo3.image = nil;
            break;
        case 3:
            self.vdo4.image = nil;
            break;
    }
    
    CameraLiveViewController *controller = [[CameraLiveViewController alloc] initWithNibName:@"CameraLiveView" bundle:nil];
    controller.camera = tempCamera;
    controller.viewTag = [NSNumber numberWithInteger:[(UIView*)sender tag]];
    controller.delegate = self;
    controller.selectedChannel = channel;
    
    UINavigationController *customNavController = [[cCustomNavigationController alloc] init];
    [self presentViewController:customNavController animated:YES completion:nil];
    [customNavController pushViewController:controller animated:YES];
    
    [controller release];
}

- (IBAction)changeViewSetting:(id)sender {
    
    [self camStopShow];
    
    CameraListForLiveViewController *controller = [[CameraListForLiveViewController alloc] initWithNibName:@"CameraList" bundle:nil];
    controller.viewTag = moreFunctionTag;
    controller.delegate = self;
    controller->isFromChange = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    [self hideMoreFunctionView:nil];
}

- (IBAction)goEventList:(id)sender {
    
    isGoPlayEvent=YES;
    
    [self camStopShow];
    
    EventListController *controller = [[EventListController alloc] initWithStyle:UITableViewStylePlain];
    NSLog(@"TAG:%@",moreFunctionTag);
    MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag integerValue]];
    controller.camera = cameraIdx;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
    [self hideMoreFunctionView:nil];
}

- (IBAction)goSnapshot:(id)sender {
    
    [self camStopShow];
    
    MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag integerValue]];
    int channel = [[channelArray objectAtIndex:[moreFunctionTag integerValue]] integerValue];
    
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
}

- (IBAction)goSetting:(id)sender {
    
    [self camStopShow];
    
    [self hideMoreFunctionView:nil];
    
    MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag integerValue]];
    
    EditCameraDefaultController *controller = [[EditCameraDefaultController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.camera = cameraIdx;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)deleteViewSetting:(id)sender {
    
    isDelete = YES;
    
    NSString *msg = NSLocalizedString(@"Sure to remove this view?", @"");
    NSString *no = NSLocalizedString(@"NO", @"");
    NSString *yes = NSLocalizedString(@"YES", @"");
    NSString *caution = NSLocalizedString(@"Caution!", @"");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:caution message:msg delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
    [alert show];
    [alert release];
}

#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        isDelete = NO;
        isLogOut = NO;
    } else if (buttonIndex == 1 && isDelete) {
        
        isDelete = NO;
        
        MyCamera *cameraIdx = [cameraArray objectAtIndex:[moreFunctionTag integerValue]];
        
        int checkRepeat = 0;
        
        for (int i=0;i<4;i++) {
            
            MyCamera *tempCamera = [cameraArray objectAtIndex:i];
            
            if (tempCamera.uid!=nil && [cameraIdx.uid isEqualToString:tempCamera.uid] && [channelArray objectAtIndex:[moreFunctionTag integerValue]]==[channelArray objectAtIndex:i]) {
                checkRepeat++;
            }
        }
        
        MyCamera *defaultCamera = [[MyCamera alloc] init];
        NSNumber *defaultChannel = [NSNumber numberWithInt:-1];
        
        if (checkRepeat==1){
            [cameraIdx stopShow:[[channelArray objectAtIndex:[moreFunctionTag integerValue]] integerValue]];
            [cameraIdx ipcamStop:[[channelArray objectAtIndex:[moreFunctionTag integerValue]] integerValue]];
        }
        
        [cameraArray replaceObjectAtIndex:[moreFunctionTag integerValue] withObject:defaultCamera];
        [channelArray replaceObjectAtIndex:[moreFunctionTag integerValue] withObject:defaultChannel];
        
        switch ([moreFunctionTag integerValue]) {
            case 0:
                self.vdo1.image = nil;
                reConnectBTN1.hidden = YES;
                break;
            case 1:
                self.vdo2.image = nil;
                reConnectBTN2.hidden = YES;
                break;
            case 2:
                self.vdo3.image = nil;
                reConnectBTN3.hidden = YES;
                break;
            case 3:
                self.vdo4.image = nil;
                reConnectBTN4.hidden = YES;
                break;
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //將資料回步回手機
        [userDefaults setObject:nil forKey:[[NSString alloc] initWithFormat:@"CameraMultiSetting_%@",moreFunctionTag]];
        [userDefaults setInteger:-1 forKey:[[NSString alloc] initWithFormat:@"ChannelMultiSetting_%@",moreFunctionTag]];
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
        [userDefaults setObject:@"" forKey:[[NSString alloc] initWithString:@"cloudUserPassword"]];
        [userDefaults synchronize];
        
        NSString *msg = NSLocalizedString(@"Log out success!", @"");
        NSString *ok = NSLocalizedString(@"OK", @"");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        //[logInOut setTitle:NSLocalizedString(@"Log in",@"") forState:UIControlStateNormal];
        
        isLogOut = NO;
    
    } else if (buttonIndex == 1 && !isLogOut) {
        
        StartViewController *controller = [[StartViewController alloc] initWithNibName:@"StartView" bundle:nil];
        controller->isFromMCV = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - View lifecycle
- (void)dealloc
{
    [connModeImageView release];
    [directoryPath release];
    
    [_vdo1 release];
    [_vdo2 release];
    [_vdo3 release];
    [_vdo4 release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    //设置功能键位置
    //居中
    moreFunctionView.frame=CGRectMake(self.view.frame.size.width/2-moreFunctionView.frame.size.width/2, self.view.frame.size.height/2-moreFunctionView.frame.size.height/2, moreFunctionView.frame.size.width, moreFunctionView.frame.size.height);
    
    if(isGoPlayEvent){
        isGoPlayEvent=NO;
    }
    
    if (isCamStopShow) {
        [self reStartShow];
    }
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
    
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_logo.png"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
    
    if (cameraArray!=nil){
        for ( MyCamera *tempCamera in cameraArray){
            tempCamera.delegate2 = self;
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]||[userDefaults objectForKey:@"cloudUserPassword"]==nil){
        //[logInOut setTitle:NSLocalizedString(@"Log in", @"") forState:UIControlStateNormal];
    } else {
        //[logInOut setTitle:NSLocalizedString(@"Log out", @"") forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectAndShow) name:@"WiFiChanged" object:nil];
    

}

- (void)checkStatus {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    MyCamera *defaultCam = [[MyCamera alloc] init];
    NSNumber *defaultChannel = [NSNumber numberWithInt:-1];
    cameraArray = [[NSMutableArray alloc] init];
    channelArray = [[NSMutableArray alloc] init];
    
    for (int i=0;i<4;i++) {
        if ([userDefaults objectForKey:[[NSString alloc] initWithFormat:@"CameraMultiSetting_%d",i]]) {
            
            int cameraChecked = 0;
            
            for (MyCamera *tempCamera in camera_list) {
                if ([tempCamera.uid isEqualToString:[userDefaults objectForKey:[[NSString alloc] initWithFormat:@"CameraMultiSetting_%d",i]]]){
                    [cameraArray addObject:tempCamera];
                    NSLog(@"UID:%@",tempCamera.uid);
                    break;
                }
                
                cameraChecked++;
            }
            
            if (cameraChecked==4) {
                [cameraArray addObject:defaultCam];
            }
        } else {
            [cameraArray addObject:defaultCam];
        }
        
        if ([userDefaults objectForKey:[[NSString alloc] initWithFormat:@"ChannelMultiSetting_%d",i]]) {
            
            [channelArray addObject:[userDefaults objectForKey:[[NSString alloc] initWithFormat:@"ChannelMultiSetting_%d",i]]];
        } else {
            [channelArray addObject:defaultChannel];
        }
    }
    
    for (int i=0;i<4;i++) {
        if([cameraArray count]<i+1){
            break;
        }
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if([[channelArray objectAtIndex:i] intValue]!=-1){
            switch (i) {
                case 0:
                    [defaultButton1 setHidden:YES];
                    [statusBar1 setHidden:NO];
                    [moreFunction1 setHidden:NO];
                    cameraName1.text = tempCamera.name;
                    cameraName1.font = [UIFont systemFontOfSize:12.0f];
                    cameraName1.textColor = [UIColor whiteColor];
                    break;
                case 1:
                    [defaultButton2 setHidden:YES];
                    [statusBar2 setHidden:NO];
                    [moreFunction2 setHidden:NO];
                    cameraName2.text = tempCamera.name;
                    cameraName2.font = [UIFont systemFontOfSize:12.0f];
                    cameraName2.textColor = [UIColor whiteColor];
                    break;
                case 2:
                    [defaultButton3 setHidden:YES];
                    [statusBar3 setHidden:NO];
                    [moreFunction3 setHidden:NO];
                    cameraName3.text = tempCamera.name;
                    cameraName3.font = [UIFont systemFontOfSize:12.0f];
                    cameraName3.textColor = [UIColor whiteColor];
                    break;
                case 3:
                    [defaultButton4 setHidden:YES];
                    [statusBar4 setHidden:NO];
                    [moreFunction4 setHidden:NO];
                    cameraName4.text = tempCamera.name;
                    cameraName4.font = [UIFont systemFontOfSize:12.0f];
                    cameraName4.textColor = [UIColor whiteColor];
                    break;
            }
            
        } else {
            switch (i) {
                case 0:
                    [defaultButton1 setHidden:NO];
                    [statusBar1 setHidden:YES];
                    [moreFunction1 setHidden:YES];
                    break;
                case 1:
                    [defaultButton2 setHidden:NO];
                    [statusBar2 setHidden:YES];
                    [moreFunction2 setHidden:YES];
                    break;
                case 2:
                    [defaultButton3 setHidden:NO];
                    [statusBar3 setHidden:YES];
                    [moreFunction3 setHidden:YES];
                    break;
                case 3:
                    [defaultButton4 setHidden:NO];
                    [statusBar4 setHidden:YES];
                    [moreFunction4 setHidden:YES];
                    break;
            }
        }
    }
}

- (void)loadCamList {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    DeviceListOnCloud *dloc = [[DeviceListOnCloud alloc] init];
    dloc.delegate = self;
    
    NSString *userID = [[NSString alloc] initWithString:[userDefaults objectForKey:@"cloudUserID"]];
    NSString *userPWD = [[NSString alloc] initWithString:[userDefaults objectForKey:@"cloudUserPassword"]];
    [dloc downloadDeviceListID:userID PWD:userPWD];

}

- (void)viewDidLoad {
    isMoreSetOpen = NO;

    [self loadDeviceFromDatabase];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"cloudUserPassword"] && ![[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]){
        [self loadCamList];
    }
    
    [self checkStatus];
    
    [self connectAndShow];
    
    [dropboxRec setTitle:NSLocalizedString(@"Camera List", @"") forState:UIControlStateNormal];
    
    [infoBTN setTitle:NSLocalizedString(@"Information", @"") forState:UIControlStateNormal];
    
    [logInOut setTitle:NSLocalizedString(@"用户手册", @"") forState:UIControlStateNormal];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];

	
#ifndef MacGulp
    //self.navigationItem.title = NSLocalizedString(@"Live View", @"");
    //self.navigationItem.title = NSLocalizedString(@"P2PCamCEO", @"");
#else
    self.title = camera.name;
#endif
    
    
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
    
    
#ifdef MacGulp
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Reload", nil)
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(reload:)];
    self.navigationItem.rightBarButtonItem = reloadButton;
    [reloadButton release];
    
#endif
        
    wrongPwdRetryTime = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    [super viewDidLoad];

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
    [super viewWillDisappear:animated];
    
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_bk"];
    [self.navigationController.navigationBar setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationItem setPrompt:nil];
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
    for (int i=0;i<4;i++){
        
        MyCamera *testCamera = [cameraArray objectAtIndex:i];
        GLog( tUI|tReStartShow, (@"\t{applicationWillResignActive} [%d]@%p uid:%@", i, testCamera, (testCamera.uid != nil)?testCamera.uid : @"(nil)") );
        
        if (testCamera.uid!=nil){
            
            NSNumber *chNum = [channelArray objectAtIndex:i];
			int ch = [chNum integerValue];
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
    for (int i=0;i<4;i++){
        
        MyCamera *testCamera = [cameraArray objectAtIndex:i];
        GLog( tUI|tReStartShow, (@"\t{applicationDidBecomeActive} [%d]@%p uid:%@", i, testCamera, (testCamera.uid != nil)?testCamera.uid : @"(nil)") );
        if (testCamera.uid!=nil){
            
            NSNumber *chNum = [channelArray objectAtIndex:i];
			int ch = [chNum integerValue];
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

    @autoreleasepool
    {
        CIImage *ciImage = [arrs objectAtIndex:0];
        NSString *uid = [arrs objectAtIndex:1];
        NSNumber *channel = [arrs objectAtIndex:2];
        
        //UIImageOrientationLeft UIImageOrientationUp UIImageOrientationRight
        UIImage *img = [UIImage imageWithCIImage:ciImage scale:0.8 orientation:UIImageOrientationUp];
        //[ciImage release];

        for (int i=0;i<4;i++) {
            MyCamera *cameraIdx = [cameraArray objectAtIndex:i];
            NSNumber *channelIdx = [channelArray objectAtIndex:i];
            if ([cameraIdx.uid isEqualToString:uid] && channelIdx == channel){
                switch(i){
                    case 0:
                        self.vdo1.image = img ;
                        break;
                    case 1:
                        self.vdo2.image = img ;
                        break;
                    case 2:
                        self.vdo3.image = img ;
                        break;
                    case 3:
                        self.vdo4.image = img ;
                        break;
                }
            }
        }
    }
}

- (void)updateToScreen:(NSValue*)pointer
{
    LPSIMAGEBUFFINFO pScreenBmpStore = (LPSIMAGEBUFFINFO)[pointer pointerValue];
    
    //	[glView renderVideo:pScreenBmpStore->pixelBuff];
    
    int width = (int)CVPixelBufferGetWidth(pScreenBmpStore->pixelBuff);
    int height = (int)CVPixelBufferGetHeight(pScreenBmpStore->pixelBuff);
    mSizePixelBuffer = CGSizeMake( width, height );
    [glView renderVideo:pScreenBmpStore->pixelBuff];
}


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
    float fScale  = [[UIScreen mainScreen] scale];
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
	while( true) {
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
        
        for (int i=0;i<4;i++) {
            MyCamera *tempCamera  = [cameraArray objectAtIndex:i];
            
            if ([tempCamera.uid isEqualToString:camera_.uid]) {
                
                switch (i) {
                    case 0:
                        cameraConnect1.image = [UIImage imageNamed:@"online"];
                        cameraStatus1.text = @"";
                        reConnectBTN1.hidden = YES;
                        break;
                    case 1:
                        cameraConnect2.image = [UIImage imageNamed:@"online"];
                        cameraStatus2.text = @"";
                        reConnectBTN2.hidden = YES;
                        break;
                    case 2:
                        cameraConnect3.image = [UIImage imageNamed:@"online"];
                        cameraStatus3.text = @"";
                        reConnectBTN3.hidden = YES;
                        break;
                    case 3:
                        cameraConnect4.image = [UIImage imageNamed:@"online"];
                        cameraStatus4.text = @"";
                        reConnectBTN4.hidden = YES;
                        break;
                    default:
                        break;
                }
            }
        }
    } else if (status == CONNECTION_STATE_TIMEOUT && isWaitReConnect) {
        
        if (camNeedReconnect == camera_) {
            [camNeedReconnect stop:camNeedReconnect.lastChannel];
            [camNeedReconnect disconnect];
            [camNeedReconnect connect:camNeedReconnect.uid];
            [camNeedReconnect start:camNeedReconnect.lastChannel];
            if(!isGoPlayEvent){
                [camNeedReconnect startShow:camNeedReconnect.lastChannel ScreenObject:self];
            }
            camNeedReconnect.delegate2 = self;
        }
    }
}

- (void)camera:(MyCamera *)camera_ _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status {
    
    if (status == CONNECTION_STATE_TIMEOUT) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera_ stop:channel];
            
            usleep(500 * 1000);
            
            [camera_ disconnect];
        });
    } else {
        
        if (status == CONNECTION_STATE_CONNECTED){
            
            for (int i=0;i<4;i++) {
                MyCamera *tempCamera  = [cameraArray objectAtIndex:i];
                
                if ([tempCamera.uid isEqualToString:camera_.uid]) {
                    
                    switch (i) {
                        case 0:
                            cameraConnect1.image = [UIImage imageNamed:@"online"];
                            cameraStatus1.text = @"";
                            reConnectBTN1.hidden = YES;
                            break;
                        case 1:
                            cameraConnect2.image = [UIImage imageNamed:@"online"];
                            cameraStatus2.text = @"";
                            reConnectBTN2.hidden = YES;
                            break;
                        case 2:
                            cameraConnect3.image = [UIImage imageNamed:@"online"];
                            cameraStatus3.text = @"";
                            reConnectBTN3.hidden = YES;
                            break;
                        case 3:
                            cameraConnect4.image = [UIImage imageNamed:@"online"];
                            cameraStatus4.text = @"";
                            reConnectBTN4.hidden = YES;
                            break;
                        default:
                            break;
                    }
                }
            }
        } else {
        
        
        for (int i=0;i<4;i++) {
            MyCamera *tempCamera = [cameraArray objectAtIndex:i];
            if ([tempCamera.uid isEqualToString:camera_.uid]){
                switch (i) {
                    case 0:
                        cameraConnect1.image = [UIImage imageNamed:@"offline"];
                        self.vdo1.image = nil;
                        if (status==CONNECTION_STATE_CONNECTING){
                            cameraStatus1.text = NSLocalizedString(@"Wait for connecting...", @"");
                        } else {
                            reConnectBTN1.hidden = NO;

                            if (status==CONNECTION_STATE_UNKNOWN_DEVICE){
                                cameraStatus1.text = NSLocalizedString(@"Unknown Device", @"");
                            } else if (status==CONNECTION_STATE_WRONG_PASSWORD){
                                cameraStatus1.text = NSLocalizedString(@"Wrong Password", @"");
                            } else if (status==CONNECTION_STATE_TIMEOUT){
                                cameraStatus1.text = NSLocalizedString(@"Timeout", @"");
                            } else if (status==CONNECTION_STATE_UNSUPPORTED){
                                cameraStatus1.text = NSLocalizedString(@"Not Supported", @"");
                            } else if (status==CONNECTION_STATE_CONNECT_FAILED){
                                cameraStatus1.text = NSLocalizedString(@"Connect Failed", @"");
                            }
                        }
                        break;
                    case 1:
                        cameraConnect2.image = [UIImage imageNamed:@"offline"];
                        self.vdo2.image = nil;
                        if (status==CONNECTION_STATE_CONNECTING){
                            cameraStatus2.text = NSLocalizedString(@"Wait for connecting...", @"");
                        } else {
                            reConnectBTN2.hidden = NO;
                            
                            if (status==CONNECTION_STATE_UNKNOWN_DEVICE){
                                cameraStatus2.text = NSLocalizedString(@"Unknown Device", @"");
                            } else if (status==CONNECTION_STATE_WRONG_PASSWORD){
                                cameraStatus2.text = NSLocalizedString(@"Wrong Password", @"");
                            } else if (status==CONNECTION_STATE_TIMEOUT){
                                cameraStatus2.text = NSLocalizedString(@"Timeout", @"");
                            } else if (status==CONNECTION_STATE_UNSUPPORTED){
                                cameraStatus2.text = NSLocalizedString(@"Not Supported", @"");
                            } else if (status==CONNECTION_STATE_CONNECT_FAILED){
                                cameraStatus2.text = NSLocalizedString(@"Connect Failed", @"");
                            }
                        }
                        break;
                    case 2:
                        cameraConnect3.image = [UIImage imageNamed:@"offline"];
                        self.vdo3.image = nil;
                        if (status==CONNECTION_STATE_CONNECTING){
                            cameraStatus3.text = NSLocalizedString(@"Wait for connecting...", @"");
                        } else {
                            reConnectBTN3.hidden = NO;
                            
                            if (status==CONNECTION_STATE_UNKNOWN_DEVICE){
                                cameraStatus3.text = NSLocalizedString(@"Unknown Device", @"");
                            } else if (status==CONNECTION_STATE_WRONG_PASSWORD){
                                cameraStatus3.text = NSLocalizedString(@"Wrong Password", @"");
                            } else if (status==CONNECTION_STATE_TIMEOUT){
                                cameraStatus3.text = NSLocalizedString(@"Timeout", @"");
                            } else if (status==CONNECTION_STATE_UNSUPPORTED){
                                cameraStatus3.text = NSLocalizedString(@"Not Supported", @"");
                            } else if (status==CONNECTION_STATE_CONNECT_FAILED){
                                cameraStatus3.text = NSLocalizedString(@"Connect Failed", @"");
                            }
                        }
                        break;
                    case 3:
                        cameraConnect4.image = [UIImage imageNamed:@"offline"];
                        self.vdo4.image = nil;
                        if (status==CONNECTION_STATE_CONNECTING){
                            cameraStatus4.text = NSLocalizedString(@"Wait for connecting...", @"");
                        } else {
                            reConnectBTN4.hidden = NO;
                            
                            if (status==CONNECTION_STATE_UNKNOWN_DEVICE){
                                cameraStatus4.text = NSLocalizedString(@"Unknown Device", @"");
                            } else if (status==CONNECTION_STATE_WRONG_PASSWORD){
                                cameraStatus4.text = NSLocalizedString(@"Wrong Password", @"");
                            } else if (status==CONNECTION_STATE_TIMEOUT){
                                cameraStatus4.text = NSLocalizedString(@"Timeout", @"");
                            } else if (status==CONNECTION_STATE_UNSUPPORTED){
                                cameraStatus4.text = NSLocalizedString(@"Not Supported", @"");
                            } else if (status==CONNECTION_STATE_CONNECT_FAILED){
                                cameraStatus4.text = NSLocalizedString(@"Connect Failed", @"");
                            }
                        }
                        break;
                }
            }
        }
        }
    }
}

#pragma mark - CameraLive Delegate
- (void)didReStartCamera:(MyCamera *)tempCamera_ cameraChannel:(NSNumber *)channel withView:(NSNumber *)tag{
    
    [channelArray replaceObjectAtIndex:[tag integerValue] withObject:channel];

    for (int i=0;i<4;i++){
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid!=nil && [tempCamera.uid isEqualToString:tempCamera_.uid]){
            
            NSNumber *tempChannel = [channelArray objectAtIndex:i];
            
            [tempCamera connect:tempCamera.uid];
            [tempCamera start:[tempChannel integerValue]];
            if(!isGoPlayEvent){
                [tempCamera startShow:[tempChannel integerValue] ScreenObject:self];
            }
            tempCamera.delegate2 = self;
        }
    }
}

#pragma mark - CameraList Delegate
- (void)didAddCamera:(MyCamera *)tempCamera cameraChannel:(NSNumber *)channel withView:(NSNumber *)tag {
    
    NSNumber *tempChannel = 0;
    
    [self checkStatus];
    if(!isGoPlayEvent){
        [tempCamera startShow:[tempChannel integerValue] ScreenObject:self];
    }
    
    tempCamera.delegate2 = self;
    
    if (tempCamera.sessionState == CONNECTION_STATE_CONNECTED && [tempCamera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
        switch ([tag integerValue]) {
            case 0:
                cameraConnect1.image = [UIImage imageNamed:@"online"];
                cameraStatus1.text = @"";
                reConnectBTN1.hidden = YES;
                break;
            case 1:
                cameraConnect2.image = [UIImage imageNamed:@"online"];
                cameraStatus2.text = @"";
                reConnectBTN2.hidden = YES;
                break;
            case 2:
                cameraConnect3.image = [UIImage imageNamed:@"online"];
                cameraStatus3.text = @"";
                reConnectBTN3.hidden = YES;
                break;
            case 3:
                cameraConnect4.image = [UIImage imageNamed:@"online"];
                cameraStatus4.text = @"";
                reConnectBTN4.hidden = YES;
                break;
            default:
                break;
        }
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
    [camera_ setSync:[[NSNumber numberWithBool:isSync] integerValue]];
    [camera_ setCloud:[[NSNumber numberWithBool:isFromCloud] integerValue]];
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
#ifndef DEF_APNSTest
            NSString *hostString = @"http://push.iotcplatform.com/apns/apns.php";
#else
			NSString *hostString = @"http://54.225.191.150/test_gcm/apns.php"; //測試Host
#endif
            NSString *argsString = @"%@?cmd=reg_mapping&token=%@&uid=%@&appid=%@&udid=%@&os=ios";
            NSString *getURLString = [NSString stringWithFormat:argsString, hostString, deviceTokenString, UID, appidString , uuid];
#ifdef DEF_APNSTest
			NSLog( @"==============================================");
			NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
			NSLog( @"==============================================");
#endif
            [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
#ifdef DEF_APNSTest
			NSLog( @"==============================================");
            NSLog( @">>> %@", registerResult);
			NSLog( @"==============================================");
#endif
        }
    });
    
    //將資料回步回手機
    [userDefaults setObject:camera_.uid forKey:[[NSString alloc] initWithFormat:@"CameraMultiSetting_%d",viewTag]];
    [userDefaults setInteger:0 forKey:[[NSString alloc] initWithFormat:@"ChannelMultiSetting_%d",viewTag]];
    [userDefaults synchronize];
    
    [self didAddCamera:camera_ cameraChannel:0 withView:[NSNumber numberWithInt:viewTag]];
    
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
    
    MyCamera *defaultCamera = [[MyCamera alloc] init];
    NSNumber *defaultChannel = [NSNumber numberWithInt:-1];
    
    for (int i=0;i<4;i++) {
        
        MyCamera *tempCamera = [cameraArray objectAtIndex:i];
        
        if (tempCamera.uid!=nil && [uid isEqualToString:tempCamera.uid]) {
            [tempCamera stopShow:[[channelArray objectAtIndex:i] integerValue]];
            [tempCamera ipcamStop:[[channelArray objectAtIndex:i] integerValue]];
            [cameraArray replaceObjectAtIndex:i withObject:defaultCamera];
            [channelArray replaceObjectAtIndex:i withObject:defaultChannel];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            //將資料回步回手機
            [userDefaults setObject:nil forKey:[[NSString alloc] initWithFormat:@"CameraMultiSetting_%d",i]];
            [userDefaults setInteger:-1 forKey:[[NSString alloc] initWithFormat:@"ChannelMultiSetting_%d", i]];
            [userDefaults synchronize];
            
            switch (i) {
                case 0:
                    self.vdo1.image = nil;
                    reConnectBTN1.hidden = YES;
                    break;
                case 1:
                    self.vdo2.image = nil;
                    reConnectBTN2.hidden = YES;
                    break;
                case 2:
                    self.vdo3.image = nil;
                    reConnectBTN3.hidden = YES;
                    break;
                case 3:
                    self.vdo4.image = nil;
                    reConnectBTN4.hidden = YES;
                    break;
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
    NSString *uid = removedCamera.uid;
 
    [removedCamera stop:0];
    [removedCamera disconnect];

    [camera_list removeObject:removedCamera];
    
    [self deleteSameUIDView:uid];
    
    if (uid != nil) {
        
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
#ifndef DEF_APNSTest
                NSString *hostString = @"http://push.iotcplatform.com/apns/apns.php";
#else
				NSString *hostString = @"http://54.225.191.150/test_gcm/apns.php"; //測試Host
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
    
	NSNumber *tempChannel = [channelArray objectAtIndex:[moreFunctionTag integerValue]];
	if( changedCamera.sessionState == CONNECTION_STATE_DISCONNECTED ) {
        [changedCamera stop:0];
        [changedCamera disconnect];

        [changedCamera connect:changedCamera.uid];
        [changedCamera start:[tempChannel integerValue]];
    }
    if(!isGoPlayEvent){
        [changedCamera startShow:[tempChannel integerValue] ScreenObject:self];
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
    
    [self checkStatus];
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
//    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
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

@end
