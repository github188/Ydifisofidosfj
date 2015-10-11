//
//  AdvancedSettingController.m
//  IOTCamViewer
//
//  Created by tutk on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "EditCameraAdvancedController.h"
#import "WiFiNetworkController.h"
#import "AboutDeviceController.h"
#import "FormatSDCardController.h"

typedef struct
{
    int cbSize;							// the following package size in bytes, should be sizeof(SMsgAVIoctrlTimeZone)
    int nIsSupportTimeZone;
    int nGMTDiff;						// the difference between GMT in hours
    char szTimeZoneString[256];			// the timezone description string in multi-bytes char format
    unsigned int local_utc_time;        //long local_utc_time;                // the number of seconds passed
    // since the UNIX epoch (January 1, 1970 UTC)
    int dst_on;                         // summer time, 0:off 1:on
}SMsgAVIoctrlTimeZoneExt64Bit;

@implementation EditCameraAdvancedController

@synthesize camera;
@synthesize theNewPassword;
@synthesize wifiSSID;
@synthesize videoQualityIndicator;
@synthesize videoFlipIndicator;
@synthesize envModeIndicator;
@synthesize wifiIndicator;
@synthesize motionIndicator;
@synthesize recordIndicator;
@synthesize timezoneIndicator;
@synthesize delegate;
@synthesize timerTimeZoneTimeOut;
@synthesize arrRequestIoCtrl;
@synthesize timeZoneCell;
@synthesize timerListWifiApResp;


- (id)initWithStyle:(UITableViewStyle)style delegate:(id<EditCameraAdvancedDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        delegate = delegate_;
    }
            
    return self;
}

- (IBAction)back:(id)sender
{
    
    if (isChangePasswd && self.delegate) {
        [self.delegate didChangeAdvancedSetting:theNewPassword :isNeedReconn];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)receiveIOCtrl:(NSNotification *)notification
{  
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dict = [notification userInfo];    
        // NSString *name = [notification name];
        
        NSData *data = (NSData *)[dict valueForKey:@"recvData"];
        NSNumber *type = (NSNumber *)[dict valueForKey:@"type"];
        NSString *uid = (NSString *)[dict valueForKey:@"uid"];
        
        if ([camera.uid isEqualToString:uid])
            [self camera:self.camera _didReceiveIOCtrlWithType:[type intValue] Data:(char *)[data bytes] DataSize:[data length]];
    //});
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark

- (int)getVideoQualitySettingRowIndex
{
    return [camera getVideoQualitySettingSupportOfChannel:0] ? 0 : -1;
}

- (int)getVideoFlipSettingRowIndex
{
    int idx = 1;
    
    if ([self getVideoQualitySettingRowIndex] < 0)
        idx--;
    
    return [camera getVideoFlipSupportOfChannel:0] ? idx : -1;
}

- (int)getEnvironmentSettingRowIndex
{
    int idx = 2;
    
    if ([self getVideoQualitySettingRowIndex] < 0)
        idx--;
    
    if ([self getVideoFlipSettingRowIndex] < 0)
        idx--;
    
    return [camera getEnvironmentModeSupportOfChannel:0] ? idx : -1;
}

- (int)getTimeZoneSettingRowIndex
{
	return camera.bIsSupportTimeZone ? 0 : -1;
}

- (int)getWifiSettingRowIndex
{
    return [camera getWiFiSettingSupportOfChannel:0] ? 0 : -1;
}

- (int)getMotionDetectionSettingRowIndex
{
    return [camera getMotionDetectionSettingSupportOfChannel:0] ? 0 : -1;
}

- (int)getRecordSettingRowIndex
{
    return [camera getRecordSettingSupportOfChannel:0] ? 0 : -1;
}

- (int)getFormatSDCardRowIndex
{
    int idx = 1;
    
    if ([self getRecordSettingRowIndex] < 0)
        idx--;
    
    return [camera getFormatSDCardSupportOfChannel:0] ? idx : -1;
}

- (int)getDeviceInfoRowIndex
{
    return [camera getDeviceInfoSupportOfChannel:0] ? 0 : -1;
}

#pragma mark

- (int)getVideoSettingSectionIndex 
{
//    return ([camera getVideoQualitySettingSupportOfChannel:0] ||
//            [camera getVideoFlipSupportOfChannel:0] ||
//            [camera getEnvironmentModeSupportOfChannel:0]) ? 1 : -1;
    return -1;
}

- (int)getTimeZoneSettingSectionIndex
{
	int idx = 2;
	
    if ([self getVideoSettingSectionIndex] < 0)
        idx--;

	return camera.bIsSupportTimeZone ? idx : -1;
}

- (int)getWifiSettingSectionIndex
{
    int idx = 3;
    
    if ([self getVideoSettingSectionIndex] < 0)
        idx--;
	
	if( !camera.bIsSupportTimeZone )
		idx--;
    
    return [camera getWiFiSettingSupportOfChannel:0] ? idx : -1;
}

- (int)getSyncSettingSectionIndex
{
    int idx = 4;
    
    if ([self getVideoSettingSectionIndex] < 0)
        idx--;
    
	if( !camera.bIsSupportTimeZone )
		idx--;
    
    if ([self getWifiSettingSectionIndex] < 0)
        idx--;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]||[userDefaults objectForKey:@"cloudUserPassword"]==nil){
        return -1;
    } else {
        return  idx;
    }
}

- (int)getEventSettingSectionIndex
{
    int idx = 5;
    
    if ([self getVideoSettingSectionIndex] < 0)
        idx--;

	if( !camera.bIsSupportTimeZone )
		idx--;
    
    if ([self getWifiSettingSectionIndex] < 0)
        idx--;
    
    
    if ([self getSyncSettingSectionIndex] <0){
        idx--;
    }
    
    return [camera getMotionDetectionSettingSupportOfChannel:0] ? idx : -1;
}

