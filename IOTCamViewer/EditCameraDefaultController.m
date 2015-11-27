//
//  EditCameraDefault.m
//  IOTCamViewer
//
//  Created by tutk on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EditCameraDefaultController.h"
#import "EditCameraAdvancedController.h"
#import "AppDelegate.h"
#import "iToast.h"
#import "CameraMultiLiveViewController.h"

@implementation EditCameraDefaultController

@synthesize fieldLabels;
@synthesize textFieldName, textFieldPassword;
@synthesize name, password;
@synthesize camera;
@synthesize delegate;

- (void)keyboardWillShow:(NSNotification *)n
{
    isKeyboardShow = YES;
}

- (void)keyboardWillHide:(NSNotification *)n
{ 
    isKeyboardShow = NO;
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath 
{    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[[dirs objectAtIndex:0] stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (IBAction)back:(id)sender 
{
    
    /*if(isPressReconnButton) {
        NSLog( @"ignore!!!" );
        return;
    }*/
    
    NSString *cameraName = nil;
    NSString *cameraPassword = nil;
    
    if (textFieldName != nil)  {
        cameraName = textFieldName.text;
        cameraName = [cameraName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if (textFieldPassword != nil) {
        cameraPassword = textFieldPassword.text;
        cameraPassword = [cameraPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if (cameraName == nil || [cameraName length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"Camera Name can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (cameraPassword == nil || [cameraPassword length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"Camera Password can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)alertInfo:(NSString *)message withTitle:(NSString *)title{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];
    [alert release];
}
- (IBAction)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
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
            NSString *getURLString = [NSString stringWithFormat:argsString, hostString, deviceTokenString, uid, appidString, uuid];
#ifdef DEF_APNSTest
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");
#endif
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
- (void)viewDidLoad {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate->passwordChanged = NO;
    
    self.fieldLabels = [[[NSArray alloc] initWithObjects:
                        NSLocalizedString(@"Name", @""), 
                        NSLocalizedString(@"Password", @""), nil] autorelease];
    
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
    
    self.navigationItem.title = NSLocalizedString(@"Edit Camera", @"");

    self.name = [NSString stringWithString:camera.name];
    self.password = [NSString stringWithString:camera.viewPwd];
    
    isKeyboardShow = false;
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    self.delegate = nil;
    self.fieldLabels = nil;
    self.textFieldName = nil;
    self.textFieldPassword = nil;
    self.camera = nil;
    self.name = nil;
    self.password = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (camera != nil)
        camera.delegate2 = self;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)dealloc {    
    
    [fieldLabels release];
    [textFieldName release];
    [textFieldPassword release];
    [camera release];
    [name release];
    [password release];
    [super dealloc];
}

#pragma mark - Table DataSoruce Methods 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
#if defined(MAJESTICIPCAMP)
    return 2;
#endif
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    if (section == DEVICEINFO_SECTION_INDEX)
        return 2;
    else if (section == ADVANCED_SECTION_INDEX)
        return 1;
#if defined(MAJESTICIPCAMP)
#else
    else if (section == RECONNECT_SECTION_INDEX)
        return 1;
    else if (section == DELETE_SECTION_INDEX)
        return 1;
#endif
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 90 : 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    if (section == 0) {
        
        UIImageView *snapshotImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 87, 65)];
        NSString *imgFullName = [self pathForDocumentsResource:[NSString stringWithFormat:@"%@.jpg", camera.uid]];        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imgFullName];        
        snapshotImgView.image = fileExists ? [UIImage imageWithContentsOfFile:imgFullName] : [UIImage imageNamed:@"videoClip.png"];
        
        UILabel *uidTextView = [[UILabel alloc] initWithFrame:CGRectMake(105, 30, 210, 20)];
        uidTextView.layer.shadowColor = [[UIColor whiteColor] CGColor];
        uidTextView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        uidTextView.layer.shadowOpacity = 1.0f;
        uidTextView.layer.shadowRadius = 1.0f;
        uidTextView.backgroundColor = [UIColor clearColor];
        uidTextView.userInteractionEnabled = NO;
        uidTextView.text = camera.uid;
        uidTextView.font = [uidTextView.font fontWithSize:15];
#if defined(SVIPCLOUD)
        uidTextView.textColor=HexRGB(0x3d3c3c);
#endif
        
        UIView *view = [[UIView alloc] init];
        [view setBackgroundColor:[UIColor clearColor]];  
        [view addSubview:snapshotImgView];
        [view addSubview:uidTextView];
        
        [snapshotImgView release];
        [uidTextView release];
        
        return [view autorelease];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *SectionTableIdentifier = @"SectionTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionTableIdentifier];
    
    if (cell == nil) {
        
        if (section == DEVICEINFO_SECTION_INDEX) {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionTableIdentifier]
                    autorelease];
            
            cell.textLabel.text = [fieldLabels objectAtIndex:row];

            if (row == NAME_ROW_INDEX) {
                
                textFieldName = [[UITextField alloc] initWithFrame: CGRectMake(135, 11, 160, 25)];
                textFieldName.clearsOnBeginEditing = NO;
                textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
                [textFieldName setDelegate:self];
                [textFieldName addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];        
                [cell.contentView addSubview:textFieldName]; 
            }         
            else if (row == PASSWORD_ROW_INDEX) {
            
                textFieldPassword = [[UITextField alloc] initWithFrame: CGRectMake(135, 11, 160, 25)];
                textFieldPassword.clearsOnBeginEditing = NO;
                textFieldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
                textFieldPassword.secureTextEntry = YES;
                [textFieldPassword setDelegate:self];
                [textFieldPassword addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];        
                [cell.contentView addSubview:textFieldPassword];            
            }
        }
        else if (section == ADVANCED_SECTION_INDEX) {
            
            if (row == ADVANCED_ROW_INDEX) {
                
                if (camera != nil && camera.sessionState == CONNECTION_STATE_CONNECTED) {
                    
                    cell = [[[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SectionTableIdentifier]
                            autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    
                } else {
                    
                    cell = [[[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SectionTableIdentifier]
                            autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        }
#if defined(MAJESTICIPCAMP)
#else
        else if (section == RECONNECT_SECTION_INDEX) {
            
            if (row == RECONNECT_ROW_INDEX) {
                
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SectionTableIdentifier] autorelease];
            }
        }
        else if (section == DELETE_SECTION_INDEX) {
            
            if (row == DELETE_ROW_INDEX) {
                
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SectionTableIdentifier] autorelease];
            }
        }
#endif
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (section == DEVICEINFO_SECTION_INDEX) {
                
        UILabel *label = (UILabel *)[cell viewWithTag:LABEL_TAG];
        UITextField *textField = nil;
        
        for (UIView *oneView in cell.contentView.subviews) {
            if ([oneView isMemberOfClass:[UITextField class]])
                textField = (UITextField *)oneView;
        }
        
        label.text = [fieldLabels objectAtIndex:row];  
        label.backgroundColor = [UIColor clearColor];
#if defined(SVIPCLOUD)
        label.textColor=HexRGB(0x3d3c3c);
#endif
        
        NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
        
        switch (row) {
                
            case NAME_ROW_INDEX:
                textField.text = self.name;
                break;
                
            case PASSWORD_ROW_INDEX:
                textField.text = self.password;
                break;
                
            default:
                break;
        }
        
        textField.tag = row;
        [rowAsNum release];
    }
    else if (section == ADVANCED_SECTION_INDEX) {
        
        if (row == ADVANCED_ROW_INDEX) {
            
            cell.textLabel.text = NSLocalizedString(@"Advanced Setting", @"");
            
            if (camera != nil && camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;         
            else            
                cell.accessoryType = UITableViewCellAccessoryNone;  
        }
    }
    else if (section == RECONNECT_SECTION_INDEX) {
        
        if (row == RECONNECT_ROW_INDEX) {
            
            cell.textLabel.text = NSLocalizedString(@"Reconnect", @"");            
            
            if ( camera != nil ) {
				
				BOOL bReset = isPressReconnButton;
				
                if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Connecting...", @""), camera.connTimes, camera.connFailErrCode];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Connecting...", @"");
					}
                    NSLog(@"connecting");
					bReset = FALSE;
                }
                else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Off line", @""), camera.connTimes, camera.connFailErrCode];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Off line", @"");
					}
                    NSLog(@"off line");
                }
                else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Unknown Device", @""), camera.connTimes, camera.connFailErrCode];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Unknown Device", @"");
					}
                    NSLog(@"unknown device");
                }
                else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Timeout", @""), camera.connTimes, camera.connFailErrCode];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Timeout", @"");
					}
                    NSLog(@"timeout");
                }
                else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ A.%d(%dL)", NSLocalizedString(@"Unsupported", @""), camera.connTimes, camera.connFailErrCode];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Unsupported", @"");
					}
                    NSLog(@"unsupported");
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
                    cell.detailTextLabel.text = NSLocalizedString(@"Connect Failed", @"");
                    NSLog(@"connected failed");
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ [%@]%d,C:%d,D:%d,r%d", NSLocalizedString(@"Online", @""), [MyCamera getConnModeString:camera.sessionMode], camera.connTimes, camera.natC, camera.natD, camera.nAvResend];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Online", @"");
					}
                    NSLog(@"online");
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    if (appDelegate->passwordChanged==YES){
                        [self doMapping:camera.uid];
                    }
                    
                    if (isReconnect) {
                        if (database != NULL) {
                            if (![database executeUpdate:@"UPDATE device SET dev_nickname=?, view_pwd=? WHERE dev_uid=?", camera.name, self.password, camera.uid]) {
                                NSLog(@"Fail to update device to database.");
                            }
                        }
                        
                        [self.delegate didChangeSetting:self.camera];
                    
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_CONNECTING)", NSLocalizedString(@"Connecting...", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Connecting...", @"");
					}
                    NSLog(@"connecting");
					bReset = FALSE;
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED)
                {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_DISCONNECTED)", NSLocalizedString(@"Off line", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Off line", @"");
					}
                    NSLog(@"off line");
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_UNKNOWN_DEVICE)", NSLocalizedString(@"Unknown Device", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Unknown Device", @"");
					}
                    NSLog(@"unknown device");
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_WRONG_PASSWORD)", NSLocalizedString(@"Wrong Password", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Wrong Password", @"");
					}
                    NSLog(@"wrong password");
                    
                    //Un-mapping
                    [self unRegMapping:camera.uid];
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_TIMEOUT)", NSLocalizedString(@"Timeout", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Timeout", @"");
					}
                    NSLog(@"timeout");
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_UNSUPPORTED)", NSLocalizedString(@"Unsupported", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Unsupported", @"");
					}
                    NSLog(@"unsupported");
                }
                else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
					if( g_bDiagnostic ) {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ B.%d(CONNECTION_STATE_NONE)", NSLocalizedString(@"Connecting...", @""), camera.connTimes];
					}
					else {
                    	cell.detailTextLabel.text = NSLocalizedString(@"Connecting...", @"");
					}
                    NSLog(@"wait for connecting");
                }

				if( bReset ) {
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 3.0), dispatch_get_main_queue(), ^(void){
						//cell.detailTextLabel.text = nil;
						isPressReconnButton = FALSE;
					});
				}
            }
            else if( camera.sessionState == CONNECTION_STATE_CONNECTING ) {
				cell.detailTextLabel.text = NSLocalizedString(@"Connecting...", @"");
			}
        }
    }
    
    else if (section == DELETE_SECTION_INDEX) {
        
        if (row == DELETE_ROW_INDEX) {
            cell.textLabel.text = NSLocalizedString(@"Remove this device", @"");
        }
    }
    
