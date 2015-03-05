//
//  EditWiFiPasswordController.h
//  IOTCamViewer
//
//  Created by tutk on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol EditWiFiPasswordDelegate;

@interface EditWiFiPasswordController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MyCameraDelegate> {
    
    UITableView *tableView;
    UITextField *textFieldBeingEdited;
    NSString *ssid;
        
    int ssid_length;
    char mode;
    char enctype;
    
    MyCamera *camera;
    
    id<EditWiFiPasswordDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *textFieldBeingEdited;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic) int ssid_length;
@property (nonatomic) char mode;
@property (nonatomic) char enctype;
@property (nonatomic, retain) id<EditWiFiPasswordDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<EditWiFiPasswordDelegate>)delegate;
- (IBAction)join:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@protocol EditWiFiPasswordDelegate

- (void)didSetPasswordSuccess:(NSString *)ssid;

@end
