//
//  SecurityCodeController.h
//  IOTCamViewer
//
//  Created by tutk on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>

#define NUMBER_OF_EDITABLE_ROWS 3
#define LABEL_TAG 4096

#define OLDPASSWORD_ROW_INDEX 0
#define NEWPASSWORD_ROW_INDEX 1
#define CONFIRMPASSWORD_ROW_INDEX 2

@class MyCamera;

@protocol SecurityCodeDelegate;

@interface SecurityCodeController : UITableViewController <UITextFieldDelegate,MyCameraDelegate> {
    
    MyCamera *camera;
    NSArray *labelItems;
    UITextField *textFieldOrigPassword;
    UITextField *textFieldNewPassword;
    UITextField *textFieldConfirmPassword;

    UIActivityIndicatorView *passwdIndicator;
    
    id<SecurityCodeDelegate> delegate;
}

@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSArray *labelItems;
@property (nonatomic, retain) UITextField *textFieldOrigPassword;
@property (nonatomic, retain) UITextField *textFieldNewPassword;
@property (nonatomic, retain) UITextField *textFieldConfirmPassword;

@property (nonatomic, assign) id<SecurityCodeDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<SecurityCodeDelegate>)delegate;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@protocol SecurityCodeDelegate

- (void) didChangeSecurityCode:(NSString *)newPassword;

@end