#if defined(SVIPCLOUD)
    cell.textLabel.textColor=HexRGB(0x3d3c3c);
#endif
    
    return cell;
}

#pragma mark - Table Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger section = [indexPath section];
    
    if (section == DEVICEINFO_SECTION_INDEX) {        
        return nil;
    }
    else {        
        if (textFieldName != nil) [textFieldName resignFirstResponder];
        if (textFieldPassword != nil) [textFieldPassword resignFirstResponder];
            
        return indexPath;
    }
}	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger section = [indexPath section];    
    NSUInteger row = [indexPath row];

    if (section == ADVANCED_SECTION_INDEX) {
        
        if (row == ADVANCED_ROW_INDEX) {
         
            if (camera != nil && camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
                
                EditCameraAdvancedController *controller = [[EditCameraAdvancedController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
                controller.camera = self.camera;
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
            }
        }
    }
    else if (section == RECONNECT_SECTION_INDEX) {
        
        if (row == RECONNECT_ROW_INDEX) {
			
			if( isPressReconnButton ||
			    camera.sessionState == CONNECTION_STATE_CONNECTING ||
			    (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING)) {
				NSLog( @"ignore!!!" );
				return;
			}
            
            if ([textFieldPassword.text length] == 0) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"") message:NSLocalizedString(@"Camera Password can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                return;
            }
            
            if (camera != nil) {
                
                isReconnect = YES;
                
                isPressReconnButton = TRUE;
                
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
					// NSString *acc = [camera getViewAccountOfChannel:0];
					NSString *pwd = textFieldPassword.text;
                    [database executeUpdate:@"update device set view_pwd=? where dev_uid=?",pwd,self.camera.uid];
					
					[self.camera disconnect];
					
					[self.camera setViewPwd:pwd];
					[self.camera connect:camera.uid];
					[self.camera start:0];
					
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
                    

                    
				});
							   
				[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = NSLocalizedString(@"Connecting...", @"");
            }
        }
    }
    
    else if (section == DELETE_SECTION_INDEX) {
        
        if (row == DELETE_ROW_INDEX) {
#if defined(BayitCam)
            NSString *msg = NSLocalizedStringFromTable(@"Are you sure you want to delete this camera?",@"bayitcam", @"");
#else
            NSString *msg = NSLocalizedString(@"Sure to remove?", @"");
#endif
            
            NSString *no = NSLocalizedString(@"NO", @"");
            NSString *yes = NSLocalizedString(@"YES", @"");
            NSString *caution = NSLocalizedString(@"Caution!", @"");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:caution message:msg delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
            [alert show];
            [alert release];
        }
    }
}

