//
//  AppDelegate.m
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CheckNetwork.h"
#import <DropboxSDK/DropboxSDK.h>
#import "AppInfoController.h"
#import "StartViewController.h"
#import "CameraMultiLiveViewController.h"
#import <IOTCamera/GLog.h>
#import <IOTCamera/GLogZone.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "IQKeyboardManager.h"
#if defined(EasynPTarget)
#import <FIR/FIR.h>
//NSString *g_tpnsHostString = @"http://push1.ipcam.hk/apns/apns.php";
#else
//NSString *g_tpnsHostString = @"http://push.iotcplatform.com/apns/apns.php";
#endif
NSString *g_tpnsHostString = @"http://push1.ipcam.hk/apns/apns.php";

NSMutableArray *camera_list;
FMDatabase *database;
NSString *deviceTokenString;

NSString *const kApplicationDidEnterBackground = @"Application_Did_Enter_Background";
NSString *const kApplicationWillEnterForeground = @"Application_Will_Enter_Foreground";
NSString *const kApplicationDidEnterForeground = @"Application_Did_Enter_Foreground";

#ifdef SUPPORT_DROPBOX
@interface AppDelegate () <DBSessionDelegate, DBNetworkRequestDelegate>
#else
@interface AppDelegate ()
#endif
{
    NSString *relinkUserId;
}

@end

@implementation AppDelegate

@synthesize mOpenUrlCmdStore;
@synthesize rootViewController = _rootViewController;
@synthesize window = _window;
@synthesize ssid;


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window

