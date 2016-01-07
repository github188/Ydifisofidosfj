//
//  EditCameraDefault.h
//  IOTCamViewer
//
//  Created by tutk on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define NUMBER_OF_EDITABLE_ROWS 3
#define LABEL_TAG 4096
#define LABEL_UID_TAG 4097
#define INDICATOR_TAG 2048

#define DEVICEINFO_SECTION_INDEX 0
#define ADVANCED_SECTION_INDEX 1
#define RECONNECT_SECTION_INDEX 2
#define DELETE_SECTION_INDEX 3
#define REBOOT_SECTION_INDEX 4

#define NAME_ROW_INDEX 0
// #define UID_ROW_INDEX 0
#define PASSWORD_ROW_INDEX 1

#define ADVANCED_ROW_INDEX 0

#define RECONNECT_ROW_INDEX 0

#define DELETE_ROW_INDEX 0

#define REBOOT_ROW_INDEX 0

#import <UIKit/UIKit.h>
#import "MyCamera.h"
#import "ChangeCameraSettingDelegate.h"
#import "EditCameraAdvancedController.h"
#import "SecurityCodeController.h"

@protocol EditCameraDefaultDelegate;

@interface EditCameraDefaultController : UITableViewController <UITextFieldDelegate, EditCameraAdvancedDelegate, MyCameraDelegate,SecurityCodeDelegate> {
        
    MyCamera *camera;       
    NSArray *fieldLabels;
    UITextField *textFieldName;
    UITextField *textFieldPassword;
    
    NSString *name;
    NSString *password;
    BOOL isNeedReconn;
    BOOL isPressReconnButton;
    BOOL isKeyboardShow;
    BOOL passwordChanged;
    BOOL isReconnect;
    
    id<EditCameraDefaultDelegate> delegate;
}

//@property (nonatomic, retain) id<ChangeCameraSettingDelegate> delegate;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) UITextField *textFieldName;
@property (nonatomic, retain) UITextField *textFieldPassword;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, assign) id<EditCameraDefaultDelegate> delegate;

- (IBAction)back:(id)sender;

@end

@protocol EditCameraDefaultDelegate

@optional
- (void) didRemoveDevice:(MyCamera *)removedCamera;
- (void) didChangeSetting:(MyCamera *)changedCamera;

@end

