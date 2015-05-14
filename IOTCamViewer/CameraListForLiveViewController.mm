//
//  CameraListForLiveViewController.m
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraListForLiveViewController.h"
#import "UIDevice+Version.h"
#import "CameraLiveViewController.h"
#import "EditCameraDefaultController.h"
#import "AppDelegate.h"

//for test
#import "DeviceListOnCloudViewController.h"
#import "GetWiFiSSIDViewController.h"
#import "AddCameraController.h"
#import "CheckViewController.h"
#import "CameraMultiLiveViewController.h"
#if defined(EasynPTarget)
#import "AddWithApCameraController.h"
#endif
#if defined(BayitCam)
#import "BayitCamAddViewController.h"
#endif

@implementation CameraListForLiveViewController

@synthesize tableView;
@synthesize searchBar;
@synthesize tableViewCell;
@synthesize arrReConntFlag;
@synthesize viewTag;
@synthesize selectCamera;

- (IBAction)toggleEdit:(id)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [tableView reloadData];
    
    if (self.tableView.editing)
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done", @"")];  
    else 
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", @"")];    
}

- (IBAction)goDeviceOnCloud:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]||[userDefaults objectForKey:@"cloudUserPassword"]==nil){
        
        NSString *msg = NSLocalizedString(@"Please login first!", @"");
        NSString *no = NSLocalizedString(@"Cancel", @"");
        NSString *yes = NSLocalizedString(@"Login", @"");
        NSString *caution = NSLocalizedString(@"Caution!", @"");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:caution message:msg delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
        [alert show];
        [alert release];
        
    } else {
        for (MyCamera *camera in camera_list) {
            camera.delegate2 = nil;
        }
        
        DeviceListOnCloudViewController *controller = [[DeviceListOnCloudViewController alloc] initWithNibName:@"DeviceListOnCloudView" bundle:nil];
        [self.navigationController pushViewController:controller animated:NO];
        [controller release];
    }
    
}

#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 ) {
        
        for (MyCamera *camera in camera_list) {
            camera.delegate2 = nil;
        }
        
        DeviceListOnCloudViewController *controller = [[DeviceListOnCloudViewController alloc] initWithNibName:@"DeviceListOnCloudView" bundle:nil];
        [self.navigationController pushViewController:controller animated:NO];
        [controller release];
    }
}

- (IBAction)goAddCamera:(id)sender {
    for (MyCamera *camera in camera_list) {
        camera.delegate2 = nil;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:0 forKey:@"wifiSetting"];
    [userDefaults synchronize];
    
    
#if defined(BayitCam)
    BayitCamAddViewController *bayitAdd=[[BayitCamAddViewController alloc]initWithNibName:@"BayitCamAddViewController" bundle:nil];
    [self.navigationController pushViewController:bayitAdd animated:YES];
    [bayitAdd release];
    return;
#endif
    
    
    
#if defined(EasynPTarget)
    AddWithApCameraController *addController=[[AddWithApCameraController alloc]initWithNibName:@"AddWithApCameraController" bundle:nil];
    [self.navigationController pushViewController:addController animated:YES];
    [addController release];
#else
    
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:0]];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];

    /*CheckViewController *controller = [[CheckViewController alloc] initWithNibName:@"CheckView" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];*/
#endif

}