- (int)getRecordSettingSectionIndex
{
    int idx = 6;
    
    if ([self getVideoSettingSectionIndex] < 0)
        idx--;
    
	if( !camera.bIsSupportTimeZone )
		idx--;
    
    if ([self getWifiSettingSectionIndex] < 0)
        idx--;
    
    if ([self getEventSettingSectionIndex] < 0)
        idx--;
    
    if ([self getSyncSettingSectionIndex] <0){
        idx--;
    }
    
    return ([camera getRecordSettingSupportOfChannel:0] ||
            [camera getFormatSDCardSupportOfChannel:0]) ? idx : -1;
}

- (int)getDeviceInfoSectionIndex
{
    int idx = 7;
    
    if ([self getVideoSettingSectionIndex] < 0)
        idx--;
    
	if( !camera.bIsSupportTimeZone )
		idx--;
    
    if ([self getWifiSettingSectionIndex] < 0)
        idx--;
    
    if ([self getEventSettingSectionIndex] < 0)
        idx--;
    
    if ([self getRecordSettingSectionIndex] < 0)
        idx--;
    
    if ([self getSyncSettingSectionIndex] <0){
        idx--;
    }
#if defined(CameraMailSetting)
    idx++;
#endif
    
    return [camera getDeviceInfoSupportOfChannel:0] ? idx : -1;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    isNeedReconn = false;
    isChangePasswd = false;
    theNewPassword = nil;
    
	nLastSelSection = -1;
	nLastSelRow = -1;
    
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
    
    self.navigationItem.title = NSLocalizedString(@"Advanced Setting", @""); 
    
    self.videoQualityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.videoFlipIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.envModeIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.wifiIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease] ;
    self.motionIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.recordIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	self.timezoneIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    
	[self doRefresh];
    [self getWifiInfo];
    
    bPendingWifi = NO;
    
    arrTimeZoneTable = [[NSArray alloc] initWithObjects:
                        @"GMT-11",
                        @"GMT-10",
                        @"GMT-9",
                        @"GMT-8",
                        @"GMT-7",
                        @"GMT-6",
                        @"GMT-5",
                        @"GMT-4",
                        @"GMT-3",
                        @"GMT-2",
                        @"GMT-1",
                        @"GMT 0",
                        @"GMT+1",
                        @"GMT+2",
                        @"GMT+3",
                        @"GMT+4",
                        @"GMT+5",
                        @"GMT+6",
                        @"GMT+7",
                        @"GMT+8",
                        @"GMT+9",
                        @"GMT+10",
                        @"GMT+11",
                        @"GMT+12", nil];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
        
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didReceiveIOCtrl" object:nil];
	self.arrRequestIoCtrl = nil;
	
    self.wifiSSID = nil;
    self.videoQualityIndicator = nil;
    self.videoFlipIndicator = nil;
    self.envModeIndicator = nil;
    self.wifiIndicator = nil;
    self.motionIndicator = nil;
    self.recordIndicator = nil;
	self.timezoneIndicator = nil;
    self.camera = nil;
    self.theNewPassword = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
	NSLog( @"Last sel section:%d row:%d", nLastSelSection, nLastSelRow );
	if( nLastSelSection != -1 &&
	    nLastSelRow != -1 ) {
		[self doRefresh];
	}
	
    if (camera != nil)
        camera.delegate2 = self;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if( bTimerListWifiApResp ) {
		[self.timerListWifiApResp invalidate];
		[timerListWifiApResp release];
		bTimerListWifiApResp = FALSE;
	}
}

- (void)dealloc {
	if( isWaitingForSetTimeZoneResp ) {
		[timerTimeZoneTimeOut release];
	}
	if( bTimerListWifiApResp ) {
		[self.timerListWifiApResp invalidate];
		[timerListWifiApResp release];
		bTimerListWifiApResp = FALSE;
	}
	[arrRequestIoCtrl release];
    [wifiSSID release];
    [videoQualityIndicator release];
    [videoFlipIndicator release];
    [envModeIndicator release];
    [wifiIndicator release];
    [motionIndicator release];
    [recordIndicator release];
    [camera release];
    [theNewPassword release];
    [arrTimeZoneTable release];
    [super dealloc];
}

#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    int row = 1;
    
    if ([camera getVideoQualitySettingSupportOfChannel:0] ||
        [camera getVideoFlipSupportOfChannel:0] ||
        [camera getEnvironmentModeSupportOfChannel:0])
        row++;
    
	if( camera.bIsSupportTimeZone )
		row++;
	
    if ([camera getWiFiSettingSupportOfChannel:0])
        row++;
    
    if ([camera getMotionDetectionSettingSupportOfChannel:0])
        row++;
    
    if ([camera getRecordSettingSupportOfChannel:0] ||
        [camera getFormatSDCardSupportOfChannel:0])
        row++;
    
    if ([camera getDeviceInfoSupportOfChannel:0])
        row++;
    
#if defined(CameraMailSetting)
    row++;
