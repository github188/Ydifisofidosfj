//
//  WiFiNetworkController.m
//  IOTCamViewer
//
//  Created by tutk on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "WiFiNetworkController.h"

@implementation WiFiNetworkController

@synthesize camera;
@synthesize wifiSSID;
@synthesize delegate;
@synthesize timerListWifiApResp;

- (IBAction)back:(id)sender {
    
    if (isChangeWiFi) 
        [self.delegate didChangeWiFiAp:wifiSSID];        
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<WiFiNetworkDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) self.delegate = delegate_;
    
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
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
    
    nLastSelIdx = -1;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                             initWithTitle:NSLocalizedString(@"Back", @"")
//                                             style:UIBarButtonItemStylePlain
//                                             target:self
//                                             action:@selector(back:)];
    
    self.navigationItem.title = NSLocalizedString(@"WiFi Networks", @"");       
    
	[self doRefresh];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {

    self.camera = nil;
    self.delegate = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
	if( nLastSelIdx != -1 ) {		
//		wifiSSIDListCount = -1;
//		[self.tableView reloadData];
//		[self doRefresh];
	}
	
    self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if( bTimerListWifiApResp ) {
		[self.timerListWifiApResp invalidate];
		bTimerListWifiApResp = FALSE;
	}
}

- (void)dealloc {
    
	if( bTimerListWifiApResp ) {
		[self.timerListWifiApResp invalidate];
		bTimerListWifiApResp = FALSE;
	}
    [camera release];
    [super dealloc];
}

#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return wifiSSIDList != NULL && wifiSSIDListCount >= 0 ? wifiSSIDListCount : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    NSUInteger row = [indexPath row];
    
    static NSString *WiFiNetworkCellIdentifier = @"WiFiNetworkCellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WiFiNetworkCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:WiFiNetworkCellIdentifier]
                autorelease];
    }
    
    SWifiAp wifiAp = wifiSSIDList[row];
    
    NSLog(@"wifi AP: %s \t%d", wifiAp.ssid, wifiAp.status);
    
    NSString *ssid = [NSString stringWithUTF8String: wifiAp.ssid];
    
    if ([ssid length] > 0)
        cell.textLabel.text = ssid; 
    else
        cell.textLabel.text = NSLocalizedString(@"Unknown", @"");
    
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (([ssid length] > 0) &&
        ((self.wifiSSID != nil && [ssid length] > 0 && [ssid isEqualToString:self.wifiSSID]) ||
         (wifiAp.status == 1 || wifiAp.status == 3 || wifiAp.status == 4)))
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	if( !bRemoteDevTimeout ) {
		if (wifiSSIDListCount < 0)
			return NSLocalizedString(@"Scanning...", @"");
		else if (wifiSSIDListCount == 0)
			return NSLocalizedString(@"No Wi-Fi network found", @"");
		else
			return NSLocalizedString(@"Choose a Network...", @"");
	}
	else {
		return NSLocalizedString(@"Remote Device Timeout", @"");
	}
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
           
    int idx = [indexPath row];
    SWifiAp wifiAp = wifiSSIDList[idx];
    
    EditWiFiPasswordController *controller = [[EditWiFiPasswordController alloc] initWithNibName:@"WiFiPassword" bundle:nil delegate:self];
    controller.camera = self.camera;
    controller.ssid = [NSString stringWithFormat:@"%s", wifiAp.ssid];
    controller.ssid_length = 32;
    controller.mode = wifiAp.mode;
    controller.enctype = wifiAp.enctype;    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
	
	nLastSelIdx = idx;
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera) {
        
        if (type == IOTYPE_USER_IPCAM_LISTWIFIAP_RESP) {         
            if( bTimerListWifiApResp ) {
				[self.timerListWifiApResp invalidate];
				bTimerListWifiApResp = FALSE;
			}
         
            if (!isRecvWiFi) {
                memset(wifiSSIDList, 0, sizeof(wifiSSIDList));
                
                SMsgAVIoctrlListWifiApResp *p = (SMsgAVIoctrlListWifiApResp *)data;
                
                wifiSSIDListCount = p->number;            
                memcpy(wifiSSIDList, p->stWifiAp, size - sizeof(p->number));            
                
                [self.tableView reloadData];
                isRecvWiFi = true;
            }
        }
    }
}

#pragma mark - EditWiFiPasswordDelegate Methods
- (void)didSetPasswordSuccess:(NSString *)ssid {
    
    isChangeWiFi = true;
    wifiSSID = [ssid copy];
    NSArray *visableCells = [self.tableView visibleCells];
    int i;        
    for (i = 0; i< [visableCells count]; i++) {        
        UITableViewCell *currentCell = [visableCells objectAtIndex:i];
        
        if ([currentCell.textLabel.text isEqualToString:ssid]) {
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            currentCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)timeOutGetListWifiAPResp:(NSTimer *)timer
{
	bTimerListWifiApResp = FALSE;

	int timeOut = [(NSNumber*)timer.userInfo intValue];
	nTotalWaitingTime += timeOut;
	
	NSLog( @"!!! IOTYPE_USER_IPCAM_LISTWIFIAP_RESP TimeOut %dsec !!!", nTotalWaitingTime );
	
	if( nTotalWaitingTime <= 30 ) {
		timeOut = 20;
	}
	else if( nTotalWaitingTime <= 50 ) {
		timeOut = 10;
	}
	else if( nTotalWaitingTime > 50 ) {
		timeOut = 0;
		
		bRemoteDevTimeout = TRUE;
		
		[self.tableView reloadData];
	}
	
	if( timeOut > 0 ) {
		bTimerListWifiApResp = TRUE;
		timerListWifiApResp = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(timeOutGetListWifiAPResp) userInfo:[NSNumber numberWithInt:timeOut] repeats:FALSE];
	}
}

- (void)doRefresh
{
    // send list wifi request
    SMsgAVIoctrlListWifiApReq *structListWiFi = malloc(sizeof(SMsgAVIoctrlListWifiApReq));
    memset(structListWiFi, 0, sizeof(SMsgAVIoctrlListWifiApReq));
    
	bTimerListWifiApResp = TRUE;
	bRemoteDevTimeout = FALSE;
	nTotalWaitingTime = 0;
	timerListWifiApResp = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timeOutGetListWifiAPResp) userInfo:[NSNumber numberWithInt:30] repeats:FALSE];
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_LISTWIFIAP_REQ Data:(char *)structListWiFi DataSize:sizeof(SMsgAVIoctrlListWifiApReq)];
    free(structListWiFi);
    
    
    wifiSSIDListCount = -1;
    memset(wifiSSIDList, 0, sizeof(wifiSSIDList));
    isRecvWiFi = false;
    isChangeWiFi = false;
    
    // send get wifi request
    SMsgAVIoctrlGetWifiReq *structGetWiFi = malloc(sizeof(SMsgAVIoctrlGetWifiReq));
    memset(structGetWiFi, 0, sizeof(SMsgAVIoctrlGetWifiReq));
    
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETWIFI_REQ Data:(char *)structGetWiFi DataSize:sizeof(SMsgAVIoctrlGetWifiReq)];
    free(structGetWiFi);	
}
@end
