//
//  SecurityCodeController.m
//  IOTCamViewer
//
//  Created by tutk on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MyCamera.h"
#import <IOTCamera/AVIOCTRLDEFs.h>
#import "SecurityCodeController.h"

@implementation SecurityCodeController

@synthesize camera;
@synthesize labelItems;
@synthesize textFieldOrigPassword, textFieldNewPassword, textFieldConfirmPassword;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<SecurityCodeDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}

- (IBAction)save:(id)sender {
    
    NSString *origPassword =nil;
    NSString *newPassword = nil;
    NSString *confirmPassword = nil;
    
    if (self.textFieldOrigPassword != nil) origPassword = textFieldOrigPassword.text;
    if (self.textFieldNewPassword != nil) newPassword = textFieldNewPassword.text;
    if (self.textFieldConfirmPassword != nil) confirmPassword = textFieldConfirmPassword.text;
    
    if (/*[origPassword length] == 0 ||*/ [newPassword length] == 0 || [confirmPassword length] == 0) {
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please input the password", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Camera Password can not be empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        return ;
    }
    
	if( nil == origPassword || NSOrderedSame != [origPassword compare:self.camera.viewPwd] ) {
		
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"The old password is invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
	}
    
    if (![newPassword isEqualToString:confirmPassword]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"The new password and confirm password do not match", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }    

    if ([newPassword length] > 15 || [confirmPassword length] > 15) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"The new password is more than 15 characters", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    // send ioctrl to change password of device.
    SMsgAVIoctrlSetPasswdReq *structSetPassword = malloc(sizeof(SMsgAVIoctrlSetPasswdReq));
    memset(structSetPassword, 0, sizeof(SMsgAVIoctrlSetPasswdReq));
    memcpy(structSetPassword->oldpasswd, [origPassword UTF8String], [origPassword length]);
    memcpy(structSetPassword->newpasswd, [newPassword UTF8String], [newPassword length]);
    
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETPASSWORD_REQ Data:(char *)structSetPassword DataSize:sizeof(SMsgAVIoctrlSetPasswdReq)];
    free(structSetPassword);    
    
//    NSLog(@"change security code(%@) in SecurityCodeController", newPassword);
//    if (self.delegate) [self.delegate didChangeSecurityCode:newPassword];
//    
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    passwdIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.view addSubview:passwdIndicator];
    [passwdIndicator startAnimating];
    passwdIndicator.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2);
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    camera.delegate2 = self;
    
    labelItems = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Old", @""),
                  NSLocalizedString(@"New", @""), 
                  NSLocalizedString(@"Confirm", @""), nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"Cancel", @"")
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"") 
                                              style:UIBarButtonItemStylePlain 
                                              target:self 
                                              action:@selector(save:)];
    
    self.navigationItem.title = NSLocalizedString(@"Security Code", @"");
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    self.delegate = nil;
    self.camera = nil;
    self.labelItems = nil;
    self.textFieldOrigPassword = nil;
    self.textFieldNewPassword = nil;
    self.textFieldConfirmPassword = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    
    self.delegate = nil;
    [camera release];
    [labelItems release];
    [textFieldOrigPassword release];
    [textFieldNewPassword release];
    [textFieldConfirmPassword release];
    [super dealloc];
}

#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 3 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SecurityCodeCellIdentifier = @"SecurityCodeCellIdentifier";
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SecurityCodeCellIdentifier];
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:SecurityCodeCellIdentifier] autorelease];
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 10, 125, 25)];
        label.textAlignment = UITextAlignmentRight;
        label.tag = LABEL_TAG;
        label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        [cell.contentView addSubview:label];
        [label release];
        
        UITextField *textField = nil;
        if (row == OLDPASSWORD_ROW_INDEX) {
            
            textField =[[UITextField alloc] initWithFrame: CGRectMake(140, 12, 150, 25)];
            self.textFieldOrigPassword = textField;
            self.textFieldOrigPassword.clearsOnBeginEditing = NO;
            [self.textFieldOrigPassword setDelegate:self];
            [self.textFieldOrigPassword addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            [cell.contentView addSubview:self.textFieldOrigPassword];
            [textField release];
        }
        else if (row == NEWPASSWORD_ROW_INDEX) {
            textField =[[UITextField alloc] initWithFrame: CGRectMake(140, 12, 150, 25)];
            self.textFieldNewPassword = textField;
            self.textFieldNewPassword.clearsOnBeginEditing = NO;
            [self.textFieldNewPassword setDelegate:self];
            [self.textFieldNewPassword addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            [cell.contentView addSubview:self.textFieldNewPassword];
            [textField release];
        }
        else if (row == CONFIRMPASSWORD_ROW_INDEX) {
        
            textField =[[UITextField alloc] initWithFrame: CGRectMake(140, 12, 150, 25)];
            self.textFieldConfirmPassword =textField;
            self.textFieldConfirmPassword.clearsOnBeginEditing = NO;
            [self.textFieldConfirmPassword setDelegate:self];
            [self.textFieldConfirmPassword addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            [cell.contentView addSubview:self.textFieldConfirmPassword];
            
            [textField release];
        }        
    }
    
	
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL_TAG];
    UITextField *textField = nil;
    
    for (UIView *oneView in cell.contentView.subviews) {
        if ([oneView isMemberOfClass:[UITextField class]])
            textField = (UITextField *)oneView;
    }
    
    label.text = [labelItems objectAtIndex:row];  
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    
    NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
    
    switch (row) {
            
        case OLDPASSWORD_ROW_INDEX:
            textField.secureTextEntry = YES;
            textField.placeholder = NSLocalizedString(@"Old Password", @"");
            break;
            
        case NEWPASSWORD_ROW_INDEX:
            textField.secureTextEntry = YES;
            textField.placeholder = NSLocalizedString(@"New Password", @"");
            break;
            
        case CONFIRMPASSWORD_ROW_INDEX:
			textField.secureTextEntry = YES;
            textField.placeholder = NSLocalizedString(@"Confirm Password", @"");
            break;
            
        default:
            break;
    }
    
    textField.tag = row;
    [rowAsNum release];
    
    return cell;    
}

- (IBAction)textFieldDone:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - TableView Delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    if (camera_ == camera) {
        if(type == IOTYPE_USER_IPCAM_SETPASSWORD_RESP ) {
			NSLog( @">>>> IOTYPE_USER_IPCAM_SETPASSWORD_RESP" );
            SMsgAVIoctrlSetPasswdResp *s = (SMsgAVIoctrlSetPasswdResp *)data;
            if (s->result==0) {
                [passwdIndicator stopAnimating ];//停止
                NSString *newPassword = nil;
                if (self.textFieldNewPassword != nil) newPassword = textFieldNewPassword.text;
                NSLog(@"change security code(%@) in SecurityCodeController", newPassword);
                if (self.delegate) {
                    [self.delegate didChangeSecurityCode:newPassword];
                }
                // [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                //  [self.navigationController popToViewController:self.delegate animated:YES];
                int count = self.navigationController.viewControllers.count;
                if (count >= 3) {
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-3] animated:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
            }
            
		}
    }
}

@end
