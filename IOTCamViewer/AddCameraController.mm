//
//  AddCameraController.m
//  IOTCamViewer
//
//  Created by tutk on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/IOTCAPIs.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "AddCameraController.h"
#import "AddCameraDetailController.h"
#import "QRCodeReader.h"
#import "LANSearchDevice.h"

@implementation AddCameraController

@synthesize addCameraByTyping, addCameraByScan, addCameraBySearch;
@synthesize tableView;

static int bLocalSearch = 0;

- (void)showListFullMesg 
{    
    NSString *msg = NSLocalizedString(@"List are full, remove a device and try again", @"");
    NSString *dismiss = NSLocalizedString(@"Dismiss", @"");
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:dismiss otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)lanSearch
{
    if (bLocalSearch == 1) return;
    bLocalSearch = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    int num = 0;
    int k = 0;
    int cnt = 0;
    
    [device_list removeAllObjects];
    
    while (num == 0 & cnt++ < 2) {
        
        LanSearch_t *pLanSearchAll = [Camera LanSearch:&num timeout:2000];
        printf("camera found(%d)\n", num);
        
        for(k = 0; k < num; k++) {
            
            printf("\tUID[%s]\n", pLanSearchAll[k].UID);
            printf("\tIP[%s]\n", pLanSearchAll[k].IP);
            printf("\tPORT[%d]\n", pLanSearchAll[k].port);
            printf("------------------\n");
            
            LANSearchDevice *dev = [[LANSearchDevice alloc] init];
            dev.uid = [NSString stringWithFormat:@"%s", pLanSearchAll[k].UID];
            dev.ip = [NSString stringWithFormat:@"%s", pLanSearchAll[k].IP];
            dev.port = pLanSearchAll[k].port;
            
            [device_list addObject:dev];
            
            [dev release];        
        }
        
        if(pLanSearchAll) {
            free(pLanSearchAll);
        }
    }

    bLocalSearch = 0;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
    // [self.tableView reloadData];
}