- (IBAction)back:(id)sender {
    for (MyCamera *camera in camera_list) {
        camera.delegate2 = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[dirs objectAtIndex:0] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

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

- (void)doMapping:(NSString *)uid{
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_mapping", NULL);
    dispatch_async(queue, ^{
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
    });
    
    dispatch_release(queue);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate->passwordChanged = NO;
}


#pragma mark - View lifecycle
- (void) viewDidLoad 
{
    self.navigationController.navigationBar.translucent = NO;
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_bk" ]];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = bg;
    
    remoteLabel.text = NSLocalizedString(@"Cloud Import", @"");
    localLabel.text =  NSLocalizedString(@"Manually Add", @"");
    
    self.navigationItem.title = NSLocalizedString(@"Camera List", @"");
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:NSLocalizedString(@"Edit", @"") 
                                   style:UIBarButtonItemStyleBordered 
                                   target:self action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];    
    
    searchedData = [[NSMutableArray alloc] init];
	arrReConntFlag = [[NSMutableArray alloc] init];
    
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
    
    
    addBTNView.hidden = isFromChange;
    
    [super viewDidLoad];
}

- (void)viewDidUnload 
{
	arrReConntFlag = nil;
    searchedData = nil;
    searchBar = nil;
    tableView = nil;
    tableViewCell = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    
    
    addBTNView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, addBTNView.frame.size.height);
    
    if ([camera_list count] < MAX_CAMERA_LIMIT) {
        self.tableView.height = self.view.frame.size.height-addBTNView.frame.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            addBTNView.frame = CGRectMake(0, self.view.frame.size.height-addBTNView.frame.size.height, self.view.frame.size.width, addBTNView.frame.size.height);
        }];
    }
    else{
        self.tableView.height = self.view.frame.size.height;
    }
    
    
    [searchedData removeAllObjects];
    [searchedData addObjectsFromArray:camera_list];    
    self.navigationItem.rightBarButtonItem.enabled = [searchedData count] > 0;
    
	[arrReConntFlag removeAllObjects];
    for (MyCamera *camera in camera_list) {
        
        NSLog(@"CAMERA NAME:%@",camera.name);
        
        camera.delegate2 = self;
		
		[arrReConntFlag addObject:[NSMutableArray arrayWithObjects:[NSString stringWithString:camera.uid], [NSNumber numberWithInt:0], nil]];
	}
    [self.tableView reloadData];
	
	AppDelegate* currentAppDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	if( currentAppDelegate.mOpenUrlCmdStore.cmd == emShowLiveViewByUID ) {
		NSIndexPath *nip = [NSIndexPath indexPathForRow:currentAppDelegate.mOpenUrlCmdStore.tabIdx inSection:0];
		[self tableView:[self tableView] didSelectRowAtIndexPath:nip];
		[currentAppDelegate urlCommandDone];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:kApplicationDidEnterForeground object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [searchedData removeAllObjects];
	for( NSMutableArray* store in arrReConntFlag ) {
		if( [store count] == 3 ) {
			NSTimer* timer = [store objectAtIndex:2];
			[timer invalidate];
			//[timer release];
		}
	}
	[arrReConntFlag removeAllObjects];
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[arrReConntFlag release];
    [searchedData release];
    [searchBar release];
    [tableView release];
    [tableViewCell release];
    [super dealloc];
}

#pragma mark - Notification Method

