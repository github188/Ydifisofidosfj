//
//  EditWiFiPasswordController.m
//  IOTCamViewer
//
//  Created by tutk on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "EditWiFiPasswordController.h"

@implementation EditWiFiPasswordController

@synthesize tableView;
@synthesize textFieldBeingEdited;
@synthesize camera;
@synthesize ssid;
@synthesize ssid_length;
@synthesize mode;
@synthesize enctype;
@synthesize delegate;

BOOL bDoWaiting = FALSE;

-(void) checkTimeout {
    if ( true == bDoWaiting){
        
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		UIActivityIndicatorView* waitView = (UIActivityIndicatorView*)[cell viewWithTag:77];
		if( waitView ) {
			[waitView stopAnimating];
			[waitView removeFromSuperview];
		}
		
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"Incorrect password for %@", @""), ssid]  delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)join:(id)sender {
    
    NSString *password = nil;
	
	bDoWaiting = FALSE;
    
    if (textFieldBeingEdited != nil)        
        password = textFieldBeingEdited.text;

    if (password != nil && [password length] > 0) {
		
		if( [password length] <= 30 ) {
    
			SMsgAVIoctrlSetWifiReq *s = malloc(sizeof(SMsgAVIoctrlSetWifiReq));
			memcpy(s->ssid, [ssid UTF8String], 32);
			memcpy(s->password, [password UTF8String], 32);
			s->enctype = enctype;
			s->mode = mode;
			
			[camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETWIFI_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlSetWifiReq)];
			
			free(s);
			bDoWaiting = TRUE;
            
            [self performSelector:@selector(checkTimeout) withObject:nil afterDelay:30];
		}
		else {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The password is more than 30 characters", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
			
			[alert show];
			[alert release];
		}
    }
    else {
     
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"Please enter password for %@", @""), ssid] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
	
	if( bDoWaiting ) {
		UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		
		UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
		//indicator.center = CGPointMake( self.textFieldBeingEdited.frame.origin.x - 20, self.textFieldBeingEdited.frame.origin.y + (self.textFieldBeingEdited.frame.size.height/2) );
        indicator.center = CGPointMake( 260, 22 );
        
        indicator.tag = 77;
		[cell addSubview:indicator];
		[indicator startAnimating];
        [indicator release];
	}
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<EditWiFiPasswordDelegate>)delegate_ {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
        self.delegate = delegate_;
    
    return self;
}

#pragma mark - View lifecycle
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{    
    self.navigationItem.title = NSLocalizedString(@"Enter Password", @"");
//    self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"Please enter password for %@", @""), ssid];

    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:NSLocalizedString(@"Cancel" , @"")
                                     style:UIBarButtonItemStylePlain 
                                     target:self 
                                     action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:NSLocalizedString(@"Join", @"")
                                   style:UIBarButtonItemStyleDone 
                                   target:self 
                                   action:@selector(join:)];
    self.navigationItem.rightBarButtonItem = joinButton;
    [joinButton release];    
    
    
    textFieldBeingEdited.frame = CGRectMake(115, 9, 180, 25);
    textFieldBeingEdited.clearsOnBeginEditing = NO;
    textFieldBeingEdited.secureTextEntry = YES;
    
    bDoWaiting = FALSE;
    
    [super viewDidLoad];
}


- (void)viewDidUnload {
    
    textFieldBeingEdited = nil;
    ssid = nil;
    camera = nil;
    tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {

    if (camera != nil)
        camera.delegate2 = self;
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dealloc {
    
    self.delegate = nil;
    
    [textFieldBeingEdited release];    
    [ssid release];
    [camera release];
    [tableView release];
    [super dealloc];
}


#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]
                autorelease];
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, 100, 25)];        
        label.text = NSLocalizedString(@"Password", @"");  
        label.textAlignment = UITextAlignmentRight;
        label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        label.backgroundColor = [UIColor clearColor];
        label.opaque = NO;
        [cell.contentView addSubview:label];
        [label release];       
        
        [textFieldBeingEdited setDelegate:self];
        [textFieldBeingEdited becomeFirstResponder];
        [textFieldBeingEdited setReturnKeyType:UIReturnKeyJoin];
        textFieldBeingEdited.clearButtonMode = UITextFieldViewModeWhileEditing;
        [cell.contentView addSubview:textFieldBeingEdited];            
    }
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - TextField Delegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [self join:nil];
    return YES;
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
       
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_SETWIFI_RESP) {
        NSLog( @"IOTYPE_USER_IPCAM_SETWIFI_RESP received." );
		
        
		UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		UIActivityIndicatorView* waitView = (UIActivityIndicatorView*)[cell viewWithTag:77];
		if( waitView ) {
			[waitView stopAnimating];
			[waitView removeFromSuperview];
		}
		
        int result = -1;
        
        SMsgAVIoctrlSetWifiResp *s = (SMsgAVIoctrlSetWifiResp *)data;
        result = s->result;
        
        if (result == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate didSetPasswordSuccess:ssid];
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"Incorrect password for %@", @""), ssid]  delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }            
    }
}

@end