{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskPortrait |UIInterfaceOrientationMaskLandscapeLeft |UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait |UIInterfaceOrientationMaskLandscapeLeft |UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation

{
    return UIInterfaceOrientationPortrait;
}


-(void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {}
-(void)networkRequestStarted{}
-(void)networkRequestStopped{}

+ (NSString *) pathForDocumentsResource:(NSString *) relativePath
{
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[[dirs objectAtIndex:0]stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

-(id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

#pragma mark - Application Lifecycle Methods
- (void)dealloc {
    
    [_rootViewController release];
    [_window release];
    [super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSDictionary *ifs = [self fetchSSIDInfo];
    ssid = [[ifs objectForKey:@"SSID"] copy];
    NSLog(@"SSID:%@",ssid);
    
    //將task丟至背景執行
    oldTaskId = UIBackgroundTaskInvalid;
    oldTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{        
//    /*
//     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
//     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//     */
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidEnterBackground object:nil];
//    
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//    
////#define RunningBackground_Test
//    
//#ifdef RunningBackground_Test
//    
//    [MyCamera uninitIOTC];
//    
//#endif
//    
//    NSLog(@"***** %s", __func__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    /*
//     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//     */
//    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationWillEnterForeground object:nil];
//    
//    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//    
//#ifdef RunningBackground_Test
//    
//    [MyCamera initIOTC];
//
//    [camera_list removeAllObjects];
//
//    [self loadDeviceFromDatabase];
//    
//#endif
//    
//    NSLog(@"***** %s", __func__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{    
    //回到前景結束背景執行的task
    if (oldTaskId!= UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask: oldTaskId];
    }
    
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *tempSSID = [ifs objectForKey:@"SSID"];
    NSLog(@"SSID1:%@",ssid);
    NSLog(@"SSID2:%@",tempSSID);
    if (![tempSSID isEqualToString:ssid]) {
        //發出重連通知給multiview or liveview
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WiFiChanged" object:nil];
    }
    
//	switch( self.mOpenUrlCmdStore.cmd ) {
//		
//		case emShowTabIndexPage: {
//			if( 0 <= mOpenUrlCmdStore.tabIdx && mOpenUrlCmdStore.tabIdx < 4 ) {
//				[_rootViewController setSelectedIndex:mOpenUrlCmdStore.tabIdx];
//				[self urlCommandDone];
//			}
//		}	break;
//		case emAddDeviceByUID: {
//			[_rootViewController setSelectedIndex:2];
//		}	break;
//		case emShowLiveViewByUID: {
//			
//			int i=0;
//			for (Camera *cam in camera_list) {
//				if( 0 == [cam.uid compare:[NSString stringWithFormat:@"%s",mOpenUrlCmdStore.uid]] ) {
//					mOpenUrlCmdStore.tabIdx = i;
//					break;
//				}
//				i++;
//			}
//			[_rootViewController setSelectedIndex:0];
//		}	break;
//		default:
//			break;
//			
//	}

}

- (void)applicationWillTerminate:(UIApplication *) application{}

-(NSString *)getLangCode {
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"zh_TW", @"zh-Hant", @"en_US", @"en", @"fr_FR", @"fr",
                          @"de_DE", @"de", @"zh_CN", @"zh-Hans", @"ja_JP", @"ja",
                          @"nl_NL", @"nl", @"it_IT", @"it", @"es_ES", @"es",nil];
    
    NSString *code = [dict objectForKey:[languages objectAtIndex:0]];
    if ( nil == code) {
        code = @"en_US" ;
    }
    
    return code ;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if defined(EasynPTarget)
    [FIR handleCrashWithKey:@"68a7098718930bfdd0d6d07211438f66"]; 
#endif
	
	//g_dwGLogZoneSeed = tCtrl_MSK|tReStartShow_MSK;
	
	unsigned int version = [Camera getIOTCamerVersion];
	unsigned char v[4] = {0};
	v[3] = (char)version;
	v[2] = (char)(version >> 8);
	v[1] = (char)(version >> 16);
	v[0] = (char)(version >> 24);
	NSString* strIOTCameraVersionString = [NSString stringWithFormat:@"%d.%d.%d.%d", v[0], v[1], v[2], v[3]];
	GLog( tAll, (@"============================================="));
	GLog( tAll, (@"IOTCamera version: %@", strIOTCameraVersionString) );
	GLog( tAll, (@"============================================="));
		
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
#ifdef SUPPORT_DROPBOX
	// Set these variables before launching the app
    NSString* appKey = @"zo6kr8w12onxr8c";
	NSString* appSecret = @"0xjdiq7mrprnsat";
	NSString *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
#endif
    
#if 0 // dropbox debug
    NSString* errorMsg = nil;
	if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
	} else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
	} else if ([root length] == 0) {
		errorMsg = @"Set your root to use either App Folder of full Dropbox";
	} else {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
		NSDictionary *loadedPlist =
        [NSPropertyListSerialization
         propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
		NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
		if ([scheme isEqual:@"db-APP_KEY"]) {
			errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
		}
	}

    //NSString* errorMsg = nil;
	if (errorMsg != nil) {
		[[[[UIAlertView alloc]
		   initWithTitle:@"Error Configuring Session" message:errorMsg
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		  autorelease]
		 show];
	}
#endif

    
#ifdef SUPPORT_DROPBOX
    DBSession* session =
    [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
    [session release];
	
	[DBRequest setNetworkRequestDelegate:self];
#endif
    
    /* Appearance Setting */
    UIImage *navigationbarBG = [UIImage imageNamed:@"title_bk"];
    UIImage *navigationbarBGWithPrompt = [UIImage imageNamed:@"dvr_title2.png"];
    
    UINavigationBar *navigation = [UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil];
    
    [navigation setBackgroundImage:navigationbarBG forBarMetrics:UIBarMetricsDefault];
    [navigation setBackgroundImage:navigationbarBGWithPrompt forBarMetrics:UIBarMetricsDefaultPrompt];
    [navigation setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0f]}];
    [navigation setTintColor:[UIColor colorWithRed:177.0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f]];
    
    UIToolbar *toolbar = [UIToolbar appearance];
    [toolbar setBackgroundImage:[UIImage imageNamed:@"function_bar"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
         
    [self openDatabase];
    [self createTable];
    
    //迁移图片／录像Statrt
    FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootDocPath=[documentsPaths objectAtIndex:0];
    while([rs next]) {
        NSString *filePath = [rs stringForColumn:@"file_path"];
        NSLog(@"%@", filePath);
        NSString *newFullPath=[AppDelegate pathForDocumentsResource:filePath];
        NSString *oldFullPath=[rootDocPath stringByAppendingPathComponent:filePath];
        if([fileManager fileExistsAtPath:oldFullPath]){
            [fileManager moveItemAtPath:oldFullPath toPath:newFullPath error:nil];
        }
    }
    [rs close];
    //迁移图片／录像END
    
    //注册推送通知
    if([[[UIDevice currentDevice]systemVersion] floatValue]>=8.0f){
        [[UIApplication sharedApplication]registerForRemoteNotifications];
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil];
        [application registerUserNotificationSettings:setting];
        application.applicationIconBadgeNumber = 0;
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
        application.applicationIconBadgeNumber = 0;
    }
		 
    camera_list = [[NSMutableArray alloc] init];
		 
    [MyCamera initIOTC];
		 
    NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *arr = [appidString componentsSeparatedByString:@"."];
    if( arr != nil && NSOrderedSame == [(NSString*)[arr objectAtIndex:[arr count]-1] compare:@"2"] ) {
        //g_bDiagnostic = TRUE;
        g_bDiagnostic = FALSE;
    }
    // handle notification(TPNS)
    if ([launchOptions count] > 0) {
        NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
        NSString *uid = [[remoteNotif objectForKey:@"aps"] objectForKey:@"uid"];
        if( uid ) {
            [_rootViewController setSelectedIndex:1];
            [self application:application didReceiveRemoteNotification:remoteNotif];
        }
    }
    mOpenUrlCmdStore.cmd = emNoCmd;
    
    
    CameraMultiLiveViewController *_startViewController = [[CameraMultiLiveViewController alloc] initWithNibName:@"CameraMultiLiveView" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_startViewController];
    [navigationController setNavigationBarHidden:YES];
    [_window setRootViewController:navigationController];
    [_window makeKeyAndVisible];
         
#ifndef SUPPORT_DROPBOX
    UIViewController *thisIsTheViewControllerIWantToSetNow;
    int indexForViewControllerYouWantToReplace = 3;
         
    thisIsTheViewControllerIWantToSetNow = [[AppInfoController alloc] initWithNibName:nil bundle:nil];
         
         
    NSMutableArray *tabbarViewControllers = [self.rootViewController.viewControllers mutableCopy];
    
    [tabbarViewControllers replaceObjectAtIndex:indexForViewControllerYouWantToReplace withObject:thisIsTheViewControllerIWantToSetNow];
         
    self.rootViewController.viewControllers = tabbarViewControllers;
         
    NSArray *items = self.rootViewController.tabBar.items;
    UITabBarItem *item = [items objectAtIndex:3];
    item.image = [UIImage imageNamed:@"info.png"];
    item.title = NSLocalizedString(@"App Info",@"");
    
    [tabbarViewControllers release];
    [thisIsTheViewControllerIWantToSetNow release];
#endif
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    return YES;
}

#pragma mark - Application Custom URL Schemes

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {
        return NO;
	}
    
    NSString *urlString = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
    if (!urlString)
        return NO;
    
    
    NSLog( @"%@, %@, %@, %@", [url scheme], [url host], [url path], [url query] );
    
    // dropbox schema
    if ( [urlString hasPrefix:@"db-"]){
        
#ifdef SUPPORT_DROPBOX
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            if ([[DBSession sharedSession] isLinked]) {
                
                NSLog(@"LINKED!");

                [[NSNotificationCenter defaultCenter] postNotificationName:@"Agree" object:nil];
                
            } else {
                
                NSLog(@"LINKED CANCEL!");
            }
        
        }
#endif
    }
	else if ( [urlString hasPrefix:@"p2pcamlive"]){
        
        NSInteger nPrefix_Len = [@"p2pcamlive://com.tutk.p2pcamlive?" length];
        NSString* strCheck = [urlString substringWithRange:NSMakeRange(0, nPrefix_Len)];
        
        BOOL bIsDiff = [strCheck compare:@"p2pcamlive://com.tutk.p2pcamlive?"/* options:NSCaseInsensitiveSearch*/];
        
        if( bIsDiff )
            return NO;
        
        NSString* strParse = [urlString substringFromIndex:nPrefix_Len];
        NSLog( @">>>>openURL parameter: %@", strParse );
        
        BOOL bContinueTest = TRUE;
        NSRange bingo;
        
        bingo = [strParse rangeOfString:@"tabIdx:" options:NSCaseInsensitiveSearch];
        if( bingo.length > 0 ) {
            NSString* strTabIdx = [strParse substringFromIndex:(bingo.location+bingo.length)];
            NSLog( @"\tstrTabIdx: %@", strTabIdx );
            
            mOpenUrlCmdStore.cmd = emShowTabIndexPage;
            mOpenUrlCmdStore.tabIdx = [strTabIdx intValue];
            
            bContinueTest = FALSE;
        }
        
        if( bContinueTest ) {
            bingo = [strParse rangeOfString:@"addDev:" options:NSCaseInsensitiveSearch];
            if( bingo.length > 0 ) {
                NSString* strDevUID = [strParse substringFromIndex:(bingo.location+bingo.length)];
                NSLog( @"\tstrDevUID: %@", strDevUID );
                
                mOpenUrlCmdStore.cmd = emAddDeviceByUID;
                strncpy( mOpenUrlCmdStore.uid, [strDevUID UTF8String], 20 );
                mOpenUrlCmdStore.uid[20] = 0;
                
                bContinueTest = FALSE;
            }
        }
        
        if( bContinueTest ) {
            bingo = [strParse rangeOfString:@"liveView:" options:NSCaseInsensitiveSearch];
            if( bingo.length > 0 ) {
                NSString* strToUID = [strParse substringFromIndex:(bingo.location+bingo.length)];
                NSLog( @"\tstrToUID: %@", strToUID );
                
                mOpenUrlCmdStore.cmd = emShowLiveViewByUID;
                strncpy( mOpenUrlCmdStore.uid, [strToUID UTF8String], 20 );
                mOpenUrlCmdStore.uid[20] = 0;
                
                //bContinueTest = FALSE;
            }
        }
    }
	return YES;
}

- (void) urlCommandDone
{
	mOpenUrlCmdStore.cmd = emNoCmd;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] 
             URLsForDirectory:NSDocumentDirectory 
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - TabBarNavigationController Delegate Methods
- (void)tabBarController:(UITabBarController *)tabBarController 
 didSelectViewController:(UIViewController *)viewController 
{    
    if (tabBarController.selectedIndex == 1) {        
        [[[[_rootViewController tabBar] items] objectAtIndex:1] 
         setBadgeValue:nil];
    }    
}

#pragma mark - NavigationBarController Delegate Methods
- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated 
{
}

#pragma mark - 设置文件夹不被备份
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - SQLite Methods

- (void)openDatabase 
{    
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //设置子目录，这些目录标记为不备份
    NSString *path=[documentsPaths objectAtIndex:0];
    NSString *dbPath=[path stringByAppendingPathComponent:NOTBACKUPDIR];
    //检查目录是否存在
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dbPath])
    {
        [fileManager createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self addSkipBackupAttributeToItemAtPath:dbPath];
    
    NSString *oldDatabaseFilePath=[path stringByAppendingPathComponent:@"database.sqlite"];
    NSString *databaseFilePath = [dbPath stringByAppendingPathComponent:@"database.sqlite"];
    
    //迁移数据库
    if([fileManager fileExistsAtPath:oldDatabaseFilePath]){
        [fileManager moveItemAtPath:oldDatabaseFilePath toPath:databaseFilePath error:nil];
    }
    
    database = [[FMDatabase alloc] initWithPath:databaseFilePath];
    
    if ([database open]) 
        NSLog(@"open sqlite db ok.");
}

- (void)closeDatabase 
{
    if (database != NULL) {
        [database close];
        [database release];
        NSLog(@"close sqlite db ok.");
    }
}

- (void)createTable 
{
    if (database != NULL) {        
        
        if (![database executeUpdate:SQLCMD_CREATE_TABLE_DEVICE]) NSLog(@"Can not create table device");
        if (![database executeUpdate:SQLCMD_CREATE_TABLE_SNAPSHOT]) NSLog(@"Can not create table snapshot");
		if (![database executeUpdate:SQLCMD_CREATE_TABLE_REMOVELST]) NSLog(@"Can not create table removelist");
        
        /* Edit here while table columns been modified */
        //if (![database columnExists:@"device" columnName:@""]) [database executeUpdate:@"ALTER TABLE device ADD COLUMN column-name column-type"];        
    }
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
            NSLog(@"Load Camera(%@, %@, %@, %@)", name, uid, view_acc, view_pwd);
            
            MyCamera *camera = [[MyCamera alloc] initWithName:name viewAccount:view_acc viewPassword:view_pwd];
            [camera setLastChannel:channel];
            [camera connect:uid];
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
			
            [camera_list addObject:camera];
            [camera release];
        }
        
        [rs close];
    }
    