#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 ) {

        camera.delegate2 = nil;
        
        [self.navigationController popViewControllerAnimated:NO];
        [self.delegate didRemoveDevice:camera];
    }
}

#pragma mark - Text Field Delegate Methods

- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string {
    
    /*
    if (textField.tag == UID_ROW_INDEX) {
        
        NSUInteger len = [textField.text length] + [string length] - range.length;  
        
        if (len <= 20)
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
        
        return NO;
    }
    */
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == textFieldPassword && textField.text != self.password){
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate->passwordChanged = YES;
    }
    
    if (textField == textFieldName) self.name = textField.text;
    if (textField == textFieldPassword) self.password = textField.text;
    
    NSString *cameraName=textFieldName.text;
    NSString *cameraPassword=textFieldPassword.text;
    
    if(![cameraName isEqualToString:self.camera.name]||![cameraPassword isEqualToString:self.camera.viewPwd]){
        
        SMsgAVIoctrlSetPasswdReq *s2 = (SMsgAVIoctrlSetPasswdReq *)malloc(sizeof(SMsgAVIoctrlSetPasswdReq));
        memcpy(s2->oldpasswd, [self.camera.viewPwd UTF8String], [self.camera.viewPwd length]);
        memcpy(s2->newpasswd, [cameraPassword UTF8String], [cameraPassword length]);
        [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETPASSWORD_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlSetPasswdReq)];
        free(s2);
        
        [self.camera setName:cameraName];
        [self.camera setViewAcc:@"admin"];
        [self.camera setViewPwd:cameraPassword];
        
        [self.delegate didChangeSetting:self.camera];
        
        if (database != NULL) {
            if (![database executeUpdate:@"UPDATE device SET dev_nickname=?, view_pwd=? WHERE dev_uid=?", cameraName, cameraPassword, camera.uid]) {
                NSLog(@"Fail to update device to database.");
            }
        }
        
