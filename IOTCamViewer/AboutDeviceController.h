//
//  AboutDeviceController.h
//  IOTCamViewer
//
//  Created by tutk on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@interface AboutDeviceController : UITableViewController <MyCameraDelegate> {
    
    MyCamera *camera;
    
    NSArray *labelItems;    
    
    NSString *model;
    NSInteger version;
    NSString *vender;
    NSInteger totalSize;
    NSInteger freeSize;
    
    UIActivityIndicatorView *modelIndicator;
    UIActivityIndicatorView *versionIndicator;
    UIActivityIndicatorView *venderIndicator;
    UIActivityIndicatorView *totalIndicator;
    UIActivityIndicatorView *freeIndicator;
}

@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSArray *labelItems;
@property (nonatomic, copy) NSString *model;
@property (nonatomic) NSInteger version;
@property (nonatomic, copy) NSString *vender;
@property (nonatomic) NSInteger totalSize;
@property (nonatomic) NSInteger freeSize;

@property (nonatomic, retain) UIActivityIndicatorView *modelIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *versionIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *venderIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *totalIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *freeIndicator;

- (IBAction)back:(id)sender;

@end
