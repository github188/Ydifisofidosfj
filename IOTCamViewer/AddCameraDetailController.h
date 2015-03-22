//
//  AddCameraDetailController.h
//  IOTCamViewer
//
//  Created by tutk on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import "AddCameraDelegate.h"
#import "FMDatabase.h"
#import "ZXingWidgetController.h"
#import "LANSearchController.h"
#import "Categories.h"

@class Camera;

#define NUMBER_OF_EDITABLE_ROWS 3

extern NSMutableArray *camera_list;
extern FMDatabase *database;

@interface AddCameraDetailController : UIViewController 
<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,ZXingDelegate, LANSearchDelegate> {
    
    NSArray *fieldLabels;
    UITextField *textFieldName;
    UITextField *textFieldUID;
    UITextField *textFieldPassword;
    UITableView *tableView;
    NSString *uid;
    NSString *ssid;
    NSString *name;
    BOOL isNameFieldBecomeisFirstResponder;
    BOOL isPasswordFieldBecomeFirstResponder;
    
    id<AddCameraDelegate> delegate;
    
    IBOutlet UILabel *SSID;
    IBOutlet UILabel *lanSearch;
    IBOutlet UIButton *add;
    IBOutlet UIButton *cancel;
    IBOutlet UIButton *syncButton;
    IBOutlet UILabel *syncLabel;
    IBOutlet UIView *checkView;
    IBOutlet UIView *noWiFiSetting;
    BOOL isSyncOnCloud;
    BOOL isAddToCloud;
    BOOL isLogin;
    
    @public
    BOOL isFromDOC;
}

@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) UITextField *textFieldName;
@property (nonatomic, retain) UITextField *textFieldUID;
@property (nonatomic, retain) UITextField *textFieldPassword;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (copy) NSString *uid;
@property (copy) NSString *ssid;
@property (copy) NSString *name;
@property (nonatomic, assign) id<AddCameraDelegate> delegate;
@property(nonatomic) BOOL isFromAutoWifi;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<AddCameraDelegate>)delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (IBAction)syncOnCloud:(id)sender;
- (IBAction)scanLanSearch:(id)sender;
- (IBAction)scanQRCode:(id)sender;
- (void)setNameFieldBecomeFirstResponder:(BOOL)value;
- (void)setPasswordFieldBecomeFirstResponder:(BOOL)value;

@property (retain, nonatomic) IBOutlet UIButton *qrBtn;
@property (retain, nonatomic) IBOutlet UIButton *lansBtn;
@property (retain, nonatomic) IBOutlet UILabel *qrLbl;


@end