#ifdef RunningBackground_Test
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (state == UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidEnterForeground object:nil];
    }
    
#endif
}
-(void)syncApiPosterUuId:(NSString*)uuId dev_token:(NSString*)dev_token{
    
    NSLog(@"syncApiPoster start!!!!!!!!!!!!!!!!!!!!!!!!");
    
    NSMutableArray *mapArr = [NSMutableArray array];
    
    FMResultSet *appointmentResults = [database executeQuery:@"SELECT dev_uid FROM device"];

    
    NSString *uid ;
    NSDictionary *dict;
    while([appointmentResults next]) {
        uid = [appointmentResults stringForColumn:@"dev_uid"];
        
        dict = @{@"uid": uid, @"interval": @"0"};   //@{"uid": uid, };
        [mapArr addObject:dict];
    }
    
    NSLog(@"%@",mapArr);
    
    NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
    NSString *hostString = g_tpnsHostString;
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:hostString]];
    
    NSDictionary *requestDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"sync",@"cmd",
                                 uuId, @"udid",
                                 dev_token, @"token",
                                 appidString,@"appid",
                                 @"ios",@"os",
                                 mapArr,@"map",
                                 nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestDic options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
}

- (void)deleteRemoveLstRecords {
	
    if (database != NULL) {
        
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        
        NSMutableArray *arrDelData = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM apnsremovelst"];
        
        while([rs next]) {
			NSString *uid = [rs stringForColumn:@"dev_uid"];
            [tempArr addObject:uid];
        }
        
        [rs close];
        
        NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
        
//        // unregister from apns server
//        dispatch_queue_t queue = dispatch_queue_create("apns-unreg_client", NULL);
//        dispatch_async(queue, ^{
        
            for (NSString *uid in tempArr){
                NSError *error = nil;
                NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
#ifndef DEF_APNSTest
                NSString *hostString = g_tpnsHostString;
#else
                NSString *hostString = g_tpnsHostString; //測試Host
#endif
                NSString *argsString = @"%@?cmd=unreg_mapping&uid=%@&appid=%@&udid=%@&os=ios";
                NSString *getURLString = [NSString stringWithFormat:argsString, hostString, uid, appidString, uuid];

                NSLog( @"==============================================");
                NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
                NSLog( @"==============================================");

                NSString *unregisterResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
                
                NSLog( @"==============================================");
                NSLog( @">>> %@", unregisterResult );
                NSLog( @"==============================================");
                if (error != NULL) {
                    NSLog(@"%@",[error localizedDescription]);
                } else {
                    [arrDelData addObject:uid];
                    NSLog(@"camera(%@) removed from apnsremovelst", uid);
                }
            }
        
            [tempArr release];

            for (NSString *uid in arrDelData){
                [database executeUpdate:@"DELETE FROM apnsremovelst where dev_uid=?", uid];
            }
            
            [arrDelData release];

//        });
//        dispatch_release(queue);
    }
}