#endif
    //for SyncSetting
    row++;
    
	NSLog( @"numberOfSectionsInTableView : %d", row );
	
    return row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SECURITYCODE_SECTION_INDEX) {
        return 1;
    } else if (section == [self getVideoSettingSectionIndex]) {
        int row = 0;
        if ([camera getVideoQualitySettingSupportOfChannel:0]) row++;
        if ([camera getVideoFlipSupportOfChannel:0]) row++;
        if ([camera getEnvironmentModeSupportOfChannel:0]) row++;
        return row;
    } else if (section == [self getTimeZoneSettingSectionIndex]) {
#if defined(TimeZoneAction)
        return 2;
#endif
        return 1;
    } else if (section == [self getWifiSettingSectionIndex]) {
        int row = 0;
        if ([camera getWiFiSettingSupportOfChannel:0]) row++;
        return row;
    }  else if (section == [self getSyncSettingSectionIndex]) {
        return 1;
    } else if (section == [self getEventSettingSectionIndex]) {
        int row = 0;
        if ([camera getMotionDetectionSettingSupportOfChannel:0]) row++;
        return row;
    } else if (section == [self getRecordSettingSectionIndex]) {
        int row = 0;
        if ([camera getRecordSettingSupportOfChannel:0]) row++;
        if ([camera getFormatSDCardSupportOfChannel:0]) row++;
        return row;
    }
#if defined(CameraMailSetting)
    else if (section == [self getDeviceInfoSectionIndex]-1){
        return 1;
    }