- (void)reloadTableView:(NSNotification *)sender
{
    [arrReConntFlag removeAllObjects];
    
    for (MyCamera *camera in camera_list) {
		[arrReConntFlag addObject:[NSMutableArray arrayWithObjects:[NSString stringWithString:camera.uid], [NSNumber numberWithInt:0], nil]];
	}
    [self.tableView reloadData];
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    return [searchedData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CameraListCellIdentifier = @"CameraListCellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
    
    if (cell == nil) {
     
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CameraListCell" owner:self options:nil];

        if ([nib count] > 0) 
            cell = self.tableViewCell;
    }    
    
    NSUInteger row = [indexPath row];
	if( [searchedData count] > 0 && row < [searchedData count] ) {
		Camera *camera = [searchedData objectAtIndex:row];
		
		/* load camera name */
		UILabel *cameraNameLabel = (UILabel *)[cell viewWithTag:CAMERA_NAME_TAG];
		if (cameraNameLabel != nil)
			cameraNameLabel.text = camera.name;
		
		/* load camera status */
		UILabel *cameraStatusLabel = (UILabel *)[cell viewWithTag:CAMERA_STATUS_TAG];

		if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Connecting...", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
			}
			NSLog(@"%@ connecting", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Off line", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Off line", @"");
			}
			NSLog(@"%@ off line", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Unknown Device", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Unknown Device", @"");
			}
			NSLog(@"%@ unknown device", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Timeout", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Timeout", @"");
			}
			NSLog(@"%@ timeout", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Unsupported", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Unsupported", @"");
			}
			NSLog(@"%@ unsupported", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ A.%ld(%ldL)", NSLocalizedString(@"Connect Failed", @""), (long)camera.connTimes, (long)camera.connFailErrCode];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Connect Failed", @"");
			}
			NSLog(@"%@ connected failed", camera.uid);
		}
		
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
			if( g_bDiagnostic ) {
				
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ [%@]%ld,C:%ld,D:%ld,r%d", NSLocalizedString(@"Online", @""), [MyCamera getConnModeString:camera.sessionMode], (long)camera.connTimes, (long)camera.natC, (long)camera.natD, camera.nAvResend ];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Online", @"");
			}
			NSLog(@"%@ online", camera.uid);
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (appDelegate->passwordChanged==YES){
                [self doMapping:camera.uid];
            }
            
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_CONNECTING)", NSLocalizedString(@"Connecting...", @""), (long)camera.connTimes];				
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
			}
			NSLog(@"%@ connecting", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED)
		{
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_DISCONNECTED)", NSLocalizedString(@"Off line", @""), (long)camera.connTimes];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Off line", @"");
			}
			NSLog(@"%@ off line", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_UNKNOWN_DEVICE)", NSLocalizedString(@"Unknown Device", @""), (long)camera.connTimes];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Unknown Device", @"");
			}
			NSLog(@"%@ unknown device", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_WRONG_PASSWORD)", NSLocalizedString(@"Wrong Password", @""), (long)camera.connTimes];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Wrong Password", @"");
			}
			NSLog(@"%@ wrong password", camera.uid);
            
            //Un-mapping
            [self unRegMapping:camera.uid];
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_TIMEOUT)", NSLocalizedString(@"Timeout", @""), (long)camera.connTimes];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Timeout", @"");
			}
			NSLog(@"%@ timeout", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_UNSUPPORTED)", NSLocalizedString(@"Unsupported", @""), (long)camera.connTimes];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Unsupported", @"");
			}
			NSLog(@"%@ unsupported", camera.uid);
		}
		else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
			if( g_bDiagnostic ) {
				cameraStatusLabel.text = [NSString stringWithFormat:@"%@ B.%ld(CONNECTION_STATE_NONE)", NSLocalizedString(@"Connecting...", @""), (long)camera.connTimes];
			}
			else {
				cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
			}
			NSLog(@"%@ wait for connecting", camera.uid);
		}
		
		/* load camera UID */
		UILabel *cameraUIDLabel = (UILabel *)[cell viewWithTag:CAMERA_UID_TAG];
		if (cameraUIDLabel != nil)
			cameraUIDLabel.text = camera.uid;    
			
		/* load camera snapshot */
		UIImageView *cameraSnapshotImageView = (UIImageView *)[cell viewWithTag:CAMERA_SNAPSHOT_TAG];
		if (cameraSnapshotImageView != nil) {
			NSString *imgFullName = [self pathForDocumentsResource:[NSString stringWithFormat:@"%@.jpg", camera.uid]];
			
			BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imgFullName];
			
			cameraSnapshotImageView.image = fileExists ? [UIImage imageWithContentsOfFile:imgFullName] : [UIImage imageNamed:@"videoClip.png"];
		}
    }
    
    cell.backgroundColor = [UIColor whiteColor];

    return cell;
}