- (void)application:(UIApplication *)application 
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{    
    NSString *inDeviceTokenStr = [deviceToken description];
    NSString *tokenString = [inDeviceTokenStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenString = [[NSString alloc] initWithString:tokenString];
    
    NSString *systemVer = [[UIDevice currentDevice] systemVersion] ;
    NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
    NSString *deviceType = [[UIDevice currentDevice] model];
    NSString *encodeUrl = [deviceType stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *langCode = [self getLangCode];
    
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
#ifndef DEF_APNSTest
        NSString *hostString = g_tpnsHostString;
#else
		NSString *hostString = g_tpnsHostString; //測試Host
#endif
#if DEBUG
        NSString *argsString = @"%@?cmd=reg_client&token=%@&appid=%@&dev=1&lang=%@&udid=%@&os=ios&osver=%@&appver=%@&model=%@";
#else
        NSString *argsString = @"%@?cmd=reg_client&token=%@&appid=%@&dev=0&lang=%@&udid=%@&os=ios&osver=%@&appver=%@&model=%@";
#endif
        NSString *getURLString = [NSString stringWithFormat:argsString, hostString, tokenString, appidString, langCode , uuid,  systemVer , appVer , encodeUrl];

		NSLog( @"==============================================");
		NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
		NSLog( @"==============================================");

        NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];

		NSLog( @"==============================================");
		NSLog( @">>> %@", registerResult );
		NSLog( @"==============================================");
        if (error != NULL) {
            NSLog(@"%@",[error localizedDescription]);
        }


            NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
        
    		if (database != NULL) {
			FMResultSet *rs = [database executeQuery:@"SELECT * FROM device"];
			int cnt = 0;
			while([rs next] && cnt++ < MAX_CAMERA_LIMIT) {
				
				NSString *uid = [rs stringForColumn:@"dev_uid"];

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
				else {

					NSLog( @"==============================================");
					NSLog( @">>> deviceTokenString is nil, re-mapping all devices NOT be executed!!!" );
					NSLog( @"==============================================");

				}
			}
			[rs close];
		}
		else {

			NSLog( @"==============================================");
			NSLog( @" database is nil!!!" );
			NSLog( @"==============================================");

		}
        [self syncApiPosterUuId:uuid dev_token:tokenString];
        [self deleteRemoveLstRecords];
        
        //get the dev_uid & interval then post a json to the server

    });
    
    dispatch_release(queue);
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to register, error: %@", error);
}

- (void)application:(UIApplication *)application 
didReceiveRemoteNotification:(NSDictionary *)userInfo {    
    
    [[[[_rootViewController tabBar] items] objectAtIndex:1] setBadgeValue:@"!"];
    
    NSString *uid = [[userInfo objectForKey:@"aps"] objectForKey:@"uid"];
    NSInteger eventType = (NSInteger)[[userInfo objectForKey:@"aps"] objectForKey:@"event_type"];
    NSInteger eventTime = (NSInteger)[[userInfo objectForKey:@"aps"] objectForKey:@"event_time"];
    
    for(MyCamera *camera in camera_list) {
        
        if ([camera.uid isEqualToString:uid]) {            
            [camera setRemoteNotification:eventType EventTime:eventTime];
            break;
        }
    }
    
    NSLog(@"didReceiveRemoteNotification:event:%d from uid:%@ at %d", eventType, uid, eventTime);
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];;
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    localNotification.timeZone=[NSTimeZone defaultTimeZone];
    localNotification.userInfo=userInfo;
    localNotification.applicationIconBadgeNumber+=1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [localNotification release];
}

@end