- (IBAction)addCameraByTypingPressed:(id)sender 
{
    if ([camera_list count] >= MAX_CAMERA_LIMIT) {        
        [self showListFullMesg];        
        return;
    }
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];    
    
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:YES];
    [controller setPasswordFieldBecomeFirstResponder:NO];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)addCameraByScanPressed:(id)sender 
{    
    if ([camera_list count] >= MAX_CAMERA_LIMIT) {
        
        [self showListFullMesg];        
        return;
    }
    
    ZXingWidgetController *controller = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    
    NSSet *readers = [[NSSet alloc] initWithObjects:qrcodeReader, nil];
    controller.readers = readers;
    [readers release];        
        
    NSBundle *mainBundle = [NSBundle mainBundle];
    controller.soundToPlay = [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;   
    [self presentModalViewController:controller animated:YES];        
    [controller release];
    [qrcodeReader release];
}       

- (IBAction)searchCameraPressed:(id)sender 
{
    [NSThread detachNewThreadSelector:@selector(lanSearch) toTarget:self withObject:nil];
    //[self lanSearch];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(searchCameraPressed:)];
                                   
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    
    self.navigationItem.title = NSLocalizedString(@"Add Camera", @"");
    
    [self.addCameraByTyping.layer setCornerRadius:0.0f];
    [self.addCameraByTyping.layer setMasksToBounds:NO];
    [self.addCameraByTyping.layer setBorderWidth:0.0f];

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    device_list = [[NSMutableArray alloc] init];
    
    [NSThread detachNewThreadSelector:@selector(lanSearch) toTarget:self withObject:nil];
    //[self lanSearch];
    
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
    
    [super viewDidLoad];
}

- (void)viewDidUnload 
{    
    //device_list = nil;
    self.addCameraByScan = nil;
    self.addCameraByTyping = nil;
    self.addCameraBySearch = nil;
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated 
{    
    [self.tableView reloadData];
    [super viewDidAppear:animated];

	AppDelegate* currentAppDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	if( currentAppDelegate.mOpenUrlCmdStore.cmd == emAddDeviceByUID ) {
		if ([camera_list count] >= MAX_CAMERA_LIMIT) {
			[self showListFullMesg];
			[currentAppDelegate urlCommandDone];
			return;
		}
		[addCameraByTyping sendActionsForControlEvents: UIControlEventTouchUpInside];
	}
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc 
{    
    [device_list release];
    [addCameraByScan release];
    [addCameraByTyping release];
    [addCameraBySearch release];
    [tableView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Zxing Delegate Methods 扫描二维码代理
- (void)zxingController:(ZXingWidgetController *)controller_ 
          didScanResult:(NSString *)result 
{            
    [self dismissModalViewControllerAnimated:NO];
       
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];   
    
    controller.uid = result;
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - LANSearch Delegate Methods
- (void)lanSearchController:(LANSearchController *)controller_ 
            didSearchResult:(NSString *)uid_ 
                         ip:(NSString *)ip_ 
                       port:(NSInteger)port_ 
{
    [controller_.navigationController popViewControllerAnimated:NO];    
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];    
    controller.uid = uid_;
    controller.hidesBottomBarWhenPushed = YES;
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - AddCameraDelegate Methods
- (void)camera:(NSString *)UID didAddwithName:(NSString *)name password:(NSString *)password {

    MyCamera *camera = [[MyCamera alloc] initWithName:name viewAccount:@"admin" viewPassword:password];
    
    [camera connect:UID];
    [camera start:0];
    
    SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
    s->channel = 0;                    
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
    free(s);
    
    SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
    free(s2);    

    
    if ( [camera getTimeZoneSupportOfChannel:0] ){
        SMsgAVIoctrlTimeZone s3={0};
        s3.cbSize = sizeof(s3);
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
    }
    
    [camera_list addObject:camera];
    [camera release];
        
    if (database != NULL) {
        [database executeUpdate:@"INSERT INTO device(dev_uid, dev_nickname, dev_name, dev_pwd, view_acc, view_pwd, channel) VALUES(?,?,?,?,?,?,?)", 
         camera.uid, name, name, password, @"admin", password, [NSNumber numberWithInt:0]];
    } 
    
    
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // register to apns server
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
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
    
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tabBarController setSelectedIndex:0];
    });
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([camera_list count] >= MAX_CAMERA_LIMIT) {
        
        [self showListFullMesg];
        return;
    }
    
    NSInteger row = [indexPath row];
    
    LANSearchDevice *dev = [device_list objectAtIndex:row];
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:self];    
    
    controller.uid = dev.uid;
    controller.hidesBottomBarWhenPushed = YES;  
    
    [controller setNameFieldBecomeFirstResponder:NO];
    [controller setPasswordFieldBecomeFirstResponder:YES];
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!bLocalSearch && (device_list == nil || [device_list count] <= 0)) ? 0 : [device_list count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CameraListCell = @"CameraListCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CameraListCell] autorelease];        
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    LANSearchDevice *dev = [device_list objectAtIndex:row];
    BOOL isDeviceExist = NO;
    
    for (Camera *camera in camera_list) {
        if ([camera.uid isEqualToString:dev.uid]) {
            isDeviceExist = YES;
            break;
        }
    }
    
    cell.textLabel.text = dev.uid;
    cell.textLabel.textColor = isDeviceExist ? [UIColor grayColor] : [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = dev.ip;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_articalList.png"]] autorelease];
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, 20)] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:headerView.frame] autorelease];
    label.textColor = [UIColor lightGrayColor];
    label.text = bLocalSearch ? NSLocalizedString(@"Searching...", @"") : [NSString stringWithFormat:NSLocalizedString(@"Camera Found! (%d)", @""), [device_list count]];
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(1, 1);
    
    /*
    if (bLocalSearch) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        CGSize expectedLabelSize = [label.text sizeWithFont:label.font
                                          constrainedToSize:CGSizeMake(320, 30)
                                              lineBreakMode:label.lineBreakMode];
    
        [indicator setCenter:CGPointMake(expectedLabelSize.width + 30, 10)];
        [indicator startAnimating];
        
        [headerView addSubview:indicator];
        [indicator release];
    }
    */
    
    [headerView addSubview:label];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.8f]];
    return headerView;
}

@end