#pragma mark - TableView Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [searchBar resignFirstResponder];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    
	NSInteger row1 = [indexPath row];
	if( [searchedData count] > 0 && row1 < [searchedData count] ) {
        
        MyCamera *tempCamera = [camera_list objectAtIndex:row1];
        //检查是否在四画面了
        CameraMultiLiveViewController *rootController=[self.navigationController.viewControllers objectAtIndex:0];
        NSMutableArray *hasCameraArray=rootController.cameraArray;
        for (MyCamera *ca in hasCameraArray) {
            if([ca.uid isEqualToString:tempCamera.uid]){
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"This device is already exists", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                
                [alert show];
                [alert release];
                
                return;
            }
        }
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //將資料回步回手機
        [userDefaults setObject:tempCamera.uid forKey:[[NSString alloc] initWithFormat:@"CameraMultiSetting_%@",viewTag]];
        [userDefaults setInteger:0 forKey:[[NSString alloc] initWithFormat:@"ChannelMultiSetting_%@",viewTag]];
        [userDefaults synchronize];
        
        [self.delegate didAddCamera:tempCamera cameraChannel:[NSNumber numberWithInteger:tempCamera.lastChannel] withView:viewTag];
        
        for (MyCamera *camera in camera_list) {
            camera.delegate2 = nil;
        }
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
 
    NSInteger row = [indexPath row];
    
    for (MyCamera *camera in camera_list) {
        camera.delegate2 = nil;
    }
    
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate didRemoveDevice:[camera_list objectAtIndex:row]];
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{    
    EditCameraDefaultController *controller = [[EditCameraDefaultController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.camera = [searchedData objectAtIndex:[indexPath row]];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView_ editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - SearchBar Delegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{    
    self.searchBar.showsCancelButton = NO;
    self.navigationItem.rightBarButtonItem.enabled = [searchedData count] > 0; 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
 
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
 
    [searchedData removeAllObjects];
    
    if ([searchText isEqualToString:@""]) {
        [self.tableView reloadData];
        return;
    }
	else if( [searchText isEqualToString:@"diagnostic"] ) {
		g_bDiagnostic = TRUE;
	}
      
    for (Camera *camera in camera_list) {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSRange range = [camera.name rangeOfString:searchText];
        
        if (range.location != NSNotFound && range.location == 0)             
            [searchedData addObject:camera];    
        
        [pool release];
    }

    self.navigationItem.rightBarButtonItem.enabled = [searchedData count] > 0;    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchedData removeAllObjects];
    [searchedData addObjectsFromArray:camera_list];
	
    @try {
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [self.searchBar resignFirstResponder];
        self.searchBar.text = @"";
    }
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

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera _didChangeSessionStatus:(NSInteger)status
{
    if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera disconnect];
            
        });
    }
    
    if (!self.tableView.editing)
        [self.tableView reloadData];
    
	if( camera.sessionState == CONNECTION_STATE_DISCONNECTED ||
	    camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE ||
	    camera.sessionState == CONNECTION_STATE_TIMEOUT ||
	    camera.sessionState == CONNECTION_STATE_UNSUPPORTED ||
	    camera.sessionState == CONNECTION_STATE_CONNECT_FAILED ) {
		
		NSMutableArray* storeToSetTimer = nil;
		int nReConntFlag = -1;
		for( NSMutableArray* store in arrReConntFlag ) {
			NSString* uidInStore = [store objectAtIndex:0];
			if( NSOrderedSame == [camera.uid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
				NSNumber* num = [store objectAtIndex:1];
				nReConntFlag = [num intValue];
				[store replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:++nReConntFlag]];
				storeToSetTimer = store;
				break;
			}
		}
		if( nReConntFlag == 1 ) {
			NSLog( @"Camera UID:%@ will re-connect in 30sec...", camera.uid );
			[storeToSetTimer addObject:[[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(ReConnectAfter30Sec:) userInfo:[NSArray arrayWithObjects:[NSString stringWithString:camera.uid], [NSValue valueWithPointer:camera], nil] repeats:NO] retain]];
		}
		else {
			NSLog( @"Camera UID:%@ give up re-connect nReConntFlag:%d", camera.uid, nReConntFlag );
		}
	}
	else if( camera.sessionState == CONNECTION_STATE_CONNECTED ) {
		for( NSMutableArray* store in arrReConntFlag ) {
			NSString* uidInStore = [store objectAtIndex:0];
			if( NSOrderedSame == [camera.uid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
				[store replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
				NSLog( @"Camera UID:%@ reset re-connect flag as -0-", camera.uid );
				break;
			}
		}
	}
}

- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (status == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera stop:channel];
            
            usleep(500 * 1000);
            
            [camera disconnect];
        });
    }
    
    if (!self.tableView.editing)
        [self.tableView reloadData];    
}

- (void)ReConnectAfter30Sec:(NSTimer*)theTimer
{
	NSArray* arrParam = (NSArray*)theTimer.userInfo;
	NSString* strUid = [arrParam objectAtIndex:0];
	MyCamera* camera = (MyCamera*)[(NSValue*)[arrParam objectAtIndex:1] pointerValue];
	
	BOOL bIsValid_Camera = FALSE;
	for( NSMutableArray* store in arrReConntFlag ) {
		NSString* uidInStore = [store objectAtIndex:0];
		if( NSOrderedSame == [strUid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
			bIsValid_Camera = TRUE;
			if( [store count] == 3 ) {
				NSTimer* timer = [store objectAtIndex:2];
                [timer invalidate];
//				[timer release];
				[store removeObjectAtIndex:2];
				break;
			}
		}
	}
	if( bIsValid_Camera ) {
		[camera connect:camera.uid];
		[camera start:0];
	}
	else {
		NSLog( @"ReConnectAfter30Sec with deallocated instance!!!" );
	}
}

@end