#if defined(IDHDCONTROL)
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HttpTool *httpTool=[HttpTool shareInstance];
            NSDictionary *dic=@{@"id":[NSString stringWithFormat:@"%ld",(long)[AccountInfo getUserId]],@"uuid":self.camera.uid,@"pwd":cameraPassword};
            [httpTool JsonPostRequst:@"/index.php?ctrl=app&act=chgPwd" parameters:dic success:^(id responseObject) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                NSInteger code=[responseObject[@"code"]integerValue];
                NSString *msg=responseObject[@"msg"];
                if(code==1){
                    [self alertInfo:msg withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
                }
                else{

                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self alertInfo:error.localizedDescription withTitle:NSLocalizedStringFromTable(@"提示", @"login", nil)];
            }];
#else
            [self.camera setName:cameraName];
            [self.camera setViewAcc:@"admin"];
            [self.camera setViewPwd:cameraPassword];
            [self.delegate didChangeSetting:self.camera];
        if (database != NULL) {
            if (![database executeUpdate:@"UPDATE device SET dev_nickname=?, view_pwd=? WHERE dev_uid=?", cameraName, cameraPassword, camera.uid]) {
                NSLog(@"Fail to update device to database.");
            }
        }
#endif
    }
    
}

#pragma mark - SecurityCodeDelegate Methods
- (void)didChangeSecurityCode:(NSString *)value {
    
    isNeedReconn = true;
    self.password = [value copy];
    textFieldPassword.text = self.password;
    
    NSLog(@"change security code(%@) in EditCameraDefaultController", textFieldPassword.text);
    
    if (isNeedReconn) {
        [NSThread sleepForTimeInterval:0.5];
        [self.camera stop:0];
        [self.camera disconnect];
    }
    
    [self.tableView reloadData];
    
    NSString *msg = NSLocalizedString(@"Security code is changed, Please reconnect!", @"");
    NSString *ok = NSLocalizedString(@"OK", @"");
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - EditCameraAdvancedDelegate Methods
- (void)didChangeAdvancedSetting:(NSString *)newPassword :(BOOL)needReconn {
    
    self.password = newPassword;
    isNeedReconn = needReconn;
    
    NSLog(@"change security code(%@) in EditCameraDefaultController", newPassword);

    [self.tableView reloadData];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didChangeSessionStatus:(NSInteger)status
{
    [self.tableView reloadData];
    if (camera_ == camera) {
        
        if (!isKeyboardShow) {
            [self.tableView reloadData];
        }
    }
    
    //NSLog(@"_didChangeSessionStatus:%d", status);
}

- (void)camera:(Camera *)camera_ _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    [self.tableView reloadData];
    if (camera_ == camera) {
        
        if (!isKeyboardShow) {
            [self.tableView reloadData];
        }
    }
    
    //NSLog(@"didChangeChannel:%d Status:%d", channel, status);
}
-(void)camera:(MyCamera *)camera _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size{
    if(type==IOTYPE_USER_IPCAM_SETPASSWORD_RESP){
        SMsgAVIoctrlSetPasswdReq *da=(SMsgAVIoctrlSetPasswdReq *)data;
        NSLog(@"%@",da);
    }
}

@end