#endif
    else if (section == [self getDeviceInfoSectionIndex]) {
        int row = 0;
        if ([camera getDeviceInfoSupportOfChannel:0]) row++;
        return row;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger cellIndicator_X = self.tableView.frame.size.width - 50;
	NSInteger cellIndicator_Y = 23;
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *SectionTableIdentifier = @"SectionTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionTableIdentifier];
    
    if (cell == nil/* && section != [self getTimeZoneSettingSectionIndex]*/ ) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SectionTableIdentifier]
                autorelease];
        if (section == [self getTimeZoneSettingSectionIndex]) {
#if defined(TimeZoneAction)
            if (row==1) {
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.tag = 7000;
                cell.accessoryView = switchView;
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                [switchView release];
            }
#else
            if (row==0) {
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.tag = 7000+row;
                cell.accessoryView = switchView;
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                [switchView release];
            }
#endif
        }
    }
    
    if (section == SECURITYCODE_SECTION_INDEX) {        
        cell.textLabel.text = NSLocalizedString(@"Security Code", @"");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
    }
    else if (section == [self getVideoSettingSectionIndex]) {
        
        if (row == [self getVideoQualitySettingRowIndex]) {
            
            if (videoQuality < 0) {            
                [cell addSubview:videoQualityIndicator];
                [videoQualityIndicator startAnimating];
                videoQualityIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
            }
            else {                
                [videoQualityIndicator stopAnimating];
                [videoQualityIndicator removeFromSuperview];
            }
            
            NSString *text = nil;   
            
            switch (videoQuality) {

                case 0:
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Unknown", @"")];;
                    break;
                case 1:
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Max", @"")];;
                    break;
                case 2:
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"High", @"")];
                    break;
                case 3:
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", @"")];
                    break;
                case 4:
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Low", @"")];
                    break;
                case 5:
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Min", @"")];
                    break;
                default:
                    text = nil;
                    break;
            }
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Video Quality", @"")];
            cell.detailTextLabel.text = text;
            
            if (text)
                [text release];
        }
        else if (row == [self getVideoFlipSettingRowIndex]) {
            
            NSString *text = nil;
            
            if ([camera getVideoFlipSupportOfChannel:0]) {
           
                if (videoFlip == -1) {
                    [cell addSubview:videoFlipIndicator];
                    [videoFlipIndicator startAnimating];
                    videoFlipIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
                }
                else {
                    [videoFlipIndicator stopAnimating];
                    [videoFlipIndicator removeFromSuperview];
                }

                switch (videoFlip) {
                    case 0:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Normal", @"")];
                        break;
                    case 1:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Vertical Flip", @"")];
                        break;
                    case 2:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Mirror", @"")];
                        break;
                    case 3:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Flip & Mirror", @"")];
                        break;
                    case -2:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Timeout", @"")];
                        break;
                    default:
                        text = nil;
                        break;
                }
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                
            }
            else {
                
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Not Supported", @"")];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Video Flip", @"")];
            cell.detailTextLabel.text = text;            
            
            if (text)
                [text release];
        }
        else if (row == [self getEnvironmentSettingRowIndex]) {
            
            NSString *text = nil;
            
            if ([camera getEnvironmentModeSupportOfChannel:0]) {
            
                if (envMode == -1) {
                    [cell addSubview:envModeIndicator];
                    [envModeIndicator startAnimating];
                    envModeIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
                }
                else {
                    [envModeIndicator stopAnimating];
                    [envModeIndicator removeFromSuperview];
                }            
                
                switch (envMode) {
                    case 0:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Indoor(50Hz)", @"")];
                        break;
                    case 1:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Indoor(60Hz)", @"")];
                        break;
                    case 2:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Outdoor", @"")];
                        break;
                    case 3:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Night", @"")];
                        break;
                    case -2:
                        text = [[NSString alloc] initWithString:NSLocalizedString(@"Timeout", @"")];
                        break;
                    default:
                        text = nil;
                        break;
                }
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                
            }
            else {
                
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Not Supported", @"")];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Environment Mode", @"")];
            cell.detailTextLabel.text = text;
            
            if (text)
                [text release];
        }
    }    
    else if (section == [self getTimeZoneSettingSectionIndex]) {
        if(indexPath.row==0){
            NSString *text = nil;
            
            if( isWaitingForSetTimeZoneResp ) {
                [cell addSubview:timezoneIndicator];
                [timezoneIndicator startAnimating];
                timezoneIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y+7 );
                
                text = @"";
            } else {
                [timezoneIndicator stopAnimating];
                [timezoneIndicator removeFromSuperview];
                summerTime=[self.camera getCameraSummartTime];
                
                text = [[NSString alloc] initWithFormat:@"GMT%@%d%@", (camera.nGMTDiff>0)?@"+":@"",camera.nGMTDiff, summerTime? NSLocalizedString(@"(DST)", @""):NSLocalizedString(@"(Standard time)", @"")];
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            }
            
            cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Time Zone", @"")];
            cell.detailTextLabel.text = text;
#if defined(TimeZoneAction)
#else
            [(UISwitch *)cell.accessoryView setOn:summerTime? YES:NO animated:YES];
#endif
            if (text)
                [text release];
        }
        else{
            cell.textLabel.text=@"DST";
            [(UISwitch *)cell.accessoryView setOn:summerTime? YES:NO animated:YES];
        }
	}
	else if (section == [self getWifiSettingSectionIndex]) {
        
        NSString *text = nil;
        
        if ([camera getWiFiSettingSupportOfChannel:0]) {
        
            if (isRecvWiFi && NO == bPendingWifi) {
                
                if (wifiStatus == 0) {
                    
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"None", @"")];
    
                } else if (wifiStatus == 1) {
                    
                    text = [self.wifiSSID copy];
                    
                } else if (wifiStatus == 2) {
                    
					text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", self.wifiSSID, NSLocalizedString(@"Wrong password", @"")]];
                    
                } else if (wifiStatus == 3) {
                    
					text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", self.wifiSSID, NSLocalizedString(@"Weak signal", @"")]];
                    
                } else if (wifiStatus == 4) {
                    
					text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", self.wifiSSID, NSLocalizedString(@"Ready", @"")]];
                    
                } else if (wifiStatus == 10) {
					
					text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Remote Device Timeout", @"")]];
					
				}
                
                [wifiIndicator stopAnimating];
                [wifiIndicator removeFromSuperview];            
            }
            else {

                [cell addSubview:wifiIndicator];
                [wifiIndicator startAnimating];
                wifiIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
            }
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
        }
        else {
            
            text = [[NSString alloc] initWithString:NSLocalizedString(@"Not Supported", @"")];
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"WiFi", @"")];
        cell.detailTextLabel.text = text;
        
        if (text)
            [text release];
    }
    else if (section == [self getSyncSettingSectionIndex]) {
        
        NSString *text = nil;
        cell.detailTextLabel.text = text;
        
        cell.textLabel.text = NSLocalizedString(@"Sync with your cloud account", @"");
//        cell.textLabel.text = camera.bIsSyncOnCloud? NSLocalizedString(@"Sync with your cloud account", @"") : NSLocalizedString(@"The device will not sync with your cloud account", @"");
        UISwitch *syncSwitch = [[UISwitch alloc] init];
        [syncSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [syncSwitch setOn:camera.bIsSyncOnCloud? YES:NO];
        [cell setAccessoryView:syncSwitch];
        [syncSwitch release];
    }
    
    else if (section == [self getEventSettingSectionIndex]) {
        
        NSString *text = nil;
        
        if ([camera getMotionDetectionSettingSupportOfChannel:0]) {
         
            if (motionDetection < 0) {                  
                [cell addSubview:motionIndicator];
                [motionIndicator startAnimating];
                motionIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
            }
            else {                
                [motionIndicator stopAnimating];
                [motionIndicator removeFromSuperview];
            }     
                        
            if (motionDetection == 0) 
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Off", @"")];
            else if (motionDetection > 0 && motionDetection <= 25)
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Low", @"")];
            else if (motionDetection > 25 && motionDetection <= 50) 
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", @"")];
            else if (motionDetection > 50 && motionDetection <= 75) 
                text = [[NSString alloc] initWithString:NSLocalizedString(@"High", @"")];
            else if (motionDetection == 100) 
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Max", @"")];
            else 
                text = nil;
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
        }
        else {
            
            text = [[NSString alloc] initWithString:NSLocalizedString(@"Not Supported", @"")];
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }    
        
        cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Motion Detection", @"")];
        cell.detailTextLabel.text = text;
        
        if (text)
            [text release];
    }
    else if (section == [self getRecordSettingSectionIndex]) {
        
        if (row == [self getRecordSettingRowIndex]) {
         
            NSString *text = nil;
            
            if ([camera getRecordSettingSupportOfChannel:0]) {

                if (recordingMode < 0) {            

                    [cell addSubview:recordIndicator];
                    [recordIndicator startAnimating];
                    recordIndicator.center = CGPointMake(cellIndicator_X, cellIndicator_Y);
                }
                else {

                    [recordIndicator stopAnimating];
                    [recordIndicator removeFromSuperview];
                }      
                                
                if (recordingMode == 0) 
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Off", @"")];
                else if (recordingMode == 1) 
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Full Time", @"")];
                else if (recordingMode == 2) 
                    text = [[NSString alloc] initWithString:NSLocalizedString(@"Alarm", @"")];
                else 
                    text = nil;
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                
            }
            else {
             
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Not Supported", @"")];

                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }      
            
            cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Recording Mode", @"")];
            cell.detailTextLabel.text = text;
            
            if (text)
                [text release];
        }
        else if (row == [self getFormatSDCardRowIndex]) {
                        
            NSString *text = nil;
            
            if ([camera getFormatSDCardSupportOfChannel:0]) {
                
                text = nil;
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            }
            else {
                
                text = [[NSString alloc] initWithString:NSLocalizedString(@"Not Supported", @"")];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            cell.textLabel.text = [NSString stringWithString:NSLocalizedString(@"Format SDCard", @"")];
            cell.detailTextLabel.text = text;
            
            if (text)
                [text release];
        }
    }
#if defined(CameraMailSetting)
    else if (section == [self getDeviceInfoSectionIndex]-1){
        cell.textLabel.text = NSLocalizedString(@"Mail Setting", @"");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
    }
#endif
    else if (section == [self getDeviceInfoSectionIndex]) {
        		
        NSString *text = [[NSString alloc] initWithString:NSLocalizedString(@"About Device", @"")];
        cell.textLabel.text = text;
		cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (text)
            [text release];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
    if( section == [self getTimeZoneSettingSectionIndex] ) {
		return 60;
	}
	else {
		return [super tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	
}

- (BOOL)readyToPushNextVC
{
	if( [arrRequestIoCtrl count] != 0 ) {
		NSLog( @"!!! Ignore by wait RESP !!!" );
		for( NSNumber* number in arrRequestIoCtrl ) {
			NSLog( @"\tIoCtrol: %dL", [number intValue]);
		}
		NSLog( @"---------------------------" );
		return FALSE;
	}
	
	return TRUE;
}

-(void) switchChanged:(id)sender {
    
    UISwitch *check = (UISwitch*)sender;
    
    if (check.tag-7000==0) {
        summerTime = check.on;
        [self.camera setCameraSummaryTime:summerTime];
        [self.tableView reloadData];
    }
    return;
    
    if ( check.isOn ) {
        bIsSync = YES;
        
    }
    else {
        bIsSync = NO;
    }
    
    if (bIsSync != camera.bIsSyncOnCloud) {
        [camera setSync:[[NSNumber numberWithBool:bIsSync] integerValue]];
        
        if (bIsSync==NO) {
            NSString *msg = NSLocalizedString(@"The device will not sync with your cloud account.", @"");
            NSString *OK = NSLocalizedString(@"OK", @"");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:OK otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            DeviceListOnCloud *dloc = [[DeviceListOnCloud alloc] init];
            dloc.delegate = self;
            
            [dloc syncDeviceUID:camera.uid deviceName:camera.name userID:[userDefaults objectForKey:@"cloudUserID"] PWD:[userDefaults objectForKey:@"cloudUserPassword"]];
            [dloc release];
        }
        
        if (database != NULL) {
            if (![database executeUpdate:@"UPDATE device SET sync=? WHERE dev_uid=?", [NSNumber numberWithBool:bIsSync], camera.uid]) {
                NSLog(@"Fail to update device to database.");
            }
        }
    }
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONWritingPrettyPrinted error:&error];
    NSString *result = [dictionary valueForKey:@"status"];
    
    if (![result isEqualToString:@"ok"]) {
        NSString *msg = NSLocalizedString(@"Failed to Sync with your cloud account！", @"");
        NSString *dismiss = NSLocalizedString(@"OK", @"");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:dismiss otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];    
    
    if (section == SECURITYCODE_SECTION_INDEX) {
		if( ![self readyToPushNextVC] ) {
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		//.modify by gxl
        int count = self.navigationController.viewControllers.count;
        if (count >= 2) {
            SecurityCodeController *controller = [[SecurityCodeController alloc] initWithStyle:UITableViewStyleGrouped delegate:[self.navigationController.viewControllers objectAtIndex:count-2]];
            controller.camera = self.camera;
            
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        } else {
            SecurityCodeController *controller = [[SecurityCodeController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
            controller.camera = self.camera;
            
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
        [self.navigationController.viewControllers objectAtIndex:1];
    }
    if (section == [self getVideoSettingSectionIndex]) {
        
        if (row == [self getVideoQualitySettingRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
         
            VideoQualityController *controller = [[VideoQualityController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
            controller.camera = self.camera;
            controller.origValue = videoQuality;
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
        else if (row == [self getVideoFlipSettingRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            
            VideoFlipController *controller = [[VideoFlipController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
            controller.camera = self.camera;
            controller.origValue = videoFlip;
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }    
        else if (row == [self getEnvironmentSettingRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            
            EnvironmentModeController *controller = [[EnvironmentModeController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
            controller.camera = self.camera;
            controller.origValue = envMode;
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
    }
	else if (section == [self getTimeZoneSettingSectionIndex]) {
		if( row == 0 ) {			
			NSLog( @"Hi clicked!!!" );
			if( !isWaitingForSetTimeZoneResp ) {
				/*TimeZoneListController *viewController = [[TimeZoneListController alloc] initWithStyle:UITableViewStylePlain];
				viewController.mTimeZoneChangedDelegate = self;
				[viewController setCurrentTimeZone:camera.strTimeZone tzGMTDiff_In_Mins:camera.nGMTDiff];
				[self.navigationController pushViewController:viewController animated:YES];
				[viewController release];*/
                self.navigationItem.title = NSLocalizedString(@"Cancel", @"");
                int nSelIndex = [self getSelIdxIn:arrTimeZoneTable compareString:camera.strTimeZone];
                
                if( nSelIndex == -1 ) {
                    nSelIndex = camera.nGMTDiff + 11;
                }
                
                ChooseViewController *controller = [[ChooseViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [controller init:1234 delegate:self selectedIndex:nSelIndex itemsArray:arrTimeZoneTable];
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
			}
			else {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
		}
	}
    else if (section == [self getWifiSettingSectionIndex]) {
        
        if (row == [self getWifiSettingRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            
            WiFiNetworkController *controller = [[WiFiNetworkController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
            controller.camera = self.camera;            
            
            if (self.wifiSSID != nil) 
                controller.wifiSSID = self.wifiSSID;
            else
                controller.wifiSSID = nil;
            
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
    }
    else if (section == [self getSyncSettingSectionIndex]) {
        if( ![self readyToPushNextVC] ) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
    }
    else if (section == [self getEventSettingSectionIndex]) {
        
        if (row == [self getMotionDetectionSettingRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            
            MotionDetectionController *controller = [[MotionDetectionController alloc] initWithStyle:UITableViewStyleGrouped delgate:self];
            controller.camera = self.camera;
            controller.origValue = motionDetection;
            
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];            
        }
        
    }
    else if (section == [self getRecordSettingSectionIndex]) {
        
        if (row == [self getRecordSettingRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            
            RecordingModeController *controller = [[RecordingModeController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
            controller.camera = self.camera;
            controller.origValue = recordingMode;
            
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
        else if (row == [self getFormatSDCardRowIndex]) {
			if( ![self readyToPushNextVC] ) {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            
            FormatSDCardController *controller = [[FormatSDCardController alloc] initWithStyle:UITableViewStyleGrouped];
            controller.camera = self.camera;
            
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
    }
#if defined(CameraMailSetting)
    else if (section == [self getDeviceInfoSectionIndex]-1){
        MailSettingController*  controller = [[MailSettingController alloc] initWithStyle:UITableViewStyleGrouped delgate:self];
        controller.camera = self.camera;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
#endif
    else if (section == [self getDeviceInfoSectionIndex]) {
		if( ![self readyToPushNextVC] ) {
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
        
        AboutDeviceController *controller = [[AboutDeviceController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.camera = self.camera;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }

	nLastSelSection = section;
	nLastSelRow = row;
}
- (int)getSelIdxIn:(NSArray*)table compareString:(NSString*)strValue
{
    int index = 0;
    for( NSString* see in table ) {
        if( [see isEqualToString:strValue] ) {
            
            return index;
        }
        
        index++;
    }
    
    return -1;
}
#pragma mark - ChooseDelegate

- (void)didSelected:(int)nTag selectedIndex:(int)nSel itemsArray:(NSArray*)arrItems
{
    if( nTag == 1234 ) {
        
        int nGMTDiff_In_Mins = (nSel - 11);
        
        camera.strTimeZone = [arrTimeZoneTable objectAtIndex:nSel];
        camera.nGMTDiff = nGMTDiff_In_Mins;
        
        [self.tableView reloadData];
        [self onTimeZoneChanged:[arrTimeZoneTable objectAtIndex:nSel] tzGMTDiff_In_Mins:nGMTDiff_In_Mins];
    }
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
        
    if (camera_ == camera) {
		for( NSNumber* number in arrRequestIoCtrl ) {
			if( [number intValue] == (int)type ) {
				[arrRequestIoCtrl removeObject:number];
				break;
			}
		}
        if(type == IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP_EXT) {
            NSLog( @">>>> IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP_EXT" );
            SMsgAVIoctrlTimeZoneExt *s = (SMsgAVIoctrlTimeZoneExt *)data;
            camera.strTimeZone = [[NSString stringWithFormat:@"%s", s->szTimeZoneString] copy];
            camera.nGMTDiff = s->nGMTDiff;
            summerTime  = s->dst_on;
            
            //utcTime = utcTime + camera.nGMTDiff*60*60 + (summerTime? 1*60*60:0);
            
            isWaitingForSetTimeZoneResp = FALSE;
            [self.tableView reloadData];
        }
        else if( type == IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP_EXT ) {
            SMsgAVIoctrlTimeZoneExt *s = (SMsgAVIoctrlTimeZoneExt *)data;
            NSLog(@"TIMEZONEOFFSET:%d",s->nGMTDiff);
            
            isWaitingForSetTimeZoneResp = FALSE;
            [self.tableView reloadData];
            
        }
        
        else if (type == IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP) {
            
            SMsgAVIoctrlGetStreamCtrlResp *s = (SMsgAVIoctrlGetStreamCtrlResp*)data;
            videoQuality = s->quality;
            
            [self.tableView reloadData];
        }
        else if (type == IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP) {
            
            SMsgAVIoctrlGetVideoModeResp *s = (SMsgAVIoctrlGetVideoModeResp*)data;
            videoFlip = s->mode;
                        
            [self.tableView reloadData];
        }
        else if (type == IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP) {
            
            SMsgAVIoctrlGetEnvironmentResp *s = (SMsgAVIoctrlGetEnvironmentResp*)data;
            envMode = s->mode;
                        
            [self.tableView reloadData];
        }
		/*else if(type == (int)IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP) {
			isWaitingForSetTimeZoneResp = FALSE;
			[self.tableView reloadData];
		}
		else if( type == IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP ) {
			SMsgAVIoctrlTimeZone *s = (SMsgAVIoctrlTimeZone *)data;
			if( s->cbSize == sizeof(SMsgAVIoctrlTimeZone) &&
			    s->nIsSupportTimeZone != 0 ) {
				NSLog( @">>>> IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP <OK>\n\tbIsSupportTimeZone:%d\n\tnGMTDiff:%d\n\tstrTimeZone:%@", s->nIsSupportTimeZone, s->nGMTDiff, ( strlen(s->szTimeZoneString) > 0 ) ? [NSString stringWithUTF8String:s->szTimeZoneString]:@"(null)" );
				camera.strTimeZone = [NSString stringWithFormat:@"%s", s->szTimeZoneString];
				camera.nGMTDiff = s->nGMTDiff;
			}
			isWaitingForSetTimeZoneResp = FALSE;
			[self.tableView reloadData];
			[timerTimeZoneTimeOut invalidate];
			[timerTimeZoneTimeOut release];
		}*/
        else if (type == IOTYPE_USER_IPCAM_LISTWIFIAP_RESP) {
            if( bTimerListWifiApResp ) {
				[self.timerListWifiApResp invalidate];
				[timerListWifiApResp release];
				bTimerListWifiApResp = FALSE;
			}
			
            SMsgAVIoctrlListWifiApResp *s = (SMsgAVIoctrlListWifiApResp *)data;
            wifiStatus = 0;
            
			NSLog( @"AP num:%d", s->number );
            for (int i = 0; i < s->number; ++i) {
             
                SWifiAp ap = s->stWifiAp[i];
                NSLog( @" [%d] ssid:%s, mode => %d, enctype => %d, signal => %d%%, status => %d", i, ap.ssid, ap.mode, ap.enctype, ap.signal, ap.status );
                if (ap.status == 1 || ap.status == 2 || ap.status == 3 || ap.status == 4) {
                    self.wifiSSID = [NSString stringWithCString:ap.ssid encoding:NSUTF8StringEncoding];
                    wifiStatus = ap.status;
                }
            }
            
            isRecvWiFi = true;
            bPendingWifi = NO;
            
            [self.tableView reloadData];
        }
        else if (type == IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP) {
            
            SMsgAVIoctrlGetMotionDetectResp *s = (SMsgAVIoctrlGetMotionDetectResp*)data;
            motionDetection = s->sensitivity;
            
            [self.tableView reloadData];
        }
        else if (type == IOTYPE_USER_IPCAM_GETRECORD_RESP) {
            
            SMsgAVIoctrlGetRecordResp *s = (SMsgAVIoctrlGetRecordResp*)data;
            recordingMode = s->recordType;            
            
            [self.tableView reloadData];
        }
        else if (type == IOTYPE_USER_IPCAM_GETWIFI_RESP) {
            
            wifiStatus = 0;
            SMsgAVIoctrlGetWifiResp *s = (SMsgAVIoctrlGetWifiResp *)data;

            self.wifiSSID = [NSString stringWithCString:(const char*)s->ssid encoding:NSUTF8StringEncoding];
            wifiStatus = s->status;
            
            isRecvWiFi = true;
            [self.tableView reloadData];
        }
        else if (type == IOTYPE_USER_IPCAM_GETWIFI_RESP_2) {
            
            wifiStatus = 0;
            SMsgAVIoctrlGetWifiResp2 *s = (SMsgAVIoctrlGetWifiResp2 *)data;
            
            self.wifiSSID = [NSString stringWithCString:(const char*)s->ssid encoding:NSUTF8StringEncoding];
            wifiStatus = s->status;
            
            isRecvWiFi = true;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - RecordingModeDelegate Methods
- (void)didSetRecordingMode:(NSInteger)value {
    
    recordingMode = value;
    [self.tableView reloadData];
}

#pragma mark - MotionDetectionDelegate Methods
- (void)didSetMotionDetection:(NSInteger)value {
    
    motionDetection = value;
    [self.tableView reloadData];
}

#pragma mark - VideoQualityDelegate Methods
- (void)didSetVideoQuality:(NSInteger)value {
    
    isNeedReconn = true;
    videoQuality = value;
    [self.tableView reloadData];
}

#pragma mark - SecurityCodeDelegate Methods
- (void)didChangeSecurityCode:(NSString *)value {

    isNeedReconn = true;
    isChangePasswd = true;
    theNewPassword = [value copy];
}

#pragma mark - VideoFlipDelegate Methods
- (void)didSetVideoFlip:(NSInteger)value {
    
    videoFlip = value;
    [self.tableView reloadData];
}

#pragma mark - EnvironmentModeDelegate Methods
- (void)didSetEnvironmentMode:(NSInteger)value {
    
    envMode = value;
    [self.tableView reloadData];
}

#pragma mark - WiFiNetworkDelegate Methods
- (void)didChangeWiFiAp:(NSString *)wifiSSID_ {
    
    bPendingWifi = YES;
    [self performSelector:@selector(getWifiInfo) withObject:nil afterDelay:30];
    
    self.wifiSSID = wifiSSID_;
    [self.tableView reloadData];
}

#pragma mark - TimeZoneChangedDelegate Methods
- (void) onTimeZoneChanged:(NSString*)tszTimeZone tzGMTDiff_In_Mins:(int)nGMTDiff_In_Mins {
    
    
    /*mIoCtrlData_SetTimeZoneBefore.cbSize = sizeof(mIoCtrlData_SetTimeZoneBefore);
     mIoCtrlData_SetTimeZoneBefore.nIsSupportTimeZone = 1;
     mIoCtrlData_SetTimeZoneBefore.nGMTDiff = camera.nGMTDiff;
     strcpy( mIoCtrlData_SetTimeZoneBefore.szTimeZoneString, [camera.strTimeZone UTF8String] );*/
    
    NSDate* now =  [NSDate date];
    long utcTime_now = (long)[now timeIntervalSince1970];
    
    SMsgAVIoctrlTimeZoneExt64Bit setTimeZone;
    setTimeZone.cbSize = sizeof(setTimeZone);
    setTimeZone.nIsSupportTimeZone = 1;
    setTimeZone.nGMTDiff = nGMTDiff_In_Mins;
    setTimeZone.local_utc_time = (int)(utcTime_now + nGMTDiff_In_Mins*60*60);
    strcpy( setTimeZone.szTimeZoneString, [tszTimeZone UTF8String] );
    setTimeZone.dst_on = (summerTime)? 1 : 0;
    
    NSLog( @"<<< recv IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ_EXT\n\tnIsSupportTimeZone: %d\n\tnGMTDiff: %d\n\tszTimeZoneString: %s\n---- Rise timer ----", setTimeZone.nIsSupportTimeZone, setTimeZone.nGMTDiff, setTimeZone.szTimeZoneString );
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ_EXT Data:(char *)&setTimeZone DataSize:sizeof(setTimeZone)];
    
    isWaitingForSetTimeZoneResp = TRUE;
    //timerTimeZoneTimeOut = [[NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(timeoutSetTimeZoneResp:) userInfo:nil repeats:NO] retain];
    
    [self.tableView reloadData];
}

- (void)timeoutSetTimeZoneResp:(NSTimer *)timer
{
	NSLog( @"!!! IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP TimeOut !!!" );
	isWaitingForSetTimeZoneResp = FALSE;
	
	[timerTimeZoneTimeOut release];
	
	[self.tableView reloadData];
}

- (void)timeOutGetListWifiAPResp:(NSTimer *)timer
{
    if ( -1 == videoFlip) {
        videoFlip = -2 ;    // set timeout flag
        [self.tableView reloadData];
    }
    
    if ( -1 == envMode){
        envMode = -2 ;      //set timeout flag
        [self.tableView reloadData];
    }
    
    
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
		
		isRecvWiFi = true;
		wifiStatus = 10;
		[self.tableView reloadData];
	}
	
	[timerListWifiApResp release];
	
	if( timeOut > 0 ) {
		bTimerListWifiApResp = TRUE;
		timerListWifiApResp = [[NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(timeOutGetListWifiAPResp:) userInfo:[NSNumber numberWithInt:timeOut] repeats:FALSE] retain];
	}
}

-(void)getWifiInfo {
    // get WiFi info
    SMsgAVIoctrlListWifiApReq *structWiFi = malloc(sizeof(SMsgAVIoctrlListWifiApReq));
    memset(structWiFi, 0, sizeof(SMsgAVIoctrlListWifiApReq));
    
	bTimerListWifiApResp = TRUE;
	nTotalWaitingTime = 0;
	timerListWifiApResp = [[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timeOutGetListWifiAPResp:) userInfo:[NSNumber numberWithInt:30] repeats:FALSE] retain];
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_LISTWIFIAP_REQ
                           Data:(char *)structWiFi
                       DataSize:sizeof(SMsgAVIoctrlListWifiApReq)];
    free(structWiFi);
}

- (void)doRefresh
{
	
    isRecvWiFi = false;
    wifiStatus = 0;
//    isNeedReconn = false;
//    isChangePasswd = false;
//    theNewPassword = nil;
	
    videoQuality = -1;
    videoFlip = -1;
    envMode = -1;
    self.wifiSSID = nil;
	
    motionDetection = -1;
    recordingMode = -1;
    
    // register notification center
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIOCtrl:) name:@"didReceiveIOCtrl" object:nil];
    
	arrRequestIoCtrl = [[NSMutableArray alloc] init];
	//	arrRequestIoCtrl = [[NSMutableArray alloc] initWithObjects:
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP],
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP],
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP],
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP],
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_LISTWIFIAP_RESP],
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP],
	//							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GETRECORD_RESP],
	//						nil];
	
    // get video quality
    SMsgAVIoctrlGetStreamCtrlReq *structVideoQuality = malloc(sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    memset(structVideoQuality, 0, sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETSTREAMCTRL_REQ
                           Data:(char *)structVideoQuality
                       DataSize:sizeof(SMsgAVIoctrlGetStreamCtrlReq)];
    free(structVideoQuality);
    
    // get video flip
    SMsgAVIoctrlGetVideoModeReq *structVideoFlip = malloc(sizeof(SMsgAVIoctrlGetVideoModeReq));
    memset(structVideoFlip, 0, sizeof(SMsgAVIoctrlGetVideoModeReq));
    structVideoFlip->channel = 0;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GET_VIDEOMODE_REQ
                           Data:(char *)structVideoFlip
                       DataSize:sizeof(SMsgAVIoctrlGetVideoModeReq)];
    free(structVideoFlip);
    
    
    // get Env Mode
    SMsgAVIoctrlGetEnvironmentReq *structEnvMode = malloc(sizeof(SMsgAVIoctrlGetEnvironmentReq));
    memset(structEnvMode, 0, sizeof(SMsgAVIoctrlGetEnvironmentReq));
    structEnvMode->channel = 0;
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GET_ENVIRONMENT_REQ
                           Data:(char *)structEnvMode
                       DataSize:sizeof(SMsgAVIoctrlGetEnvironmentReq)];
    free(structEnvMode);
	
	// get TimeZone
    isWaitingForSetTimeZoneResp = TRUE;
    SMsgAVIoctrlTimeZoneExt s3={0};
    s3.cbSize = sizeof(s3);
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ_EXT Data:(char *)&s3 DataSize:sizeof(s3)];
    

    // get MotionDetection info
    SMsgAVIoctrlGetMotionDetectReq *structMotionDetection = malloc(sizeof(SMsgAVIoctrlGetMotionDetectReq));
    memset(structMotionDetection, 0, sizeof(SMsgAVIoctrlGetMotionDetectReq));
    
    structMotionDetection->channel = 0;
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETMOTIONDETECT_REQ
                           Data:(char *)structMotionDetection
                       DataSize:sizeof(SMsgAVIoctrlGetMotionDetectReq)];
    free(structMotionDetection);
    
    
    // get RecordingMode info
    SMsgAVIoctrlGetRecordReq *structRecordingMode = malloc(sizeof(SMsgAVIoctrlGetRecordReq));
    memset(structRecordingMode, 0, sizeof(SMsgAVIoctrlGetRecordReq));
    
    structRecordingMode->channel = 0;
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETRECORD_REQ
                           Data:(char *)structRecordingMode
                       DataSize:sizeof(SMsgAVIoctrlGetRecordReq)];
    free(structRecordingMode);
}

@end
