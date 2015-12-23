//
//  AppDelegate.h
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "RootViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "MyCamera.h"
#define NOTBACKUPDIR  @"dotbackupdir"

#define MAX_CAMERA_LIMIT 100

#define SQLCMD_CREATE_TABLE_DEVICE @"CREATE TABLE IF NOT EXISTS device(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, dev_nickname TEXT, dev_name TEXT, dev_pwd TEXT, view_acc TEXT, view_pwd TEXT, ask_format_sdcard INTEGER, channel INTEGER, sync INTEGER, isFromCloud INTEGER)"

#define SQLCMD_CREATE_TABLE_SNAPSHOT @"CREATE TABLE IF NOT EXISTS snapshot(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, file_path TEXT, time REAL)"

#define SQLCMD_CREATE_TABLE_REMOVELST @"CREATE TABLE IF NOT EXISTS apnsremovelst(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT)"

extern NSMutableArray *camera_list;
extern FMDatabase *database;
extern NSString *deviceTokenString;

// Notification Name
extern NSString *const kApplicationDidEnterBackground;
extern NSString *const kApplicationWillEnterForeground;
extern NSString *const kApplicationDidEnterForeground;

extern NSString *g_tpnsHostString;

enum open_url_cmd{
	emNoCmd = 0,
	emShowTabIndexPage = 1,
	emAddDeviceByUID,
	emShowLiveViewByUID
};

typedef struct tagOpenUrlCmdStore
{
	enum open_url_cmd cmd;
	int tabIdx;
	char uid[21];
	
}SOPENURLCMDSTORE, *LPSOPENURLCMDSTORE;

@interface AppDelegate : UIResponder
<UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, NSURLConnectionDataDelegate> {
	@public
	SOPENURLCMDSTORE mOpenUrlCmdStore;
    BOOL passwordChanged;
    UIBackgroundTaskIdentifier oldTaskId;
    NSString *ssid;
}

@property (readwrite, assign) SOPENURLCMDSTORE mOpenUrlCmdStore;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) NSString *ssid;
@property (nonatomic) BOOL allowRotation;
@property (nonatomic,retain) NSDictionary *apnsUserInfo;
@property(nonatomic) BOOL isbackgrounded;

+ (NSString *) pathForDocumentsResource:(NSString *) relativePath;
- (void) urlCommandDone;
-(id)fetchSSIDInfo;
@end
